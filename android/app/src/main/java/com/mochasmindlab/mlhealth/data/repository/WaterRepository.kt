package com.mochasmindlab.mlhealth.data.repository

import com.mochasmindlab.mlhealth.data.dao.WaterDao
import com.mochasmindlab.mlhealth.data.entities.WaterEntry
import kotlinx.coroutines.flow.Flow
import java.util.*
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class WaterRepository @Inject constructor(
    private val waterDao: WaterDao
) {
    suspend fun addWaterEntry(waterEntry: WaterEntry) {
        waterDao.insert(waterEntry)
    }

    suspend fun updateWaterEntry(waterEntry: WaterEntry) {
        waterDao.update(waterEntry)
    }

    suspend fun deleteWaterEntry(waterEntry: WaterEntry) {
        waterDao.delete(waterEntry)
    }

    fun getAllWaterEntries(): Flow<List<WaterEntry>> {
        return waterDao.getAllEntries()
    }

    fun getTodayWaterEntries(): Flow<List<WaterEntry>> {
        val calendar = Calendar.getInstance()
        calendar.set(Calendar.HOUR_OF_DAY, 0)
        calendar.set(Calendar.MINUTE, 0)
        calendar.set(Calendar.SECOND, 0)
        calendar.set(Calendar.MILLISECOND, 0)
        val startOfDay = calendar.time

        calendar.add(Calendar.DAY_OF_MONTH, 1)
        val endOfDay = calendar.time

        return waterDao.getEntriesBetweenDates(startOfDay, endOfDay)
    }

    suspend fun getTodayWaterIntakeOz(): Float {
        val calendar = Calendar.getInstance()
        calendar.set(Calendar.HOUR_OF_DAY, 0)
        calendar.set(Calendar.MINUTE, 0)
        calendar.set(Calendar.SECOND, 0)
        calendar.set(Calendar.MILLISECOND, 0)
        val startOfDay = calendar.time

        calendar.add(Calendar.DAY_OF_MONTH, 1)
        val endOfDay = calendar.time

        return waterDao.getTotalOzBetweenDates(startOfDay, endOfDay) ?: 0f
    }

    fun getWaterEntriesBetweenDates(startDate: Date, endDate: Date): Flow<List<WaterEntry>> {
        return waterDao.getEntriesBetweenDates(startDate, endDate)
    }

    suspend fun getWaterIntakeOzBetweenDates(startDate: Date, endDate: Date): Float {
        return waterDao.getTotalOzBetweenDates(startDate, endDate) ?: 0f
    }

    suspend fun addQuickWaterEntry(ozAmount: Float) {
        val waterEntry = WaterEntry(
            amount = ozAmount,
            unit = WaterUnit.OZ,
            timestamp = Date()
        )
        waterDao.insert(waterEntry)
    }

    suspend fun deleteOldEntries(olderThan: Date) {
        waterDao.deleteOlderThan(olderThan)
    }
}