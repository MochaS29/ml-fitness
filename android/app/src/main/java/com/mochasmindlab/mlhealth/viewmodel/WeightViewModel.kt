package com.mochasmindlab.mlhealth.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mochasmindlab.mlhealth.data.entities.WeightEntry
import com.mochasmindlab.mlhealth.data.repository.WeightRepository
import com.mochasmindlab.mlhealth.di.ApplicationScope
import com.mochasmindlab.mlhealth.services.HealthConnectManager
import com.mochasmindlab.mlhealth.utils.PreferencesManager
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import java.time.LocalDate
import java.util.Calendar
import java.util.Date
import java.time.ZoneId
import java.util.UUID
import javax.inject.Inject

@HiltViewModel
class WeightViewModel @Inject constructor(
    private val weightRepository: WeightRepository,
    private val preferencesManager: PreferencesManager,
    private val healthConnectManager: HealthConnectManager,
    @ApplicationScope private val appScope: CoroutineScope
) : ViewModel() {

    private val _currentWeight = MutableStateFlow(0.0)
    val currentWeight: StateFlow<Double> = _currentWeight.asStateFlow()

    private val _goalWeight = MutableStateFlow(0.0)
    val goalWeight: StateFlow<Double> = _goalWeight.asStateFlow()

    private val _startingWeight = MutableStateFlow(0.0)
    val startingWeight: StateFlow<Double> = _startingWeight.asStateFlow()

    private val _weightHistory = MutableStateFlow<List<WeightEntry>>(emptyList())
    val weightHistory: StateFlow<List<WeightEntry>> = _weightHistory.asStateFlow()

    private val _weeklyAverage = MutableStateFlow(0.0)
    val weeklyAverage: StateFlow<Double> = _weeklyAverage.asStateFlow()

    private val _monthlyProgress = MutableStateFlow(0.0)
    val monthlyProgress: StateFlow<Double> = _monthlyProgress.asStateFlow()

    private val _bmi = MutableStateFlow(0.0)
    val bmi: StateFlow<Double> = _bmi.asStateFlow()

    private val _bmiCategory = MutableStateFlow("")
    val bmiCategory: StateFlow<String> = _bmiCategory.asStateFlow()

    init {
        loadWeightData()
        loadGoals()
    }

    private fun loadWeightData() {
        viewModelScope.launch {
            // Load weight history
            weightRepository.getAllWeightEntries().collect { entries ->
                _weightHistory.value = entries

                if (entries.isNotEmpty()) {
                    _currentWeight.value = entries.first().weight

                    // Calculate weekly average
                    val weekAgo = Date.from(LocalDate.now().minusWeeks(1).atStartOfDay(ZoneId.systemDefault()).toInstant())
                    val weekEntries = entries.filter { it.date >= weekAgo }
                    _weeklyAverage.value = if (weekEntries.isNotEmpty()) {
                        weekEntries.map { it.weight }.average()
                    } else {
                        _currentWeight.value
                    }

                    // Calculate monthly progress
                    val monthAgo = Date.from(LocalDate.now().minusMonths(1).atStartOfDay(ZoneId.systemDefault()).toInstant())
                    val monthAgoEntry = entries.find { it.date <= monthAgo }
                    if (monthAgoEntry != null) {
                        _monthlyProgress.value = _currentWeight.value - monthAgoEntry.weight
                    }
                }
            }
        }

        // Load BMI
        viewModelScope.launch {
            combine(
                _currentWeight,
                preferencesManager.userProfile
            ) { weight, profile ->
                profile?.let {
                    val height = it.height
                    if (height > 0) {
                        val heightInMeters = height / 100
                        val bmiValue = weight / (heightInMeters * heightInMeters)
                        _bmi.value = bmiValue
                        _bmiCategory.value = when {
                            bmiValue < 18.5 -> "Underweight"
                            bmiValue < 25 -> "Normal"
                            bmiValue < 30 -> "Overweight"
                            else -> "Obese"
                        }
                    }
                }
            }.collect()
        }
    }

    private fun loadGoals() {
        viewModelScope.launch {
            preferencesManager.userProfile.collect { profile ->
                profile?.let {
                    _goalWeight.value = it.targetWeight.toDouble()
                    _startingWeight.value = it.weight.toDouble()
                }
            }
        }
    }

    fun addWeightEntry(weight: Double, notes: String, date: Date = Date()) {
        // Normalize to start-of-day so dashboard's getWeightOnDate / getLatestEntry
        // queries align across days. appScope outlives the dialog so the insert
        // isn't dropped if the screen recomposes.
        val startOfDay = Calendar.getInstance().apply {
            time = date
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }.time
        appScope.launch {
            weightRepository.insertWeightEntry(
                WeightEntry(weight = weight, date = startOfDay, notes = notes)
            )

            // Mirror to Health Connect when the user has granted write permission.
            // The user enters lbs, but HC stores kilograms. Fails silently if HC is
            // unavailable or not permitted — local entry above is still persisted.
            runCatching {
                if (healthConnectManager.hasAllPermissions()) {
                    val kg = weight * 0.45359237
                    healthConnectManager.writeWeightKg(
                        weight = kg,
                        time = startOfDay.toInstant()
                    )
                }
            }
        }
    }

    fun deleteWeightEntry(id: UUID) {
        viewModelScope.launch {
            weightRepository.deleteWeightEntry(id)
        }
    }
}