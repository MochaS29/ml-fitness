package com.mochasmindlab.mlhealth.data.database

import androidx.room.*
import com.mochasmindlab.mlhealth.data.models.WeightEntry
import kotlinx.coroutines.flow.Flow
import java.time.LocalDate

@Dao
interface WeightDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertWeightEntry(entry: WeightEntry): Long
    
    @Update
    suspend fun updateWeightEntry(entry: WeightEntry)
    
    @Query("DELETE FROM weight_entries WHERE id = :id")
    suspend fun deleteWeightEntry(id: Long)
    
    @Query("SELECT * FROM weight_entries ORDER BY date DESC")
    fun getAllWeightEntries(): Flow<List<WeightEntry>>
    
    @Query("SELECT * FROM weight_entries WHERE id = :id")
    fun getWeightEntryById(id: Long): Flow<WeightEntry?>
    
    @Query("SELECT * FROM weight_entries WHERE date BETWEEN :startDate AND :endDate ORDER BY date DESC")
    fun getWeightEntriesBetweenDates(startDate: LocalDate, endDate: LocalDate): Flow<List<WeightEntry>>
    
    @Query("SELECT * FROM weight_entries ORDER BY date DESC LIMIT 1")
    suspend fun getLatestWeight(): WeightEntry?
    
    @Query("SELECT * FROM weight_entries WHERE date = :date LIMIT 1")
    suspend fun getWeightOnDate(date: LocalDate): WeightEntry?
    
    @Query("DELETE FROM weight_entries")
    suspend fun deleteAllWeightEntries()
}