package com.mochasmindlab.mlhealth.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mochasmindlab.mlhealth.data.entities.WaterEntry
import com.mochasmindlab.mlhealth.data.entities.WaterUnit
import com.mochasmindlab.mlhealth.data.repository.WaterRepository
import com.mochasmindlab.mlhealth.utils.PreferencesManager
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import java.util.*
import javax.inject.Inject

@HiltViewModel
class WaterTrackingViewModel @Inject constructor(
    private val waterRepository: WaterRepository,
    private val preferencesManager: PreferencesManager
) : ViewModel() {

    // UI State
    data class WaterTrackingUiState(
        val todayEntries: List<WaterEntry> = emptyList(),
        val totalOuncesToday: Float = 0f,
        val waterGoalOz: Int = 64, // Default 8 glasses of 8oz
        val glassesConsumed: Int = 0,
        val progressPercentage: Float = 0f,
        val remindersEnabled: Boolean = false,
        val reminderInterval: String = "Every 2 hours",
        val isLoading: Boolean = false,
        val errorMessage: String? = null
    )

    private val _uiState = MutableStateFlow(WaterTrackingUiState())
    val uiState: StateFlow<WaterTrackingUiState> = _uiState.asStateFlow()

    private val _waterGoalOz = MutableStateFlow(64) // Default 64 oz (8 glasses)
    val waterGoalOz: StateFlow<Int> = _waterGoalOz.asStateFlow()

    init {
        loadWaterGoal()
        loadTodayWaterEntries()
        checkReminderStatus()
    }

    private fun loadWaterGoal() {
        viewModelScope.launch {
            preferencesManager.waterGoalOz.collect { goal ->
                _waterGoalOz.value = goal
                updateProgressCalculations()
            }
        }
    }

    private fun loadTodayWaterEntries() {
        viewModelScope.launch {
            waterRepository.getTodayWaterEntries().collect { entries ->
                val totalOz = entries.sumOf { it.getAmountInOz().toDouble() }.toFloat()
                val glasses = (totalOz / 8).toInt()
                val progress = (totalOz / _waterGoalOz.value) * 100

                _uiState.update { currentState ->
                    currentState.copy(
                        todayEntries = entries,
                        totalOuncesToday = totalOz,
                        glassesConsumed = glasses,
                        progressPercentage = progress.coerceIn(0f, 100f),
                        waterGoalOz = _waterGoalOz.value
                    )
                }
            }
        }
    }

    private fun checkReminderStatus() {
        viewModelScope.launch {
            preferencesManager.waterRemindersEnabled.collect { enabled ->
                _uiState.update { it.copy(remindersEnabled = enabled) }
            }
        }
    }

    fun addWater(ounces: Float) {
        viewModelScope.launch {
            try {
                _uiState.update { it.copy(isLoading = true) }
                waterRepository.addQuickWaterEntry(ounces)
                _uiState.update { it.copy(isLoading = false) }
            } catch (e: Exception) {
                _uiState.update {
                    it.copy(
                        isLoading = false,
                        errorMessage = "Failed to add water entry: ${e.message}"
                    )
                }
            }
        }
    }

    fun addGlass() {
        addWater(8f) // 8 oz per glass
    }

    fun addBottle() {
        addWater(16.9f) // Standard water bottle size
    }

    fun addCustomAmount(amount: Float, unit: WaterUnit) {
        viewModelScope.launch {
            try {
                _uiState.update { it.copy(isLoading = true) }
                val waterEntry = WaterEntry(
                    amount = amount,
                    unit = unit,
                    timestamp = Date()
                )
                waterRepository.addWaterEntry(waterEntry)
                _uiState.update { it.copy(isLoading = false) }
            } catch (e: Exception) {
                _uiState.update {
                    it.copy(
                        isLoading = false,
                        errorMessage = "Failed to add water entry: ${e.message}"
                    )
                }
            }
        }
    }

    fun deleteWaterEntry(entry: WaterEntry) {
        viewModelScope.launch {
            try {
                waterRepository.deleteWaterEntry(entry)
            } catch (e: Exception) {
                _uiState.update {
                    it.copy(errorMessage = "Failed to delete water entry: ${e.message}")
                }
            }
        }
    }

    fun updateWaterGoal(newGoalOz: Int) {
        viewModelScope.launch {
            preferencesManager.setWaterGoalOz(newGoalOz)
            _waterGoalOz.value = newGoalOz
            updateProgressCalculations()
        }
    }

    fun toggleReminders() {
        viewModelScope.launch {
            val newState = !_uiState.value.remindersEnabled
            preferencesManager.setWaterRemindersEnabled(newState)
            _uiState.update { it.copy(remindersEnabled = newState) }

            if (newState) {
                scheduleWaterReminders()
            } else {
                cancelWaterReminders()
            }
        }
    }

    fun updateReminderInterval(interval: String) {
        viewModelScope.launch {
            preferencesManager.setWaterReminderInterval(interval)
            _uiState.update { it.copy(reminderInterval = interval) }

            if (_uiState.value.remindersEnabled) {
                scheduleWaterReminders()
            }
        }
    }

    private fun updateProgressCalculations() {
        val totalOz = _uiState.value.totalOuncesToday
        val glasses = (totalOz / 8).toInt()
        val progress = (totalOz / _waterGoalOz.value) * 100

        _uiState.update { currentState ->
            currentState.copy(
                glassesConsumed = glasses,
                progressPercentage = progress.coerceIn(0f, 100f),
                waterGoalOz = _waterGoalOz.value
            )
        }
    }

    private fun scheduleWaterReminders() {
        // TODO: Implement using WorkManager or AlarmManager
        // This would schedule periodic notifications based on the interval
    }

    private fun cancelWaterReminders() {
        // TODO: Cancel scheduled notifications
    }

    fun clearErrorMessage() {
        _uiState.update { it.copy(errorMessage = null) }
    }

    // Get water intake history for charts
    suspend fun getWeeklyWaterData(): Map<Date, Float> {
        val calendar = Calendar.getInstance()
        calendar.add(Calendar.DAY_OF_MONTH, -7)
        val startDate = calendar.time
        val endDate = Date()

        val entries = waterRepository.getWaterEntriesBetweenDates(startDate, endDate)
            .first()

        return entries.groupBy { entry ->
            val cal = Calendar.getInstance()
            cal.time = entry.timestamp
            cal.set(Calendar.HOUR_OF_DAY, 0)
            cal.set(Calendar.MINUTE, 0)
            cal.set(Calendar.SECOND, 0)
            cal.set(Calendar.MILLISECOND, 0)
            cal.time
        }.mapValues { (_, dayEntries) ->
            dayEntries.sumOf { it.getAmountInOz().toDouble() }.toFloat()
        }
    }
}