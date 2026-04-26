package com.mochasmindlab.mlhealth.data.database

import android.content.Context
import android.database.sqlite.SQLiteDatabase
import com.mochasmindlab.mlhealth.data.models.FoodItem
import dagger.hilt.android.qualifiers.ApplicationContext
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

        val sql = """
            SELECT f.fdcId, f.name, f.brand, f.servingSize, f.servingUnit,
                   f.calories, f.protein, f.carbs, f.fat, f.fiber, f.sugar, f.sodium
            FROM foods f
            JOIN foods_fts fts ON f.fdcId = fts.rowid
            WHERE foods_fts MATCH ?
            ORDER BY f.isCommon DESC, rank
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
                   calories, protein, carbs, fat, fiber, sugar, sodium
            FROM foods WHERE fdcId = ?
        """.trimIndent()
        return queryFoods(sql, arrayOf(fdcId.toString())).firstOrNull()
    }

    private fun searchLike(query: String, limit: Int): List<FoodItem> {
        val sql = """
            SELECT fdcId, name, brand, servingSize, servingUnit,
                   calories, protein, carbs, fat, fiber, sugar, sodium
            FROM foods
            WHERE name LIKE ? OR brand LIKE ?
            ORDER BY isCommon DESC,
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
                    servingSize = cursor.getString(3) ?: "1",
                    servingUnit = cursor.getString(4) ?: "serving"
                )
            }
        }
        return results
    }

    private fun open(): SQLiteDatabase {
        val dbFile = context.getDatabasePath(DB_NAME)
        if (!dbFile.exists()) {
            dbFile.parentFile?.mkdirs()
            context.assets.open(DB_NAME).use { input ->
                dbFile.outputStream().use { output -> input.copyTo(output) }
            }
        }
        return SQLiteDatabase.openDatabase(
            dbFile.absolutePath,
            null,
            SQLiteDatabase.OPEN_READONLY
        )
    }

    companion object {
        private const val DB_NAME = "food_database.sqlite"
    }
}
