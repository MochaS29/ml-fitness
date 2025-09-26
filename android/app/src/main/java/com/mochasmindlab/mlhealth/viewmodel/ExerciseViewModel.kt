package com.mochasmindlab.mlhealth.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mochasmindlab.mlhealth.data.models.ExerciseEntry
import com.mochasmindlab.mlhealth.data.repository.ExerciseRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import java.time.DayOfWeek
import java.time.LocalDate
import java.time.temporal.TemporalAdjusters
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
            exerciseRepository.getExercisesForDate(date).collect { exercises ->
                _todayExercises.value = exercises
                _totalCaloriesBurned.value = exercises.sumOf { it.caloriesBurned }
                _totalMinutes.value = exercises.sumOf { it.minutes }
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
                val minutes = exerciseRepository.getTotalMinutesForDate(date)
                stats.add(dayName to minutes)
            }
            _weeklyStats.value = stats
        }
    }

    fun quickAddExercise(name: String, duration: Int, calories: Int) {
        viewModelScope.launch {
            val entry = ExerciseEntry(
                name = name,
                minutes = duration,
                caloriesBurned = calories,
                date = LocalDate.now(),
                type = "Other"
            )
            exerciseRepository.insertExercise(entry)
            loadTodayExercises()
            loadWeeklyStats()
        }
    }

    fun deleteExercise(id: Long) {
        viewModelScope.launch {
            exerciseRepository.deleteExercise(id)
            loadTodayExercises()
            loadWeeklyStats()
        }
    }
}