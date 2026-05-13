package com.mochasmindlab.mlhealth.data.database

import androidx.room.*
import com.mochasmindlab.mlhealth.data.entities.WaterEntry
import kotlinx.coroutines.flow.Flow
import java.util.*

@Dao
interface WaterDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(waterEntry: WaterEntry)

    @Update
    suspend fun update(waterEntry: WaterEntry)

    @Delete
    suspend fun delete(waterEntry: WaterEntry)

    @Query("SELECT * FROM water_entries ORDER BY timestamp DESC")
    fun getAllWaterEntries(): Flow<List<WaterEntry>>

    @Query("SELECT * FROM water_entries WHERE DATE(timestamp/1000, 'unixepoch') = DATE(:date/1000, 'unixepoch') ORDER BY timestamp DESC")
    suspend fun getEntriesForDate(date: Date): List<WaterEntry>

    /** Reactive version — emits whenever water_entries changes. */
    @Query("SELECT * FROM water_entries WHERE DATE(timestamp/1000, 'unixepoch') = DATE(:date/1000, 'unixepoch') ORDER BY timestamp DESC")
    fun getEntriesForDateFlow(date: Date): Flow<List<WaterEntry>>

    @Query("SELECT SUM(amount * CASE unit WHEN 'OZ' THEN 1.0 WHEN 'ML' THEN 0.033814 WHEN 'L' THEN 33.814 WHEN 'CUP' THEN 8.0 WHEN 'PINT' THEN 16.0 WHEN 'QUART' THEN 32.0 WHEN 'GALLON' THEN 128.0 ELSE 1.0 END) FROM water_entries WHERE DATE(timestamp/1000, 'unixepoch') = DATE(:date/1000, 'unixepoch')")
    suspend fun getTotalForDate(date: Date): Double?

    @Query("SELECT * FROM water_entries WHERE timestamp BETWEEN :startDate AND :endDate ORDER BY timestamp DESC")
    suspend fun getEntriesBetweenDates(startDate: Date, endDate: Date): List<WaterEntry>

    @Query("DELETE FROM water_entries")
    suspend fun deleteAllWaterEntries()

    @Query("SELECT * FROM water_entries WHERE id = :id")
    suspend fun getWaterEntryById(id: UUID): WaterEntry?
}