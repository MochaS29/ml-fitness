package com.mochasmindlab.mlhealth.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mochasmindlab.mlhealth.data.database.SleepDao
import com.mochasmindlab.mlhealth.data.entities.SleepEntry
import com.mochasmindlab.mlhealth.services.HealthConnectManager
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import java.time.LocalDate
import java.util.Calendar
import java.util.Date
import java.util.UUID
import javax.inject.Inject
import kotlin.math.abs

@HiltViewModel
class SleepTrackingViewModel @Inject constructor(
    private val dao: SleepDao,
    private val healthConnect: HealthConnectManager
) : ViewModel() {

    // ── All entries live list ─────────────────────────────────────────────────
    val entries: StateFlow<List<SleepEntry>> =
        dao.getAll()
            .stateIn(
                scope = viewModelScope,
                started = SharingStarted.WhileSubscribed(5_000),
                initialValue = emptyList()
            )

    // ── Last 7 days (derived from the full live list) ─────────────────────────
    val last7Days: StateFlow<List<SleepEntry>> =
        entries
            .map { list ->
                val cutoff = sevenDaysAgoMidnight()
                list.filter { it.bedTime.time >= cutoff }
            }
            .stateIn(
                scope = viewModelScope,
                started = SharingStarted.WhileSubscribed(5_000),
                initialValue = emptyList()
            )

    // ── 7-day average sleep in hours ─────────────────────────────────────────
    val avgHoursLast7: StateFlow<Double> =
        last7Days
            .map { list ->
                if (list.isEmpty()) 0.0
                else list.map { it.durationMinutes / 60.0 }.average()
            }
            .stateIn(
                scope = viewModelScope,
                started = SharingStarted.WhileSubscribed(5_000),
                initialValue = 0.0
            )

    // ── Error / status ────────────────────────────────────────────────────────
    private val _errorMessage = MutableStateFlow<String?>(null)
    val errorMessage: StateFlow<String?> = _errorMessage.asStateFlow()

    private val _isSyncing = MutableStateFlow(false)
    val isSyncing: StateFlow<Boolean> = _isSyncing.asStateFlow()

    // ── Mutations ─────────────────────────────────────────────────────────────

    fun addEntry(
        bedTime: Date,
        wakeTime: Date,
        quality: Int? = null,
        notes: String? = null
    ) {
        viewModelScope.launch {
            try {
                dao.insert(
                    SleepEntry(
                        id = UUID.randomUUID(),
                        bedTime = bedTime,
                        wakeTime = wakeTime,
                        quality = quality,
                        notes = notes?.ifBlank { null },
                        source = "manual"
                    )
                )
            } catch (e: Exception) {
                _errorMessage.value = "Failed to save entry: ${e.message}"
            }
        }
    }

    fun delete(entry: SleepEntry) {
        viewModelScope.launch {
            try {
                dao.delete(entry)
            } catch (e: Exception) {
                _errorMessage.value = "Failed to delete entry: ${e.message}"
            }
        }
    }

    /**
     * Reads SleepSessionRecord from Health Connect for the last 7 days and inserts any
     * sessions that don't already have a manual entry within ±30 minutes of the bed-time.
     */
    fun syncFromHealthConnect() {
        viewModelScope.launch {
            _isSyncing.value = true
            try {
                val existingEntries = dao.getInRange(
                    start = Date(sevenDaysAgoMidnight()),
                    end = Date()
                )
                val thirtyMinMs = 30 * 60 * 1000L

                for (daysBack in 0..6) {
                    val date = LocalDate.now().minusDays(daysBack.toLong())
                    val sessions = healthConnect.readSleepSessions(date)
                    for (session in sessions) {
                        val isDuplicate = existingEntries.any { existing ->
                            abs(existing.bedTime.time - session.bedTime.time) <= thirtyMinMs
                        }
                        if (!isDuplicate) {
                            dao.insert(session)
                        }
                    }
                }
            } catch (e: Exception) {
                _errorMessage.value = "Sync failed: ${e.message}"
            } finally {
                _isSyncing.value = false
            }
        }
    }

    fun clearError() {
        _errorMessage.value = null
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    private fun sevenDaysAgoMidnight(): Long {
        val cal = Calendar.getInstance()
        cal.add(Calendar.DAY_OF_MONTH, -7)
        cal.set(Calendar.HOUR_OF_DAY, 0)
        cal.set(Calendar.MINUTE, 0)
        cal.set(Calendar.SECOND, 0)
        cal.set(Calendar.MILLISECOND, 0)
        return cal.timeInMillis
    }
}
