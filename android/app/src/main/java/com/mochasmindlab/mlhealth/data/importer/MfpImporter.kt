package com.mochasmindlab.mlhealth.data.importer

import com.mochasmindlab.mlhealth.data.database.MLFitnessDatabase
import com.mochasmindlab.mlhealth.data.entities.ExerciseEntry
import com.mochasmindlab.mlhealth.data.entities.FoodEntry
import com.mochasmindlab.mlhealth.data.entities.WeightEntry
import com.mochasmindlab.mlhealth.data.models.MealType
import com.mochasmindlab.mlhealth.util.CsvParser
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale
import kotlin.math.roundToInt

/**
 * Imports a MyFitnessPal CSV export into the diary. Handles the three export
 * types MyFitnessPal produces, auto-detected from the header row:
 *   - Nutrition   -> FoodEntry  (one row per logged food, macros already consumed)
 *   - Exercise    -> ExerciseEntry
 *   - Measurement -> WeightEntry
 *
 * Column lookup is header-name based (case-insensitive, tolerant of "(g)"/"(mg)"
 * suffixes and column reordering). Mirrors the iOS MFPImporter.
 */
object MfpImporter {

    enum class Kind { NUTRITION, EXERCISE, WEIGHT }

    /** The app stores weight in pounds; MFP measurement exports don't reliably
     * label the unit, so the user confirms it before importing. */
    enum class WeightUnit(val toPounds: Double) {
        POUNDS(1.0), KILOGRAMS(2.2046226218)
    }

    data class ParsedFoodRow(
        val date: Date, val mealType: MealType, val name: String,
        val calories: Double, val protein: Double, val carbs: Double, val fat: Double,
        val fiber: Double, val sugar: Double, val saturatedFat: Double,
        val cholesterol: Double, val sodium: Double, val additional: Map<String, Double>
    )

    data class ParsedExerciseRow(
        val date: Date, val name: String, val category: String,
        val durationMinutes: Int, val caloriesBurned: Double
    )

    data class ParsedWeightRow(val date: Date, val rawWeight: Double)

    data class Summary(
        val kind: Kind,
        val totalRows: Int,
        val importableRows: Int,
        val skippedRows: Int,
        val startDate: Date?,
        val endDate: Date?,
        val mealCounts: Map<MealType, Int>,
        val sampleNames: List<String>,
        val foodEntries: List<ParsedFoodRow>,
        val exerciseEntries: List<ParsedExerciseRow>,
        val weightEntries: List<ParsedWeightRow>
    ) {
        val noun: String
            get() = when (kind) {
                Kind.NUTRITION -> if (importableRows == 1) "entry" else "entries"
                Kind.EXERCISE -> if (importableRows == 1) "workout" else "workouts"
                Kind.WEIGHT -> if (importableRows == 1) "weigh-in" else "weigh-ins"
            }
    }

    class ImportException(message: String) : Exception(message)

    // MARK: - Preview

    fun preview(csvText: String): Summary {
        val (headers, rows) = CsvParser.parseWithHeaders(csvText)
        if (rows.isEmpty()) throw ImportException("That file has no rows to import.")

        val keys = headers.map { it.lowercase() }
        return when (detectKind(keys)) {
            Kind.NUTRITION -> previewNutrition(rows)
            Kind.EXERCISE -> previewExercise(rows)
            Kind.WEIGHT -> previewWeight(rows)
            null -> throw ImportException(
                "This doesn't look like a MyFitnessPal export. Choose the Nutrition, Exercise, or Measurement CSV from your MyFitnessPal data."
            )
        }
    }

    private fun detectKind(keys: List<String>): Kind? {
        fun has(prefix: String) = keys.any { it.startsWith(prefix) }
        // Order matters: a strength row in an exercise export can carry a
        // "weight" column, so check food and exercise before weight.
        return when {
            has("food") -> Kind.NUTRITION
            has("exercise") -> Kind.EXERCISE
            has("weight") -> Kind.WEIGHT
            else -> null
        }
    }

    // MARK: - Import

    /**
     * Inserts the summary's rows and returns how many were actually added
     * (duplicates already in the diary are skipped). Dedupe is against entries
     * that existed *before* this import, so a full re-import adds nothing.
     */
    suspend fun importSummary(
        summary: Summary,
        weightUnit: WeightUnit,
        db: MLFitnessDatabase,
        progress: (Double) -> Unit
    ): Int = when (summary.kind) {
        Kind.NUTRITION -> insertFood(summary.foodEntries, db, progress)
        Kind.EXERCISE -> insertExercise(summary.exerciseEntries, db, progress)
        Kind.WEIGHT -> insertWeight(summary.weightEntries, weightUnit, db, progress)
    }

    // MARK: - Nutrition

    private fun previewNutrition(rows: List<Map<String, String>>): Summary {
        val parsed = mutableListOf<ParsedFoodRow>()
        var skipped = 0
        for (row in rows) parseFood(row)?.let { parsed.add(it) } ?: skipped++
        val sorted = parsed.sortedBy { it.date }
        return Summary(
            Kind.NUTRITION, rows.size, parsed.size, skipped,
            sorted.firstOrNull()?.date, sorted.lastOrNull()?.date,
            parsed.groupingBy { it.mealType }.eachCount(),
            parsed.take(5).map { it.name }, parsed, emptyList(), emptyList()
        )
    }

    private suspend fun insertFood(entries: List<ParsedFoodRow>, db: MLFitnessDatabase, progress: (Double) -> Unit): Int {
        if (entries.isEmpty()) return 0
        val dao = db.foodDao()
        val (start, end) = dayRange(entries.map { it.date })
        val existing = dao.getEntriesBetween(start, end)
            .map { dedupeKey(it.date, it.name, it.calories) }.toSet()
        var inserted = 0
        val total = entries.size
        entries.forEachIndexed { idx, row ->
            if (!existing.contains(dedupeKey(row.date, row.name, row.calories))) {
                dao.insert(
                    FoodEntry(
                        name = row.name, date = row.date, timestamp = row.date,
                        mealType = row.mealType.name.lowercase(),
                        servingSize = "1", servingUnit = "serving", servingCount = 1.0,
                        calories = row.calories, protein = row.protein, carbs = row.carbs, fat = row.fat,
                        fiber = row.fiber, sugar = row.sugar, sodium = row.sodium,
                        cholesterol = row.cholesterol, saturatedFat = row.saturatedFat,
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

    private fun parseFood(row: Map<String, String>): ParsedFoodRow? {
        val date = value(row, listOf("date"))?.let { parseDate(it) } ?: return null
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
            date = dated, mealType = meal, name = name,
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

    // MARK: - Exercise

    private fun previewExercise(rows: List<Map<String, String>>): Summary {
        val parsed = mutableListOf<ParsedExerciseRow>()
        var skipped = 0
        for (row in rows) parseExercise(row)?.let { parsed.add(it) } ?: skipped++
        val sorted = parsed.sortedBy { it.date }
        return Summary(
            Kind.EXERCISE, rows.size, parsed.size, skipped,
            sorted.firstOrNull()?.date, sorted.lastOrNull()?.date, emptyMap(),
            parsed.take(5).map { it.name }, emptyList(), parsed, emptyList()
        )
    }

    private suspend fun insertExercise(entries: List<ParsedExerciseRow>, db: MLFitnessDatabase, progress: (Double) -> Unit): Int {
        if (entries.isEmpty()) return 0
        val dao = db.exerciseDao()
        val (start, end) = dayRange(entries.map { it.date })
        val existing = dao.getExercisesBetweenOnce(start, end)
            .map { dedupeKey(it.date, it.name, it.caloriesBurned) }.toSet()
        var inserted = 0
        val total = entries.size
        entries.forEachIndexed { idx, row ->
            if (!existing.contains(dedupeKey(row.date, row.name, row.caloriesBurned))) {
                dao.insert(
                    ExerciseEntry(
                        name = row.name, category = row.category, type = row.category,
                        date = row.date, timestamp = row.date,
                        duration = row.durationMinutes, caloriesBurned = row.caloriesBurned
                    )
                )
                inserted++
            }
            if (idx % 100 == 0) progress(idx.toDouble() / total)
        }
        progress(1.0)
        return inserted
    }

    private fun parseExercise(row: Map<String, String>): ParsedExerciseRow? {
        val date = value(row, listOf("date"))?.let { parseDate(it) } ?: return null
        val name = value(row, listOf("exercise", "name"))?.takeIf { it.isNotEmpty() } ?: return null
        val category = mapExerciseCategory(value(row, listOf("type")) ?: "Cardio")
        val minutes = (number(row, listOf("exercise minutes", "minutes", "duration")) ?: 0.0).toInt()
        val calories = number(row, listOf("exercise calories", "calories burned", "calories")) ?: 0.0
        val dated = atTime(date, 12, 0)
        return ParsedExerciseRow(dated, name, category, minutes, calories)
    }

    private fun mapExerciseCategory(raw: String): String {
        val lower = raw.lowercase()
        return when {
            lower.contains("strength") || lower.contains("weight") -> "Strength"
            lower.contains("cardio") -> "Cardio"
            raw.isEmpty() -> "Cardio"
            else -> raw
        }
    }

    // MARK: - Weight

    private fun previewWeight(rows: List<Map<String, String>>): Summary {
        val parsed = mutableListOf<ParsedWeightRow>()
        var skipped = 0
        for (row in rows) parseWeight(row)?.let { parsed.add(it) } ?: skipped++
        val sorted = parsed.sortedBy { it.date }
        return Summary(
            Kind.WEIGHT, rows.size, parsed.size, skipped,
            sorted.firstOrNull()?.date, sorted.lastOrNull()?.date, emptyMap(),
            emptyList(), emptyList(), emptyList(), parsed
        )
    }

    private suspend fun insertWeight(entries: List<ParsedWeightRow>, unit: WeightUnit, db: MLFitnessDatabase, progress: (Double) -> Unit): Int {
        if (entries.isEmpty()) return 0
        val dao = db.weightDao()
        val factor = unit.toPounds
        val (start, end) = dayRange(entries.map { it.date })
        val existing = dao.getEntriesInRange(start, end)
            .map { weightKey(it.date, it.weight) }.toSet()
        var inserted = 0
        val total = entries.size
        entries.forEachIndexed { idx, row ->
            val pounds = row.rawWeight * factor
            if (!existing.contains(weightKey(row.date, pounds))) {
                dao.insert(WeightEntry(weight = pounds, date = row.date, timestamp = row.date))
                inserted++
            }
            if (idx % 100 == 0) progress(idx.toDouble() / total)
        }
        progress(1.0)
        return inserted
    }

    private fun parseWeight(row: Map<String, String>): ParsedWeightRow? {
        val date = value(row, listOf("date"))?.let { parseDate(it) } ?: return null
        val w = number(row, listOf("weight"))?.takeIf { it > 0 } ?: return null
        return ParsedWeightRow(atTime(date, 7, 0), w)
    }

    // MARK: - Meal + time mapping

    private fun mapMeal(raw: String): MealType = when (raw.trim().lowercase()) {
        "breakfast" -> MealType.BREAKFAST
        "lunch" -> MealType.LUNCH
        "dinner" -> MealType.DINNER
        "snack", "snacks" -> MealType.SNACK
        else -> MealType.SNACK
    }

    private fun timestamp(meal: MealType, date: Date): Date {
        val (h, m) = when (meal) {
            MealType.BREAKFAST -> 8 to 0
            MealType.LUNCH -> 12 to 30
            MealType.DINNER -> 19 to 0
            MealType.SNACK -> 15 to 0
        }
        return atTime(date, h, m)
    }

    private fun atTime(date: Date, hour: Int, minute: Int): Date {
        val cal = Calendar.getInstance()
        cal.time = date
        cal.set(Calendar.HOUR_OF_DAY, hour)
        cal.set(Calendar.MINUTE, minute)
        cal.set(Calendar.SECOND, 0)
        cal.set(Calendar.MILLISECOND, 0)
        return cal.time
    }

    // MARK: - Dedupe

    private fun startOfDay(date: Date): Date {
        val cal = Calendar.getInstance()
        cal.time = date
        cal.set(Calendar.HOUR_OF_DAY, 0); cal.set(Calendar.MINUTE, 0)
        cal.set(Calendar.SECOND, 0); cal.set(Calendar.MILLISECOND, 0)
        return cal.time
    }

    private fun dayRange(dates: List<Date>): Pair<Date, Date> {
        val min = dates.minOrNull() ?: Date(0)
        val max = dates.maxOrNull() ?: Date(0)
        val start = startOfDay(min)
        val cal = Calendar.getInstance()
        cal.time = startOfDay(max)
        cal.add(Calendar.DAY_OF_YEAR, 1)
        return Pair(start, cal.time)
    }

    private fun dedupeKey(day: Date, name: String, n: Double): String =
        "${startOfDay(day).time}|${name.lowercase()}|${n.roundToInt()}"

    private fun weightKey(day: Date, pounds: Double): String =
        "${startOfDay(day).time}|${(pounds * 10).roundToInt()}"   // 0.1 lb resolution

    // MARK: - Column helpers

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
        return raw.replace(",", "").replace(" ", "").toDoubleOrNull()
    }

    private fun parseDate(raw: String): Date? {
        val trimmed = raw.trim()
        for (format in dateFormats) {
            try {
                val df = SimpleDateFormat(format, Locale.US)
                df.isLenient = false
                return df.parse(trimmed) ?: continue
            } catch (_: Exception) {
            }
        }
        return null
    }

    private val dateFormats = listOf(
        "yyyy-MM-dd", "MM/dd/yyyy", "M/d/yyyy", "dd/MM/yyyy", "d/M/yyyy", "yyyy/MM/dd", "MMMM d, yyyy"
    )
}
