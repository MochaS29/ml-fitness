package com.mochasmindlab.mlhealth.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mochasmindlab.mlhealth.utils.DemoDataGenerator
import com.mochasmindlab.mlhealth.utils.PreferencesManager
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class SettingsViewModel @Inject constructor(
    private val preferencesManager: PreferencesManager,
    private val demoDataGenerator: DemoDataGenerator
) : ViewModel() {

    data class SettingsUiState(
        val isDarkMode: Boolean = false,
        val notificationsEnabled: Boolean = true,
        val waterReminders: Boolean = true,
        val mealReminders: Boolean = true,
        val exerciseReminders: Boolean = false,
        val isGeneratingData: Boolean = false,
        val dataGenerationComplete: Boolean = false,
        val errorMessage: String? = null
    )

    private val _uiState = MutableStateFlow(SettingsUiState())
    val uiState: StateFlow<SettingsUiState> = _uiState.asStateFlow()

    init {
        loadPreferences()
    }

    private fun loadPreferences() {
        viewModelScope.launch {
            launch {
                preferencesManager.notificationsEnabled.collect { enabled ->
                    _uiState.value = _uiState.value.copy(notificationsEnabled = enabled)
                }
            }
            launch {
                preferencesManager.waterReminderEnabled.collect { enabled ->
                    _uiState.value = _uiState.value.copy(waterReminders = enabled)
                }
            }
            launch {
                preferencesManager.mealReminderEnabled.collect { enabled ->
                    _uiState.value = _uiState.value.copy(mealReminders = enabled)
                }
            }
            launch {
                preferencesManager.exerciseReminderEnabled.collect { enabled ->
                    _uiState.value = _uiState.value.copy(exerciseReminders = enabled)
                }
            }
        }
    }

    fun toggleDarkMode() {
        _uiState.value = _uiState.value.copy(isDarkMode = !_uiState.value.isDarkMode)
        // TODO: Persist dark mode preference
    }

    fun toggleNotifications() {
        viewModelScope.launch {
            val newState = !_uiState.value.notificationsEnabled
            preferencesManager.setNotificationsEnabled(newState)
            _uiState.value = _uiState.value.copy(notificationsEnabled = newState)
        }
    }

    fun toggleWaterReminders() {
        viewModelScope.launch {
            val newState = !_uiState.value.waterReminders
            preferencesManager.setWaterReminderEnabled(newState)
            _uiState.value = _uiState.value.copy(waterReminders = newState)
        }
    }

    fun toggleMealReminders() {
        viewModelScope.launch {
            val newState = !_uiState.value.mealReminders
            preferencesManager.setMealReminderEnabled(newState)
            _uiState.value = _uiState.value.copy(mealReminders = newState)
        }
    }

    fun toggleExerciseReminders() {
        viewModelScope.launch {
            val newState = !_uiState.value.exerciseReminders
            preferencesManager.setExerciseReminderEnabled(newState)
            _uiState.value = _uiState.value.copy(exerciseReminders = newState)
        }
    }

    fun generateDemoData(days: Int = 30) {
        viewModelScope.launch {
            try {
                _uiState.value = _uiState.value.copy(
                    isGeneratingData = true,
                    dataGenerationComplete = false,
                    errorMessage = null
                )

                demoDataGenerator.generateDemoData(days)

                _uiState.value = _uiState.value.copy(
                    isGeneratingData = false,
                    dataGenerationComplete = true
                )
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    isGeneratingData = false,
                    errorMessage = "Failed to generate demo data: ${e.message}"
                )
            }
        }
    }

    fun clearAllData() {
        viewModelScope.launch {
            try {
                // TODO: Clear all database tables
                preferencesManager.clearAllPreferences()
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    errorMessage = "Failed to clear data: ${e.message}"
                )
            }
        }
    }

    fun clearErrorMessage() {
        _uiState.value = _uiState.value.copy(errorMessage = null)
    }
}