package com.mlhealth.app.data.local

import androidx.room.*
import java.time.LocalDateTime

@Entity(tableName = "supplement_entries")
@TypeConverters(SupplementConverters::class)
data class SupplementEntryEntity(
    @PrimaryKey
    val id: String,
    val name: String,
    val brand: String,
    val category: String,
    val servingSize: String,
    val timestamp: LocalDateTime,
    val nutrients: Map<String, Double>,
    val barcode: String? = null,
    val dpn: String? = null,
    val notes: String? = null,
    val isFavorite: Boolean = false
)

@Dao
interface SupplementEntryDao {
    @Query("SELECT * FROM supplement_entries ORDER BY timestamp DESC")
    fun getAllSupplementEntries(): kotlinx.coroutines.flow.Flow<List<SupplementEntryEntity>>

    @Query("SELECT * FROM supplement_entries WHERE id = :id")
    suspend fun getSupplementEntryById(id: String): SupplementEntryEntity?

    @Query("SELECT * FROM supplement_entries WHERE DATE(timestamp) = DATE(:date) ORDER BY timestamp DESC")
    suspend fun getSupplementEntriesByDate(date: LocalDateTime): List<SupplementEntryEntity>

    @Query("SELECT * FROM supplement_entries WHERE barcode = :barcode LIMIT 1")
    suspend fun getSupplementEntryByBarcode(barcode: String): SupplementEntryEntity?

    @Query("SELECT * FROM supplement_entries WHERE dpn = :dpn LIMIT 1")
    suspend fun getSupplementEntryByDPN(dpn: String): SupplementEntryEntity?

    @Query("SELECT * FROM supplement_entries WHERE isFavorite = 1 ORDER BY name ASC")
    suspend fun getFavoriteSupplements(): List<SupplementEntryEntity>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertSupplementEntry(entry: SupplementEntryEntity)

    @Update
    suspend fun updateSupplementEntry(entry: SupplementEntryEntity)

    @Query("DELETE FROM supplement_entries WHERE id = :id")
    suspend fun deleteSupplementEntry(id: String)

    @Query("DELETE FROM supplement_entries")
    suspend fun deleteAllSupplementEntries()

    @Query("UPDATE supplement_entries SET isFavorite = :isFavorite WHERE id = :id")
    suspend fun updateFavoriteStatus(id: String, isFavorite: Boolean)
}

class SupplementConverters {
    @TypeConverter
    fun fromNutrientsMap(nutrients: Map<String, Double>): String {
        return nutrients.entries.joinToString(";") { "${it.key}:${it.value}" }
    }

    @TypeConverter
    fun toNutrientsMap(nutrientsString: String): Map<String, Double> {
        if (nutrientsString.isEmpty()) return emptyMap()

        return nutrientsString.split(";").associate { entry ->
            val parts = entry.split(":")
            parts[0] to parts[1].toDouble()
        }
    }
}