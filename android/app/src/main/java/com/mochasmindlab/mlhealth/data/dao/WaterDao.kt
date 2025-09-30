package com.mochasmindlab.mlhealth.data.dao

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

    @Query("SELECT * FROM water_entries WHERE id = :id")
    suspend fun getById(id: String): WaterEntry?

    @Query("SELECT * FROM water_entries ORDER BY timestamp DESC")
    fun getAllEntries(): Flow<List<WaterEntry>>

    @Query("SELECT * FROM water_entries WHERE timestamp >= :startDate AND timestamp < :endDate ORDER BY timestamp DESC")
    fun getEntriesBetweenDates(startDate: Date, endDate: Date): Flow<List<WaterEntry>>

    @Query("SELECT * FROM water_entries WHERE timestamp >= :startDate AND timestamp < :endDate")
    suspend fun getEntriesBetweenDatesSync(startDate: Date, endDate: Date): List<WaterEntry>

    @Query("SELECT SUM(CASE " +
            "WHEN unit = 'OZ' THEN amount " +
            "WHEN unit = 'ML' THEN amount * 0.033814 " +
            "WHEN unit = 'CUP' THEN amount * 8 " +
            "WHEN unit = 'L' THEN amount * 33.814 " +
            "END) FROM water_entries WHERE timestamp >= :startDate AND timestamp < :endDate")
    suspend fun getTotalOzBetweenDates(startDate: Date, endDate: Date): Float?

    @Query("DELETE FROM water_entries WHERE timestamp < :date")
    suspend fun deleteOlderThan(date: Date)

    @Query("SELECT * FROM water_entries WHERE timestamp >= :startOfDay ORDER BY timestamp ASC LIMIT 1")
    suspend fun getFirstEntryToday(startOfDay: Date): WaterEntry?

    @Query("SELECT * FROM water_entries WHERE timestamp >= :startOfDay ORDER BY timestamp DESC LIMIT 1")
    suspend fun getLastEntryToday(startOfDay: Date): WaterEntry?
}