package com.mochasmindlab.mlhealth.data.repository

import com.mochasmindlab.mlhealth.data.database.WeightDao
import com.mochasmindlab.mlhealth.data.entities.WeightEntry
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.first
import java.time.LocalDate
import java.util.Date
import java.time.ZoneId
import java.util.UUID
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class WeightRepository @Inject constructor(
    private val weightDao: WeightDao
) {
    suspend fun insertWeightEntry(entry: WeightEntry) = weightDao.insertWeightEntry(entry)
    
    suspend fun updateWeightEntry(entry: WeightEntry) = weightDao.updateWeightEntry(entry)
    
    suspend fun deleteWeightEntry(id: UUID) = weightDao.deleteWeightEntry(id)
    
    fun getAllWeightEntries(): Flow<List<WeightEntry>> = weightDao.getAllWeightEntries()
    
    fun getWeightEntryById(id: UUID): Flow<WeightEntry?> = weightDao.getWeightEntryById(id)
    
    fun getWeightEntriesBetweenDates(startDate: Date, endDate: Date): Flow<List<WeightEntry>> =
        weightDao.getWeightEntriesBetweenDates(startDate, endDate)
    
    suspend fun getLatestWeight(): WeightEntry? = weightDao.getLatestWeight()
    
    suspend fun getWeightOnDate(date: Date): WeightEntry? = weightDao.getWeightOnDate(date)
    
    suspend fun getWeeklyAverage(): Double {
        val weekAgo = Date.from(LocalDate.now().minusWeeks(1).atStartOfDay(ZoneId.systemDefault()).toInstant())
        val entries = weightDao.getWeightEntriesBetweenDates(weekAgo, Date()).first()
        return if (entries.isNotEmpty()) {
            entries.map { it.weight }.average()
        } else {
            0.0
        }
    }
    
    suspend fun getMonthlyProgress(): Double {
        val monthAgo = Date.from(LocalDate.now().minusMonths(1).atStartOfDay(ZoneId.systemDefault()).toInstant())
        val oldEntry = weightDao.getWeightOnDate(monthAgo)
        val currentEntry = weightDao.getLatestWeight()

        return if (oldEntry != null && currentEntry != null) {
            currentEntry.weight - oldEntry.weight
        } else {
            0.0
        }
    }
    
    suspend fun getWeightTrend(days: Int = 30): List<Pair<Date, Double>> {
        val startDate = Date.from(LocalDate.now().minusDays(days.toLong()).atStartOfDay(ZoneId.systemDefault()).toInstant())
        val entries = weightDao.getWeightEntriesBetweenDates(startDate, Date()).first()
        return entries.map { it.date to it.weight }
    }
    
    suspend fun getWeightStatistics(): Map<String, Double> {
        val allEntries = weightDao.getAllWeightEntries().first()
        if (allEntries.isEmpty()) {
            return mapOf(
                "current" to 0.0,
                "highest" to 0.0,
                "lowest" to 0.0,
                "average" to 0.0
            )
        }

        val weights = allEntries.map { it.weight }
        return mapOf(
            "current" to (allEntries.firstOrNull()?.weight ?: 0.0),
            "highest" to weights.maxOrNull()!!,
            "lowest" to weights.minOrNull()!!,
            "average" to weights.average()
        )
    }
}