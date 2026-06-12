package com.mochasmindlab.mlhealth.data.repository

import com.mochasmindlab.mlhealth.data.database.SupplementDao
import com.mochasmindlab.mlhealth.data.entities.SupplementEntry
import kotlinx.coroutines.flow.Flow
import java.util.*
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class SupplementRepository @Inject constructor(
    private val supplementDao: SupplementDao
) {
    suspend fun addSupplementEntry(entry: SupplementEntry) {
        supplementDao.insert(entry)
    }

    suspend fun updateSupplementEntry(entry: SupplementEntry) {
        supplementDao.update(entry)
    }

    suspend fun deleteSupplementEntry(entry: SupplementEntry) {
        supplementDao.delete(entry)
    }

    suspend fun getSupplementsForDate(date: Date): List<SupplementEntry> {
        return supplementDao.getEntriesForDate(date)
    }

    suspend fun getAllSupplementNames(): List<String> {
        return supplementDao.getAllSupplementNames()
    }

    suspend fun getSupplementsForDateRange(startDate: Date, endDate: Date): List<SupplementEntry> {
        val allSupplements = mutableListOf<SupplementEntry>()
        val calendar = Calendar.getInstance()
        calendar.time = startDate

        while (calendar.time <= endDate) {
            allSupplements.addAll(getSupplementsForDate(calendar.time))
            calendar.add(Calendar.DAY_OF_MONTH, 1)
        }

        return allSupplements
    }

    suspend fun getTodaySupplements(): List<SupplementEntry> {
        val calendar = Calendar.getInstance()
        calendar.set(Calendar.HOUR_OF_DAY, 0)
        calendar.set(Calendar.MINUTE, 0)
        calendar.set(Calendar.SECOND, 0)
        calendar.set(Calendar.MILLISECOND, 0)
        val today = calendar.time

        return getSupplementsForDate(today)
    }
}