package com.mochasmindlab.mlhealth.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mochasmindlab.mlhealth.data.entities.ExerciseEntry
import com.mochasmindlab.mlhealth.data.repository.ExerciseRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import java.time.DayOfWeek
import java.time.LocalDate
import java.time.temporal.TemporalAdjusters
import java.time.ZoneId
import java.util.Date
import java.util.Calendar
import javax.inject.Inject

@HiltViewModel
class ExerciseViewModel @Inject constructor(
    private val exerciseRepository: ExerciseRepository
) : ViewModel() {

    private val _todayExercises = MutableStateFlow<List<ExerciseEntry>>(emptyList())
    val todayExercises: StateFlow<List<ExerciseEntry>> = _todayExercises.asStateFlow()

    private val _totalCaloriesBurned = MutableStateFlow(0)
    val totalCaloriesBurned: StateFlow<Int> = _totalCaloriesBurned.asStateFlow()

    private val _totalMinutes = MutableStateFlow(0)
    val totalMinutes: StateFlow<Int> = _totalMinutes.asStateFlow()

    private val _weeklyStats = MutableStateFlow<List<Pair<String, Int>>>(emptyList())
    val weeklyStats: StateFlow<List<Pair<String, Int>>> = _weeklyStats.asStateFlow()

    init {
        loadTodayExercises()
        loadWeeklyStats()
    }

    fun loadExercisesForDate(date: LocalDate) {
        viewModelScope.launch {
            val dateAsDate = Date.from(date.atStartOfDay(ZoneId.systemDefault()).toInstant())
            exerciseRepository.getExercisesForDate(dateAsDate).collect { exercises ->
                _todayExercises.value = exercises
                _totalCaloriesBurned.value = exercises.sumOf { it.caloriesBurned.toInt() }
                _totalMinutes.value = exercises.sumOf { it.duration }
            }
        }
    }

    private fun loadTodayExercises() {
        loadExercisesForDate(LocalDate.now())
    }

    private fun loadWeeklyStats() {
        viewModelScope.launch {
            val today = LocalDate.now()
            val startOfWeek = today.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY))

            val stats = mutableListOf<Pair<String, Int>>()
            for (i in 0..6) {
                val date = startOfWeek.plusDays(i.toLong())
                val dayName = date.dayOfWeek.name.take(3)
                val dateAsDate = Date.from(date.atStartOfDay(ZoneId.systemDefault()).toInstant())
                val minutes = exerciseRepository.getTotalMinutesForDate(dateAsDate) ?: 0
                stats.add(dayName to minutes)
            }
            _weeklyStats.value = stats
        }
    }

    fun quickAddExercise(name: String, duration: Int, calories: Int) {
        viewModelScope.launch {
            val entry = ExerciseEntry(
                name = name,
                category = "Other",
                type = "Other",
                date = Date(),
                duration = duration,
                caloriesBurned = calories.toDouble()
            )
            exerciseRepository.insertExercise(entry)
            loadTodayExercises()
            loadWeeklyStats()
        }
    }

    fun deleteExercise(exercise: ExerciseEntry) {
        viewModelScope.launch {
            exerciseRepository.deleteExercise(exercise)
            loadTodayExercises()
            loadWeeklyStats()
        }
    }
}