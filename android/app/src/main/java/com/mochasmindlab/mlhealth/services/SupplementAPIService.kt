package com.mochasmindlab.mlhealth.services

import com.mochasmindlab.mlhealth.config.ApiConfig
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.serialization.json.*
import okhttp3.OkHttpClient
import okhttp3.Request
import java.util.concurrent.TimeUnit

/**
 * Service for looking up supplement information from various APIs
 * Integrates multiple databases for comprehensive coverage
 */
class SupplementAPIService {
    private val client = OkHttpClient.Builder()
        .connectTimeout(10, TimeUnit.SECONDS)
        .readTimeout(10, TimeUnit.SECONDS)
        .build()

    private val json = Json {
        ignoreUnknownKeys = true
        isLenient = true
    }

    data class SupplementInfo(
        val name: String,
        val brand: String? = null,
        val barcode: String? = null,
        val ingredients: List<String> = emptyList(),
        val servingSize: String? = null,
        val nutrients: Map<String, Double> = emptyMap(),
        val source: String
    )

    /**
     * Search multiple APIs for supplement information
     */
    suspend fun lookupSupplement(barcode: String): SupplementInfo? = withContext(Dispatchers.IO) {
        try {
            // Try NIH DSLD first (most comprehensive for supplements)
            val nihResult = searchNIHDatabase(barcode)
            if (nihResult != null) return@withContext nihResult

            // Try Open Food Facts (global coverage)
            val offResult = searchOpenFoodFacts(barcode)
            if (offResult != null) return@withContext offResult

            // Try USDA FoodData Central
            val usdaResult = searchUSDADatabase(barcode)
            if (usdaResult != null) return@withContext usdaResult

            // Try Nutritionix if API key is configured
            val nutritionixResult = searchNutritionix(barcode)
            if (nutritionixResult != null) return@withContext nutritionixResult

            null
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }

    /**
     * NIH Dietary Supplement Label Database
     * FREE - No API key required
     * https://dsld.od.nih.gov/api/
     */
    private suspend fun searchNIHDatabase(barcode: String): SupplementInfo? {
        try {
            // Search by UPC/barcode
            val searchUrl = "https://api.ods.od.nih.gov/dsld/v8/label?upc=$barcode"

            val request = Request.Builder()
                .url(searchUrl)
                .header("Accept", "application/json")
                .build()

            val response = client.newCall(request).execute()
            if (!response.isSuccessful || response.body == null) {
                // Try searching by name if barcode doesn't work
                return searchNIHByName(barcode)
            }

            val responseBody = response.body!!.string()
            val jsonResponse = json.parseToJsonElement(responseBody)

            if (jsonResponse is JsonArray && jsonResponse.size > 0) {
                val product = jsonResponse[0].jsonObject
                return parseNIHProduct(product, barcode)
            }

            return null
        } catch (e: Exception) {
            e.printStackTrace()
            return null
        }
    }

    private suspend fun searchNIHByName(query: String): SupplementInfo? {
        try {
            val searchUrl = "https://api.ods.od.nih.gov/dsld/v8/browse?search=$query&limit=1"

            val request = Request.Builder()
                .url(searchUrl)
                .header("Accept", "application/json")
                .build()

            val response = client.newCall(request).execute()
            if (!response.isSuccessful || response.body == null) return null

            val responseBody = response.body!!.string()
            val jsonResponse = json.parseToJsonElement(responseBody).jsonObject

            val products = jsonResponse["products"]?.jsonArray
            if (products != null && products.size > 0) {
                val productId = products[0].jsonObject["dsld_id"]?.jsonPrimitive?.content
                if (productId != null) {
                    return getNIHProductDetails(productId)
                }
            }

            return null
        } catch (e: Exception) {
            e.printStackTrace()
            return null
        }
    }

    private suspend fun getNIHProductDetails(dsldId: String): SupplementInfo? {
        try {
            val detailUrl = "https://api.ods.od.nih.gov/dsld/v8/label/$dsldId"

            val request = Request.Builder()
                .url(detailUrl)
                .header("Accept", "application/json")
                .build()

            val response = client.newCall(request).execute()
            if (!response.isSuccessful || response.body == null) return null

            val responseBody = response.body!!.string()
            val product = json.parseToJsonElement(responseBody).jsonObject

            return parseNIHProduct(product, null)
        } catch (e: Exception) {
            e.printStackTrace()
            return null
        }
    }

    private fun parseNIHProduct(product: JsonObject, barcode: String?): SupplementInfo {
        val name = product["product_name"]?.jsonPrimitive?.content ?: "Unknown Supplement"
        val brand = product["brand_name"]?.jsonPrimitive?.content
        val servingSize = product["serving_size"]?.jsonPrimitive?.content

        val ingredients = mutableListOf<String>()
        val nutrients = mutableMapOf<String, Double>()

        // Parse ingredients
        product["ingredients"]?.jsonArray?.forEach { ingredient ->
            val ingObj = ingredient.jsonObject
            val ingName = ingObj["ingredient_name"]?.jsonPrimitive?.content
            val amount = ingObj["amount"]?.jsonPrimitive?.doubleOrNull
            val unit = ingObj["unit"]?.jsonPrimitive?.content

            if (ingName != null) {
                if (amount != null && unit != null) {
                    ingredients.add("$ingName: $amount$unit")
                    nutrients[ingName] = amount
                } else {
                    ingredients.add(ingName)
                }
            }
        }

        return SupplementInfo(
            name = name,
            brand = brand,
            barcode = barcode,
            ingredients = ingredients,
            servingSize = servingSize,
            nutrients = nutrients,
            source = "NIH DSLD"
        )
    }

    /**
     * Open Food Facts API
     * FREE - No API key required
     */
    private suspend fun searchOpenFoodFacts(barcode: String): SupplementInfo? {
        try {
            val url = "https://world.openfoodfacts.org/api/v2/product/$barcode.json"
            val request = Request.Builder()
                .url(url)
                .header("User-Agent", "ML Fitness Android App - Version 1.0")
                .build()

            val response = client.newCall(request).execute()
            if (!response.isSuccessful || response.body == null) return null

            val responseBody = response.body!!.string()
            val jsonResponse = json.parseToJsonElement(responseBody).jsonObject

            val status = jsonResponse["status"]?.jsonPrimitive?.intOrNull ?: 0
            if (status != 1) return null

            val product = jsonResponse["product"]?.jsonObject ?: return null

            // Check if it's a supplement/vitamin category
            val categories = product["categories"]?.jsonPrimitive?.content ?: ""
            if (!categories.contains("supplement", ignoreCase = true) &&
                !categories.contains("vitamin", ignoreCase = true)) {
                return null
            }

            return parseOpenFoodFactsSupplement(product, barcode)
        } catch (e: Exception) {
            e.printStackTrace()
            return null
        }
    }

    private fun parseOpenFoodFactsSupplement(product: JsonObject, barcode: String): SupplementInfo {
        val name = product["product_name"]?.jsonPrimitive?.content ?: "Unknown"
        val brand = product["brands"]?.jsonPrimitive?.content
        val servingSize = product["serving_size"]?.jsonPrimitive?.content

        val ingredients = product["ingredients_text"]?.jsonPrimitive?.content
            ?.split(",")
            ?.map { it.trim() }
            ?: emptyList()

        val nutrients = mutableMapOf<String, Double>()
        val nutriments = product["nutriments"]?.jsonObject

        nutriments?.let {
            it["vitamin-a_100g"]?.jsonPrimitive?.doubleOrNull?.let { v -> nutrients["Vitamin A"] = v }
            it["vitamin-c_100g"]?.jsonPrimitive?.doubleOrNull?.let { v -> nutrients["Vitamin C"] = v }
            it["vitamin-d_100g"]?.jsonPrimitive?.doubleOrNull?.let { v -> nutrients["Vitamin D"] = v }
            it["vitamin-e_100g"]?.jsonPrimitive?.doubleOrNull?.let { v -> nutrients["Vitamin E"] = v }
            it["vitamin-b1_100g"]?.jsonPrimitive?.doubleOrNull?.let { v -> nutrients["Thiamine"] = v }
            it["vitamin-b2_100g"]?.jsonPrimitive?.doubleOrNull?.let { v -> nutrients["Riboflavin"] = v }
            it["vitamin-b6_100g"]?.jsonPrimitive?.doubleOrNull?.let { v -> nutrients["Vitamin B6"] = v }
            it["vitamin-b12_100g"]?.jsonPrimitive?.doubleOrNull?.let { v -> nutrients["Vitamin B12"] = v }
            it["calcium_100g"]?.jsonPrimitive?.doubleOrNull?.let { v -> nutrients["Calcium"] = v }
            it["iron_100g"]?.jsonPrimitive?.doubleOrNull?.let { v -> nutrients["Iron"] = v }
            it["magnesium_100g"]?.jsonPrimitive?.doubleOrNull?.let { v -> nutrients["Magnesium"] = v }
            it["zinc_100g"]?.jsonPrimitive?.doubleOrNull?.let { v -> nutrients["Zinc"] = v }
        }

        return SupplementInfo(
            name = name,
            brand = brand,
            barcode = barcode,
            ingredients = ingredients,
            servingSize = servingSize,
            nutrients = nutrients,
            source = "Open Food Facts"
        )
    }

    /**
     * USDA FoodData Central
     * Using existing API key
     */
    private suspend fun searchUSDADatabase(barcode: String): SupplementInfo? {
        if (!ApiConfig.isApiConfigured("USDA")) return null

        try {
            val url = "https://api.nal.usda.gov/fdc/v1/foods/search?" +
                    "query=$barcode&" +
                    "dataType=Dietary%20Supplement&" +
                    "api_key=${ApiConfig.USDA_API_KEY}"

            val request = Request.Builder()
                .url(url)
                .build()

            val response = client.newCall(request).execute()
            if (!response.isSuccessful || response.body == null) return null

            val responseBody = response.body!!.string()
            val jsonResponse = json.parseToJsonElement(responseBody).jsonObject

            val foods = jsonResponse["foods"]?.jsonArray
            if (foods.isNullOrEmpty()) return null

            val supplement = foods[0].jsonObject
            return parseUSDASupplement(supplement, barcode)
        } catch (e: Exception) {
            e.printStackTrace()
            return null
        }
    }

    private fun parseUSDASupplement(supplement: JsonObject, barcode: String): SupplementInfo {
        val description = supplement["description"]?.jsonPrimitive?.content ?: "Unknown"
        val brand = supplement["brandOwner"]?.jsonPrimitive?.content
        val servingSize = supplement["servingSize"]?.jsonPrimitive?.content

        val ingredients = supplement["ingredients"]?.jsonPrimitive?.content
            ?.split(",")
            ?.map { it.trim() }
            ?: emptyList()

        val nutrients = mutableMapOf<String, Double>()
        val foodNutrients = supplement["foodNutrients"]?.jsonArray

        foodNutrients?.forEach { nutrientElement ->
            val nutrient = nutrientElement.jsonObject
            val name = nutrient["nutrientName"]?.jsonPrimitive?.content
            val value = nutrient["value"]?.jsonPrimitive?.doubleOrNull

            if (name != null && value != null) {
                nutrients[name] = value
            }
        }

        return SupplementInfo(
            name = description,
            brand = brand,
            barcode = barcode,
            ingredients = ingredients,
            servingSize = servingSize,
            nutrients = nutrients,
            source = "USDA FoodData Central"
        )
    }

    /**
     * Nutritionix API
     * Requires API key configuration
     */
    private suspend fun searchNutritionix(barcode: String): SupplementInfo? {
        val appId = ApiConfig.NUTRITIONIX_APP_ID
        val appKey = ApiConfig.NUTRITIONIX_APP_KEY

        if (appId.isBlank() || appKey.isBlank()) return null

        try {
            val url = "https://trackapi.nutritionix.com/v2/search/item?upc=$barcode"

            val request = Request.Builder()
                .url(url)
                .header("x-app-id", appId)
                .header("x-app-key", appKey)
                .build()

            val response = client.newCall(request).execute()
            if (!response.isSuccessful || response.body == null) return null

            val responseBody = response.body!!.string()
            val jsonResponse = json.parseToJsonElement(responseBody).jsonObject

            val foods = jsonResponse["foods"]?.jsonArray
            if (foods.isNullOrEmpty()) return null

            val item = foods[0].jsonObject
            return parseNutritionixItem(item, barcode)
        } catch (e: Exception) {
            e.printStackTrace()
            return null
        }
    }

    private fun parseNutritionixItem(item: JsonObject, barcode: String): SupplementInfo {
        val name = item["item_name"]?.jsonPrimitive?.content ?: "Unknown"
        val brand = item["brand_name"]?.jsonPrimitive?.content
        val servingSize = item["serving_qty"]?.jsonPrimitive?.content

        val nutrients = mutableMapOf<String, Double>()

        // Parse available nutrients
        item["nf_vitamin_a_dv"]?.jsonPrimitive?.doubleOrNull?.let { nutrients["Vitamin A"] = it }
        item["nf_vitamin_c_dv"]?.jsonPrimitive?.doubleOrNull?.let { nutrients["Vitamin C"] = it }
        item["nf_calcium_dv"]?.jsonPrimitive?.doubleOrNull?.let { nutrients["Calcium"] = it }
        item["nf_iron_dv"]?.jsonPrimitive?.doubleOrNull?.let { nutrients["Iron"] = it }

        return SupplementInfo(
            name = name,
            brand = brand,
            barcode = barcode,
            ingredients = emptyList(),
            servingSize = servingSize,
            nutrients = nutrients,
            source = "Nutritionix"
        )
    }

    /**
     * Search by supplement name across all APIs
     */
    suspend fun searchByName(query: String): List<SupplementInfo> = withContext(Dispatchers.IO) {
        val results = mutableListOf<SupplementInfo>()

        // Search NIH database
        searchNIHByName(query)?.let { results.add(it) }

        // Add more API searches as needed

        results
    }
}