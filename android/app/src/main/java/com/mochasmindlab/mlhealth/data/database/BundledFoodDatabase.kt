package com.mochasmindlab.mlhealth.data.database

import android.content.Context
import android.database.sqlite.SQLiteDatabase
import com.mochasmindlab.mlhealth.data.models.FoodItem
import dagger.hilt.android.qualifiers.ApplicationContext
import org.json.JSONObject
import javax.inject.Inject
import javax.inject.Singleton
import kotlin.math.roundToInt

/**
 * Read-only accessor for the bundled USDA food database (~53K rows, FTS5).
 * Mirrors iOS LocalFoodDatabase.swift: prefix-match FTS5 with LIKE fallback.
 *
 * The asset is copied into the app's databases dir on first access. Search
 * results are returned as FoodItem with id=0 (i.e. not yet persisted to Room).
 */
@Singleton
class BundledFoodDatabase @Inject constructor(
    @ApplicationContext private val context: Context
) {
    private val db: SQLiteDatabase by lazy { open() }

    fun search(query: String, limit: Int = 50): List<FoodItem> {
        val trimmed = query.trim()
        if (trimmed.isEmpty()) return emptyList()

        val ftsQuery = trimmed
            .split(Regex("\\s+"))
            .filter { it.isNotEmpty() }
            .joinToString(" ") { "\"${it.replace("\"", "\"\"")}\"*" }

        // Match iOS LocalFoodDatabase ordering: unbranded foods first ("egg"
        // before "Egg Whisk Brand Eggs"), then common items, then FTS rank.
        // Without the brand-IS-NULL guard, branded entries like "Just Egg" or
        // "Eggo Waffles" bubble above the plain ingredient. (Bug reported by
        // tester searching "eggs" 2026-05-22.)
        val sql = """
            SELECT f.fdcId, f.name, f.brand, f.servingSize, f.servingUnit,
                   f.calories, f.protein, f.carbs, f.fat, f.fiber, f.sugar, f.sodium,
                   f.cholesterol, f.saturatedFat, f.additionalNutrients
            FROM foods f
            JOIN foods_fts fts ON f.fdcId = fts.rowid
            WHERE foods_fts MATCH ?
            ORDER BY (f.brand IS NULL OR f.brand = '') DESC, f.isCommon DESC, rank
            LIMIT ?
        """.trimIndent()

        val ftsResults = runCatching {
            queryFoods(sql, arrayOf(ftsQuery, limit.toString()))
        }.getOrDefault(emptyList())

        return ftsResults.ifEmpty { searchLike(trimmed, limit) }
    }

    fun findByFdcId(fdcId: Int): FoodItem? {
        val sql = """
            SELECT fdcId, name, brand, servingSize, servingUnit,
                   calories, protein, carbs, fat, fiber, sugar, sodium,
                   cholesterol, saturatedFat, additionalNutrients
            FROM foods WHERE fdcId = ?
        """.trimIndent()
        return queryFoods(sql, arrayOf(fdcId.toString())).firstOrNull()
    }

    private fun searchLike(query: String, limit: Int): List<FoodItem> {
        // Same unbranded-first rule as the FTS path above — see comment there.
        val sql = """
            SELECT fdcId, name, brand, servingSize, servingUnit,
                   calories, protein, carbs, fat, fiber, sugar, sodium,
                   cholesterol, saturatedFat, additionalNutrients
            FROM foods
            WHERE name LIKE ? OR brand LIKE ?
            ORDER BY (brand IS NULL OR brand = '') DESC, isCommon DESC,
                     CASE WHEN LOWER(name) = LOWER(?) THEN 0
                          WHEN LOWER(name) LIKE LOWER(? || '%') THEN 1
                          ELSE 2 END,
                     name
            LIMIT ?
        """.trimIndent()
        val pattern = "%$query%"
        return queryFoods(sql, arrayOf(pattern, pattern, query, query, limit.toString()))
    }

    private fun queryFoods(sql: String, args: Array<String>): List<FoodItem> {
        val results = mutableListOf<FoodItem>()
        db.rawQuery(sql, args).use { cursor ->
            val cholIdx = cursor.getColumnIndex("cholesterol")
            val satIdx = cursor.getColumnIndex("saturatedFat")
            val addlIdx = cursor.getColumnIndex("additionalNutrients")
            while (cursor.moveToNext()) {
                val brand = cursor.getString(2)?.takeIf { it.isNotBlank() }
                results += FoodItem(
                    id = 0L,
                    name = cursor.getString(1),
                    brand = brand,
                    calories = cursor.getDouble(5).roundToInt(),
                    protein = cursor.getDouble(6).toFloat(),
                    carbs = cursor.getDouble(7).toFloat(),
                    fat = cursor.getDouble(8).toFloat(),
                    fiber = cursor.getDouble(9).toFloat(),
                    sugar = cursor.getDouble(10).toFloat(),
                    sodium = cursor.getDouble(11).toFloat(),
                    cholesterol = if (cholIdx >= 0 && !cursor.isNull(cholIdx)) cursor.getDouble(cholIdx).toFloat() else null,
                    saturatedFat = if (satIdx >= 0 && !cursor.isNull(satIdx)) cursor.getDouble(satIdx).toFloat() else null,
                    additionalNutrients = if (addlIdx >= 0) parseAdditionalNutrients(cursor.getString(addlIdx)) else emptyMap(),
                    servingSize = cursor.getString(3) ?: "1",
                    servingUnit = cursor.getString(4) ?: "serving"
                )
            }
        }
        return results
    }

    /**
     * The bundled DB stores vitamins/minerals as a small JSON object,
     * e.g. {"iron":2.12,"vitamin_c":0.1,"calcium":28.0}. Parse leniently —
     * a malformed/empty value just yields no micros for that food.
     */
    private fun parseAdditionalNutrients(raw: String?): Map<String, Double> {
        if (raw.isNullOrBlank() || raw == "null") return emptyMap()
        return try {
            val obj = JSONObject(raw)
            buildMap {
                obj.keys().forEach { key ->
                    val v = obj.optDouble(key, Double.NaN)
                    if (!v.isNaN()) put(key, v)
                }
            }
        } catch (e: Exception) {
            emptyMap()
        }
    }

    private fun open(): SQLiteDatabase {
        // Copy to a versioned on-disk name so an app update that ships a newer
        // asset (e.g. one carrying vitamins/minerals) replaces the stale copy
        // from a previous install instead of reusing it forever.
        val dbFile = context.getDatabasePath(DISK_NAME)
        if (!dbFile.exists()) {
            dbFile.parentFile?.mkdirs()
            context.assets.open(ASSET_NAME).use { input ->
                dbFile.outputStream().use { output -> input.copyTo(output) }
            }
            // Best-effort cleanup of the pre-v2 copy so we don't keep ~14 MB dead.
            runCatching { context.getDatabasePath(LEGACY_DISK_NAME).delete() }
        }
        return SQLiteDatabase.openDatabase(
            dbFile.absolutePath,
            null,
            SQLiteDatabase.OPEN_READONLY
        )
    }

    companion object {
        private const val ASSET_NAME = "food_database.sqlite"
        // Bumped from the un-suffixed name to force a fresh copy of the asset
        // that carries cholesterol / saturated fat / vitamins / minerals.
        private const val DISK_NAME = "food_database_v2.sqlite"
        private const val LEGACY_DISK_NAME = "food_database.sqlite"
    }
}
