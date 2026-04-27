package com.mochasmindlab.mlhealth.services

import com.mochasmindlab.mlhealth.data.entities.CustomRecipe
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.serialization.json.*
import okhttp3.OkHttpClient
import okhttp3.Request
import java.io.IOException
import java.util.Date
import java.util.UUID
import java.util.concurrent.TimeUnit
import javax.inject.Inject
import javax.inject.Singleton

/**
 * Imports recipes from public URLs by parsing JSON-LD schema.org/Recipe blocks.
 * Mirrors iOS RecipeImportService / SchemaOrgParser.
 * Constructs its own OkHttpClient (consistent with other services in this project).
 */
@Singleton
class RecipeImportService @Inject constructor() {

    private val okHttpClient: OkHttpClient = OkHttpClient.Builder()
        .connectTimeout(15, TimeUnit.SECONDS)
        .readTimeout(15, TimeUnit.SECONDS)
        .build()

    // ---------- Public API ----------

    suspend fun importFromUrl(url: String): Result<CustomRecipe> = withContext(Dispatchers.IO) {
        runCatching {
            val html = fetchHtml(url)
            val blocks = extractJsonLdBlocks(html)
            val recipe = blocks.firstNotNullOfOrNull { parseBlock(it, url) }
                ?: throw IOException("Could not import: no Recipe JSON-LD found at $url")
            recipe
        }.recoverCatching { e ->
            throw IOException("Could not import: ${e.message}")
        }
    }

    // ---------- HTTP ----------

    private fun fetchHtml(url: String): String {
        val request = Request.Builder()
            .url(url)
            .header(
                "User-Agent",
                "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) " +
                "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36"
            )
            .header("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8")
            .header("Referer", "https://www.google.com/")
            .header("DNT", "1")
            .build()

        okHttpClient.newCall(request).execute().use { response ->
            if (!response.isSuccessful) throw IOException("HTTP ${response.code}")
            return response.body?.string() ?: throw IOException("Empty response body")
        }
    }

    // ---------- JSON-LD extraction ----------

    /** Returns the raw text content of every <script type="application/ld+json"> block. */
    private fun extractJsonLdBlocks(html: String): List<String> {
        val pattern = Regex(
            """<script[^>]*type=["']application/ld\+json["'][^>]*>(.*?)</script>""",
            setOf(RegexOption.IGNORE_CASE, RegexOption.DOT_MATCHES_ALL)
        )
        return pattern.findAll(html).map { it.groupValues[1].trim() }.toList()
    }

    // ---------- JSON-LD parsing ----------

    private val json = Json { ignoreUnknownKeys = true; isLenient = true; coerceInputValues = true }

    /** Try to parse a raw JSON-LD string and return a CustomRecipe if it contains a Recipe node. */
    private fun parseBlock(raw: String, sourceUrl: String): CustomRecipe? {
        return runCatching {
            val element = json.parseToJsonElement(raw)
            val recipeObj = findRecipeObject(element) ?: return null
            mapToCustomRecipe(recipeObj, sourceUrl)
        }.getOrNull()
    }

    /** Finds the Recipe object inside a JSON element (handles all 4 site patterns). */
    private fun findRecipeObject(element: JsonElement): JsonObject? {
        return when (element) {
            is JsonObject -> {
                if (isRecipeType(element["@type"])) return element
                // @graph array
                val graph = element["@graph"]
                if (graph is JsonArray) {
                    graph.filterIsInstance<JsonObject>().firstOrNull { isRecipeType(it["@type"]) }
                } else null
            }
            is JsonArray -> element.filterIsInstance<JsonObject>()
                .firstOrNull { isRecipeType(it["@type"]) }
                ?: element.filterIsInstance<JsonObject>().firstNotNullOfOrNull { findRecipeObject(it) }
            else -> null
        }
    }

    private fun isRecipeType(element: JsonElement?): Boolean = when (element) {
        is JsonPrimitive -> element.content.contains("Recipe", ignoreCase = true)
        is JsonArray     -> element.filterIsInstance<JsonPrimitive>()
                                .any { it.content.contains("Recipe", ignoreCase = true) }
        else -> false
    }

    // ---------- Mapping ----------

    private fun mapToCustomRecipe(obj: JsonObject, sourceUrl: String): CustomRecipe {
        val name = decodeHtmlEntities(obj["name"]?.jsonPrimitive?.contentOrNull ?: "Imported Recipe")
        val description = decodeHtmlEntities(obj["description"]?.jsonPrimitive?.contentOrNull ?: "")

        val ingredients = (obj["recipeIngredient"] as? JsonArray)
            ?.filterIsInstance<JsonPrimitive>()
            ?.map { decodeHtmlEntities(it.content) }
            ?: emptyList()

        val instructions = parseInstructions(obj["recipeInstructions"])

        val prepTime = parseIsoDuration(obj["prepTime"]?.jsonPrimitive?.contentOrNull)
        val cookTime = parseIsoDuration(obj["cookTime"]?.jsonPrimitive?.contentOrNull)

        val nutritionObj = obj["nutrition"] as? JsonObject
        val calories  = extractNutrientDouble(nutritionObj?.get("calories"))
        val protein   = extractNutrientDouble(nutritionObj?.get("proteinContent"))
        val carbs     = extractNutrientDouble(nutritionObj?.get("carbohydrateContent"))
        val fat       = extractNutrientDouble(nutritionObj?.get("fatContent"))
        val fiber     = nutritionObj?.get("fiberContent")?.let { extractNutrientDouble(it) }
        val sugar     = nutritionObj?.get("sugarContent")?.let { extractNutrientDouble(it) }
        val sodium    = nutritionObj?.get("sodiumContent")?.let { extractNutrientDouble(it) }

        val tags = (obj["keywords"] as? JsonPrimitive)?.content
            ?.split(",")
            ?.map { decodeHtmlEntities(it.trim()) }
            ?.filter { it.isNotEmpty() }
            ?: emptyList()

        return CustomRecipe(
            id           = UUID.randomUUID(),
            name         = name,
            category     = guessCategory(name, tags),
            source       = sourceUrl,
            isUserCreated = false,
            isFavorite   = false,
            createdDate  = Date(),
            prepTime     = prepTime,
            cookTime     = cookTime,
            servings     = parseServings(obj["recipeYield"]),
            ingredients  = ingredients,
            instructions = instructions,
            tags         = tags,
            calories     = calories,
            protein      = protein,
            carbs        = carbs,
            fat          = fat,
            fiber        = fiber,
            sugar        = sugar,
            sodium       = sodium
        )
    }

    private fun parseInstructions(element: JsonElement?): List<String> = when (element) {
        is JsonArray -> element.mapNotNull { step ->
            when (step) {
                is JsonPrimitive -> decodeHtmlEntities(step.content).takeIf { it.isNotEmpty() }
                is JsonObject    -> decodeHtmlEntities(
                    step["text"]?.jsonPrimitive?.contentOrNull
                        ?: step["name"]?.jsonPrimitive?.contentOrNull
                        ?: ""
                ).takeIf { it.isNotEmpty() }
                else -> null
            }
        }
        is JsonPrimitive -> element.content.lines()
            .map { decodeHtmlEntities(it.trim()) }
            .filter { it.isNotEmpty() }
        else -> emptyList()
    }

    /** Parses ISO 8601 duration strings like "PT15M", "PT1H30M" into minutes. */
    private fun parseIsoDuration(duration: String?): Int {
        if (duration.isNullOrBlank()) return 0
        val hours   = Regex("""(\d+)H""").find(duration)?.groupValues?.get(1)?.toIntOrNull() ?: 0
        val minutes = Regex("""(\d+)M""").find(duration)?.groupValues?.get(1)?.toIntOrNull() ?: 0
        return hours * 60 + minutes
    }

    private fun parseServings(element: JsonElement?): Int {
        val raw = when (element) {
            is JsonPrimitive -> element.content
            is JsonArray     -> (element.firstOrNull() as? JsonPrimitive)?.content ?: ""
            else             -> return 2
        }
        return Regex("""\d+""").find(raw)?.value?.toIntOrNull() ?: 2
    }

    private fun extractNutrientDouble(element: JsonElement?): Double {
        if (element == null) return 0.0
        val raw = (element as? JsonPrimitive)?.content ?: return 0.0
        return Regex("""\d+(\.\d+)?""").find(raw)?.value?.toDoubleOrNull() ?: 0.0
    }

    private fun guessCategory(name: String, tags: List<String>): String {
        val text = (name + " " + tags.joinToString(" ")).lowercase()
        return when {
            text.contains("breakfast") || text.contains("oatmeal") ||
            text.contains("pancake") || text.contains("waffle") -> "Breakfast"
            text.contains("lunch") || text.contains("sandwich") -> "Lunch"
            text.contains("dinner") || text.contains("main")    -> "Dinner"
            text.contains("snack") || text.contains("appetizer")-> "Snack"
            else                                                 -> "Dinner"
        }
    }

    // ---------- HTML entity decoding ----------

    private val namedEntities = mapOf(
        "&amp;"   to "&",  "&lt;"    to "<",  "&gt;"    to ">",
        "&quot;"  to "\"", "&apos;"  to "'",  "&#39;"   to "'",
        "&nbsp;"  to " ",  "&rsquo;" to "’", "&lsquo;" to "‘",
        "&rdquo;" to "”", "&ldquo;" to "“",
        "&mdash;" to "—", "&ndash;" to "–",
        "&hellip;" to "…", "&frac12;" to "½"
    )

    fun decodeHtmlEntities(input: String): String {
        var s = input
        namedEntities.forEach { (entity, char) ->
            s = s.replace(entity, char, ignoreCase = true)
        }
        // Numeric decimal &#NNN;
        s = Regex("""&#(\d+);""").replace(s) { mr ->
            mr.groupValues[1].toIntOrNull()?.toChar()?.toString() ?: mr.value
        }
        // Numeric hex &#xHH;
        s = Regex("""&#x([0-9a-fA-F]+);""", RegexOption.IGNORE_CASE).replace(s) { mr ->
            mr.groupValues[1].toInt(16).toChar().toString()
        }
        return s
    }
}
