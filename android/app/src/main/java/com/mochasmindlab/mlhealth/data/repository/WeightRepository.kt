package com.mochasmindlab.mlhealth.data.repository

import com.mochasmindlab.mlhealth.data.database.WeightDao
import com.mochasmindlab.mlhealth.data.models.WeightEntry
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.first
import java.time.LocalDate
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class WeightRepository @Inject constructor(
    private val weightDao: WeightDao
) {
    suspend fun insertWeightEntry(entry: WeightEntry) = weightDao.insertWeightEntry(entry)
    
    suspend fun updateWeightEntry(entry: WeightEntry) = weightDao.updateWeightEntry(entry)
    
    suspend fun deleteWeightEntry(id: Long) = weightDao.deleteWeightEntry(id)
    
    fun getAllWeightEntries(): Flow<List<WeightEntry>> = weightDao.getAllWeightEntries()
    
    fun getWeightEntryById(id: Long): Flow<WeightEntry?> = weightDao.getWeightEntryById(id)
    
    fun getWeightEntriesBetweenDates(startDate: LocalDate, endDate: LocalDate): Flow<List<WeightEntry>> =
        weightDao.getWeightEntriesBetweenDates(startDate, endDate)
    
    suspend fun getLatestWeight(): WeightEntry? = weightDao.getLatestWeight()
    
    suspend fun getWeightOnDate(date: LocalDate): WeightEntry? = weightDao.getWeightOnDate(date)
    
    suspend fun getWeeklyAverage(): Float {
        val weekAgo = LocalDate.now().minusWeeks(1)
        val entries = weightDao.getWeightEntriesBetweenDates(weekAgo, LocalDate.now()).first()
        return if (entries.isNotEmpty()) {
            entries.map { it.weight }.average().toFloat()
        } else {
            0f
        }
    }
    
    suspend fun getMonthlyProgress(): Float {
        val monthAgo = LocalDate.now().minusMonths(1)
        val oldEntry = weightDao.getWeightOnDate(monthAgo)
        val currentEntry = weightDao.getLatestWeight()
        
        return if (oldEntry != null && currentEntry != null) {
            currentEntry.weight - oldEntry.weight
        } else {
            0f
        }
    }
    
    suspend fun getWeightTrend(days: Int = 30): List<Pair<LocalDate, Float>> {
        val startDate = LocalDate.now().minusDays(days.toLong())
        val entries = weightDao.getWeightEntriesBetweenDates(startDate, LocalDate.now()).first()
        return entries.map { it.date to it.weight }
    }
    
    suspend fun getWeightStatistics(): Map<String, Float> {
        val allEntries = weightDao.getAllWeightEntries().first()
        if (allEntries.isEmpty()) {
            return mapOf(
                "current" to 0f,
                "highest" to 0f,
                "lowest" to 0f,
                "average" to 0f
            )
        }
        
        val weights = allEntries.map { it.weight }
        return mapOf(
            "current" to (allEntries.firstOrNull()?.weight ?: 0f),
            "highest" to weights.maxOrNull()!!,
            "lowest" to weights.minOrNull()!!,
            "average" to weights.average().toFloat()
        )
    }
}