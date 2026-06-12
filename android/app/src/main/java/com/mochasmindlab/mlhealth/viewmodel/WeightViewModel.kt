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

    // Rolling time-range selector for the progress chart (mirrors iOS weight
    // range picker). ALL shows the full history.
    private val _selectedRange = MutableStateFlow(WeightRange.MONTH)
    val selectedRange: StateFlow<WeightRange> = _selectedRange.asStateFlow()

    /** History filtered to the selected rolling window, newest-first. */
    val rangedHistory: StateFlow<List<WeightEntry>> =
        combine(_weightHistory, _selectedRange) { history, range ->
            val days = range.days ?: return@combine history
            val cutoff = Date.from(
                LocalDate.now().minusDays(days.toLong())
                    .atStartOfDay(ZoneId.systemDefault()).toInstant()
            )
            history.filter { it.date >= cutoff }
        }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), emptyList())

    fun setRange(range: WeightRange) {
        _selectedRange.value = range
    }

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
                    // Fall back to the oldest logged weight as the "starting"
                    // value when onboarding's USER_WEIGHT is missing. Without
                    // this, the Weight Tracking summary shows Start: 0 lbs and
                    // the "To Lose / To Gain" calc inverts (167 → 0 reads as
                    // gain). loadGoals() may override with a real onboarding
                    // value if one exists.
                    if (_startingWeight.value <= 0.0) {
                        _startingWeight.value = entries.last().weight
                    }

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

        // Auto-calculate BMI from current weight + stored height. Read height
        // via the individual flow so we don't depend on the full userProfile
        // aggregate (which only emits when USER_NAME is set). Weight stored in
        // pounds → convert to kg before applying the standard BMI formula
        // (kg / m²). When height isn't set, leave BMI at 0 and let the UI hide
        // it rather than show nonsense.
        viewModelScope.launch {
            combine(
                _currentWeight,
                preferencesManager.userHeight
            ) { weightLbs, heightCm ->
                if (heightCm > 0 && weightLbs > 0) {
                    val weightKg = weightLbs * 0.453592
                    val heightM = heightCm / 100.0
                    val bmiValue = weightKg / (heightM * heightM)
                    _bmi.value = bmiValue
                    _bmiCategory.value = when {
                        bmiValue < 18.5 -> "Underweight"
                        bmiValue < 25 -> "Normal"
                        bmiValue < 30 -> "Overweight"
                        else -> "Obese"
                    }
                } else {
                    _bmi.value = 0.0
                    _bmiCategory.value = ""
                }
            }.collect()
        }
    }

    private fun loadGoals() {
        // Read body-metric fields individually instead of via the userProfile
        // aggregate flow — that flow only emits when USER_NAME is set, which
        // would silently break this screen for anyone who hasn't completed
        // onboarding even after they set a goal weight from the Goals page.
        viewModelScope.launch {
            preferencesManager.userTargetWeight.collect { target ->
                _goalWeight.value = target.toDouble()
            }
        }
        viewModelScope.launch {
            preferencesManager.userWeight.collect { starting ->
                _startingWeight.value = starting.toDouble()
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

/** Rolling windows for the weight progress chart. [days] = null means all time. */
enum class WeightRange(val label: String, val days: Int?) {
    WEEK("7D", 7),
    MONTH("30D", 30),
    QUARTER("90D", 90),
    ALL("All", null)
}