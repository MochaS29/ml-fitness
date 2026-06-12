package com.mochasmindlab.mlhealth.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mochasmindlab.mlhealth.data.database.MLFitnessDatabase
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale
import javax.inject.Inject

@HiltViewModel
class ProgressReportsViewModel @Inject constructor(
    private val database: MLFitnessDatabase
) : ViewModel() {

    data class DayCalories(val label: String, val calories: Double)
    data class DayExercise(val label: String, val minutes: Int)
    data class WeightPoint(val label: String, val weight: Double)

    data class ReportsUiState(
        val isLoading: Boolean = true,
        val caloriesPerDay: List<DayCalories> = emptyList(),
        val exercisePerDay: List<DayExercise> = emptyList(),
        val weightPoints: List<WeightPoint> = emptyList(),
        val errorMessage: String? = null
    )

    private val _uiState = MutableStateFlow(ReportsUiState())
    val uiState: StateFlow<ReportsUiState> = _uiState.asStateFlow()

    private val dayLabelFormat = SimpleDateFormat("EEE", Locale.getDefault())   // Mon, Tue …
    private val dateFormat = SimpleDateFormat("MMM d", Locale.getDefault())

    init {
        loadLast7Days()
    }

    fun refresh() {
        loadLast7Days()
    }

    private fun loadLast7Days() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, errorMessage = null)
            try {
                val (calories, exercise, weights) = withContext(Dispatchers.IO) {
                    val cal = Calendar.getInstance()
                    // End of today
                    cal.set(Calendar.HOUR_OF_DAY, 23)
                    cal.set(Calendar.MINUTE, 59)
                    cal.set(Calendar.SECOND, 59)
                    val endDate = cal.time

                    // Earliest date: 6 days ago start of day
                    cal.add(Calendar.DAY_OF_MONTH, -6)
                    cal.set(Calendar.HOUR_OF_DAY, 0)
                    cal.set(Calendar.MINUTE, 0)
                    cal.set(Calendar.SECOND, 0)
                    val startDate = cal.time

                    // Build per-day date list (oldest → newest)
                    val days = mutableListOf<Date>()
                    val iter = Calendar.getInstance().apply { time = startDate }
                    repeat(7) {
                        days.add(iter.time)
                        iter.add(Calendar.DAY_OF_MONTH, 1)
                    }

                    val caloriesList = days.map { date ->
                        val dayStart = dayStart(date)
                        val label = dayLabelFormat.format(date)
                        val kcal = database.foodDao().getTotalCaloriesForDate(dayStart) ?: 0.0
                        DayCalories(label, kcal)
                    }

                    val exerciseList = days.map { date ->
                        val dayStart = dayStart(date)
                        val label = dayLabelFormat.format(date)
                        val mins = database.exerciseDao().getTotalMinutesForDate(dayStart) ?: 0
                        DayExercise(label, mins)
                    }

                    val weightEntries = database.weightDao().getEntriesInRange(startDate, endDate)
                    val weightList = weightEntries.map { entry ->
                        WeightPoint(dateFormat.format(entry.date), entry.weight)
                    }

                    Triple(caloriesList, exerciseList, weightList)
                }

                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    caloriesPerDay = calories,
                    exercisePerDay = exercise,
                    weightPoints = weights
                )
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    errorMessage = "Failed to load data: ${e.message}"
                )
            }
        }
    }

    /** Returns a Date with time zeroed out (midnight) for the given date. */
    private fun dayStart(date: Date): Date {
        val cal = Calendar.getInstance()
        cal.time = date
        cal.set(Calendar.HOUR_OF_DAY, 0)
        cal.set(Calendar.MINUTE, 0)
        cal.set(Calendar.SECOND, 0)
        cal.set(Calendar.MILLISECOND, 0)
        return cal.time
    }
}
