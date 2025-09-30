package com.mochasmindlab.mlhealth.data.repository

import com.mochasmindlab.mlhealth.data.database.WaterDao
import com.mochasmindlab.mlhealth.data.entities.WaterEntry
import com.mochasmindlab.mlhealth.data.entities.WaterUnit
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow
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

    fun getTodayWaterEntries(): Flow<List<WaterEntry>> = flow {
        val today = Date()
        emit(waterDao.getEntriesForDate(today))
    }

    suspend fun getTodayWaterIntakeOz(): Float {
        val today = Date()
        val totalAmount = waterDao.getTotalForDate(today) ?: 0.0
        return totalAmount.toFloat()
    }

    suspend fun getWaterEntriesForDate(date: Date): List<WaterEntry> {
        return waterDao.getEntriesForDate(date)
    }

    suspend fun getWaterIntakeOzForDate(date: Date): Float {
        val totalAmount = waterDao.getTotalForDate(date) ?: 0.0
        return totalAmount.toFloat()
    }

    suspend fun addQuickWaterEntry(ozAmount: Float) {
        val waterEntry = WaterEntry(
            amount = ozAmount,
            unit = WaterUnit.OZ,
            timestamp = Date()
        )
        waterDao.insert(waterEntry)
    }
}