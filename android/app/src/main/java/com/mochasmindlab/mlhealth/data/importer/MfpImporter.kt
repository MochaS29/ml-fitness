package com.mochasmindlab.mlhealth.data.importer

import com.mochasmindlab.mlhealth.data.database.FoodDao
import com.mochasmindlab.mlhealth.data.entities.FoodEntry
import com.mochasmindlab.mlhealth.data.models.MealType
import com.mochasmindlab.mlhealth.util.CsvParser
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale
import kotlin.math.roundToInt

/**
 * Imports a MyFitnessPal "Nutrition" CSV export into the food diary.
 *
 * MFP exports one row per logged food, and each row already carries the
 * *consumed* macros (not per-serving values times a count), so every row maps
 * cleanly to a single [FoodEntry] with servingCount = 1. No serving math.
 *
 * Column lookup is header-name based (case-insensitive, tolerant of "(g)"/"(mg)"
 * suffixes and column reordering). Mirrors the iOS MFPImporter.
 */
object MfpImporter {

    data class ParsedFoodRow(
        val date: Date,
        val mealType: MealType,
        val name: String,
        val calories: Double,
        val protein: Double,
        val carbs: Double,
        val fat: Double,
        val fiber: Double,
        val sugar: Double,
        val saturatedFat: Double,
        val cholesterol: Double,
        val sodium: Double,
        val additional: Map<String, Double>
    )

    data class Summary(
        val totalRows: Int,
        val importableRows: Int,
        val skippedRows: Int,
        val startDate: Date?,
        val endDate: Date?,
        val mealCounts: Map<MealType, Int>,
        val sampleNames: List<String>,
        val entries: List<ParsedFoodRow>
    )

    class ImportException(message: String) : Exception(message)

    // MARK: - Preview (parse only, no insert)

    fun preview(csvText: String): Summary {
        val (headers, rows) = CsvParser.parseWithHeaders(csvText)
        if (rows.isEmpty()) throw ImportException("That file has no rows to import.")

        val keys = headers.map { it.lowercase() }
        val hasRequired = hasColumn(keys, listOf("date")) &&
            hasColumn(keys, listOf("food", "name")) &&
            hasColumn(keys, listOf("calories", "energy"))
        if (!hasRequired) {
            throw ImportException(
                "This doesn't look like a MyFitnessPal Nutrition export. It needs at least Date, Food, and Calories columns."
            )
        }

        val parsed = mutableListOf<ParsedFoodRow>()
        var skipped = 0
        for (row in rows) {
            val entry = parseRow(row)
            if (entry != null) parsed.add(entry) else skipped++
        }

        val sorted = parsed.sortedBy { it.date }
        val mealCounts = parsed.groupingBy { it.mealType }.eachCount()

        return Summary(
            totalRows = rows.size,
            importableRows = parsed.size,
            skippedRows = skipped,
            startDate = sorted.firstOrNull()?.date,
            endDate = sorted.lastOrNull()?.date,
            mealCounts = mealCounts,
            sampleNames = parsed.take(5).map { it.name },
            entries = parsed
        )
    }

    // MARK: - Import (insert with dedupe)

    /**
     * Inserts the parsed rows and returns how many were actually added
     * (duplicates already in the diary are skipped). Dedupe is against entries
     * that existed *before* this import, so a full re-import of the same file
     * adds nothing, while legitimately repeated foods within one file are kept.
     */
    suspend fun importEntries(
        entries: List<ParsedFoodRow>,
        dao: FoodDao,
        progress: (Double) -> Unit
    ): Int {
        if (entries.isEmpty()) return 0

        val existingKeys = existingDedupeKeys(entries, dao)

        var inserted = 0
        val total = entries.size
        entries.forEachIndexed { idx, row ->
            val key = dedupeKey(row.date, row.name, row.calories)
            if (!existingKeys.contains(key)) {
                dao.insert(
                    FoodEntry(
                        name = row.name,
                        date = row.date,
                        timestamp = row.date,
                        mealType = row.mealType.name.lowercase(),
                        servingSize = "1",
                        servingUnit = "serving",
                        servingCount = 1.0,
                        calories = row.calories,
                        protein = row.protein,
                        carbs = row.carbs,
                        fat = row.fat,
                        fiber = row.fiber,
                        sugar = row.sugar,
                        sodium = row.sodium,
                        cholesterol = row.cholesterol,
                        saturatedFat = row.saturatedFat,
                        additionalNutrients = row.additional
                    )
                )
                inserted++
            }
            if (idx % 100 == 0) progress(idx.toDouble() / total)
        }
        progress(1.0)
        return inserted
    }

    // MARK: - Row parsing

    private fun parseRow(row: Map<String, String>): ParsedFoodRow? {
        val dateStr = value(row, listOf("date")) ?: return null
        val date = parseDate(dateStr) ?: return null
        val name = value(row, listOf("food", "name"))?.takeIf { it.isNotEmpty() } ?: return null

        val meal = mapMeal(value(row, listOf("meal")) ?: "")
        val dated = timestamp(meal, date)

        val additional = mutableMapOf<String, Double>()
        number(row, listOf("potassium"))?.let { additional["Potassium"] = it }
        number(row, listOf("vitamin a"))?.let { additional["Vitamin A"] = it }
        number(row, listOf("vitamin c"))?.let { additional["Vitamin C"] = it }
        number(row, listOf("calcium"))?.let { additional["Calcium"] = it }
        number(row, listOf("iron"))?.let { additional["Iron"] = it }

        return ParsedFoodRow(
            date = dated,
            mealType = meal,
            name = name,
            calories = number(row, listOf("calories", "energy")) ?: 0.0,
            protein = number(row, listOf("protein (g)", "protein")) ?: 0.0,
            carbs = number(row, listOf("carbohydrates (g)", "carbohydrates", "carbs")) ?: 0.0,
            fat = number(row, listOf("fat (g)", "fat")) ?: 0.0,
            fiber = number(row, listOf("fiber", "fibre")) ?: 0.0,
            sugar = number(row, listOf("sugar")) ?: 0.0,
            saturatedFat = number(row, listOf("saturated fat")) ?: 0.0,
            cholesterol = number(row, listOf("cholesterol")) ?: 0.0,
            sodium = number(row, listOf("sodium (mg)", "sodium")) ?: 0.0,
            additional = additional
        )
    }

    // MARK: - Meal + time mapping

    private fun mapMeal(raw: String): MealType = when (raw.trim().lowercase()) {
        "breakfast" -> MealType.BREAKFAST
        "lunch" -> MealType.LUNCH
        "dinner" -> MealType.DINNER
        "snack", "snacks" -> MealType.SNACK
        else -> MealType.SNACK   // custom / renamed meals map to Snack
    }

    /** MFP exports carry no time of day; assign a stable per-meal time so the
     * diary orders entries sensibly. Matches iOS conventions. */
    private fun timestamp(meal: MealType, date: Date): Date {
        val (h, m) = when (meal) {
            MealType.BREAKFAST -> 8 to 0
            MealType.LUNCH -> 12 to 30
            MealType.DINNER -> 19 to 0
            MealType.SNACK -> 15 to 0
        }
        val cal = Calendar.getInstance()
        cal.time = date
        cal.set(Calendar.HOUR_OF_DAY, h)
        cal.set(Calendar.MINUTE, m)
        cal.set(Calendar.SECOND, 0)
        cal.set(Calendar.MILLISECOND, 0)
        return cal.time
    }

    // MARK: - Dedupe

    private fun dedupeKey(day: Date, name: String, calories: Double): String {
        val cal = Calendar.getInstance()
        cal.time = day
        cal.set(Calendar.HOUR_OF_DAY, 0)
        cal.set(Calendar.MINUTE, 0)
        cal.set(Calendar.SECOND, 0)
        cal.set(Calendar.MILLISECOND, 0)
        return "${cal.timeInMillis}|${name.lowercase()}|${calories.roundToInt()}"
    }

    private suspend fun existingDedupeKeys(entries: List<ParsedFoodRow>, dao: FoodDao): Set<String> {
        val dates = entries.map { it.date }
        val minDate = dates.minOrNull() ?: return emptySet()
        val maxDate = dates.maxOrNull() ?: return emptySet()

        val cal = Calendar.getInstance()
        cal.time = minDate
        cal.set(Calendar.HOUR_OF_DAY, 0); cal.set(Calendar.MINUTE, 0)
        cal.set(Calendar.SECOND, 0); cal.set(Calendar.MILLISECOND, 0)
        val start = cal.time

        cal.time = maxDate
        cal.set(Calendar.HOUR_OF_DAY, 0); cal.set(Calendar.MINUTE, 0)
        cal.set(Calendar.SECOND, 0); cal.set(Calendar.MILLISECOND, 0)
        cal.add(Calendar.DAY_OF_YEAR, 1)
        val end = cal.time

        val existing = dao.getEntriesBetween(start, end)
        return existing.map { dedupeKey(it.date, it.name, it.calories) }.toSet()
    }

    // MARK: - Column helpers

    private fun hasColumn(keys: List<String>, candidates: List<String>): Boolean =
        candidates.any { candidate -> keys.any { it == candidate || it.startsWith(candidate) } }

    private fun value(row: Map<String, String>, candidates: List<String>): String? {
        for (candidate in candidates) {
            val exact = row[candidate]
            if (!exact.isNullOrEmpty()) return exact.trim()
        }
        for (candidate in candidates) {
            val match = row.entries.firstOrNull { it.key.startsWith(candidate) }?.value
            if (!match.isNullOrEmpty()) return match.trim()
        }
        return null
    }

    private fun number(row: Map<String, String>, candidates: List<String>): Double? {
        val raw = value(row, candidates) ?: return null
        val cleaned = raw.replace(",", "").replace(" ", "")
        return cleaned.toDoubleOrNull()
    }

    private fun parseDate(raw: String): Date? {
        val trimmed = raw.trim()
        for (format in dateFormats) {
            try {
                val df = SimpleDateFormat(format, Locale.US)
                df.isLenient = false
                return df.parse(trimmed) ?: continue
            } catch (_: Exception) {
                // try next format
            }
        }
        return null
    }

    private val dateFormats = listOf(
        "yyyy-MM-dd", "MM/dd/yyyy", "M/d/yyyy", "dd/MM/yyyy", "d/M/yyyy", "yyyy/MM/dd", "MMMM d, yyyy"
    )
}
