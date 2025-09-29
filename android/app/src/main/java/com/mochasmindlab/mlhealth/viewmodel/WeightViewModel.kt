package com.mochasmindlab.mlhealth.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mochasmindlab.mlhealth.data.entities.WeightEntry
import com.mochasmindlab.mlhealth.data.repository.WeightRepository
import com.mochasmindlab.mlhealth.utils.PreferencesManager
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import java.time.LocalDate
import javax.inject.Inject

@HiltViewModel
class WeightViewModel @Inject constructor(
    private val weightRepository: WeightRepository,
    private val preferencesManager: PreferencesManager
) : ViewModel() {

    private val _currentWeight = MutableStateFlow(0f)
    val currentWeight: StateFlow<Float> = _currentWeight.asStateFlow()

    private val _goalWeight = MutableStateFlow(0f)
    val goalWeight: StateFlow<Float> = _goalWeight.asStateFlow()

    private val _startingWeight = MutableStateFlow(0f)
    val startingWeight: StateFlow<Float> = _startingWeight.asStateFlow()

    private val _weightHistory = MutableStateFlow<List<WeightEntry>>(emptyList())
    val weightHistory: StateFlow<List<WeightEntry>> = _weightHistory.asStateFlow()

    private val _weeklyAverage = MutableStateFlow(0f)
    val weeklyAverage: StateFlow<Float> = _weeklyAverage.asStateFlow()

    private val _monthlyProgress = MutableStateFlow(0f)
    val monthlyProgress: StateFlow<Float> = _monthlyProgress.asStateFlow()

    private val _bmi = MutableStateFlow(0f)
    val bmi: StateFlow<Float> = _bmi.asStateFlow()

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
                    val weekAgo = LocalDate.now().minusWeeks(1)
                    val weekEntries = entries.filter { it.date >= weekAgo }
                    _weeklyAverage.value = if (weekEntries.isNotEmpty()) {
                        weekEntries.map { it.weight }.average().toFloat()
                    } else {
                        _currentWeight.value
                    }

                    // Calculate monthly progress
                    val monthAgo = LocalDate.now().minusMonths(1)
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
                preferencesManager.userHeight
            ) { weight, height ->
                if (height > 0) {
                    val heightInMeters = height / 100
                    val bmiValue = weight / (heightInMeters * heightInMeters) * 703 / 2.205 // Convert lbs to kg
                    _bmi.value = bmiValue
                    _bmiCategory.value = when {
                        bmiValue < 18.5 -> "Underweight"
                        bmiValue < 25 -> "Normal"
                        bmiValue < 30 -> "Overweight"
                        else -> "Obese"
                    }
                }
            }.collect()
        }
    }

    private fun loadGoals() {
        viewModelScope.launch {
            preferencesManager.goalWeight.collect { weight ->
                _goalWeight.value = weight
            }
        }

        viewModelScope.launch {
            preferencesManager.startingWeight.collect { weight ->
                _startingWeight.value = weight
            }
        }
    }

    fun addWeightEntry(weight: Float, notes: String) {
        viewModelScope.launch {
            val entry = WeightEntry(
                weight = weight,
                date = LocalDate.now(),
                notes = notes
            )
            weightRepository.insertWeightEntry(entry)

            // Update current weight in preferences
            preferencesManager.setCurrentWeight(weight)

            // If this is the first entry, set as starting weight
            if (_weightHistory.value.size == 1) {
                preferencesManager.setStartingWeight(weight)
            }
        }
    }

    fun deleteWeightEntry(id: Long) {
        viewModelScope.launch {
            weightRepository.deleteWeightEntry(id)
        }
    }
}