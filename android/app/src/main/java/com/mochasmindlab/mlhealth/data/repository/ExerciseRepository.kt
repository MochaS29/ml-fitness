package com.mochasmindlab.mlhealth.data.repository

import com.mochasmindlab.mlhealth.data.database.ExerciseDao
import com.mochasmindlab.mlhealth.data.models.ExerciseEntry
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.first
import java.time.LocalDate
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class ExerciseRepository @Inject constructor(
    private val exerciseDao: ExerciseDao
) {
    suspend fun insertExercise(exercise: ExerciseEntry) = exerciseDao.insertExercise(exercise)
    
    suspend fun updateExercise(exercise: ExerciseEntry) = exerciseDao.updateExercise(exercise)
    
    suspend fun deleteExercise(id: Long) = exerciseDao.deleteExercise(id)
    
    fun getAllExercises(): Flow<List<ExerciseEntry>> = exerciseDao.getAllExercises()
    
    fun getExercisesForDate(date: LocalDate): Flow<List<ExerciseEntry>> = 
        exerciseDao.getExercisesForDate(date)
    
    fun getExercisesBetweenDates(startDate: LocalDate, endDate: LocalDate): Flow<List<ExerciseEntry>> =
        exerciseDao.getExercisesBetweenDates(startDate, endDate)
    
    suspend fun getTotalMinutesForDate(date: LocalDate): Int =
        exerciseDao.getTotalMinutesForDate(date) ?: 0
    
    suspend fun getTotalCaloriesForDate(date: LocalDate): Int =
        exerciseDao.getTotalCaloriesForDate(date) ?: 0
    
    fun getExerciseById(id: Long): Flow<ExerciseEntry?> = exerciseDao.getExerciseById(id)
    
    suspend fun getWeeklyStats(startDate: LocalDate): Map<LocalDate, Int> {
        val endDate = startDate.plusDays(6)
        val exercises = exerciseDao.getExercisesBetweenDates(startDate, endDate).first()
        
        return (0..6).associate { dayOffset ->
            val date = startDate.plusDays(dayOffset.toLong())
            val minutes = exercises.filter { it.date == date }.sumOf { it.minutes }
            date to minutes
        }
    }
    
    suspend fun getMonthlyStats(month: LocalDate): Map<String, Float> {
        val startDate = month.withDayOfMonth(1)
        val endDate = month.withDayOfMonth(month.lengthOfMonth())
        val exercises = exerciseDao.getExercisesBetweenDates(startDate, endDate).first()
        
        val totalMinutes = exercises.sumOf { it.minutes }
        val totalCalories = exercises.sumOf { it.caloriesBurned }
        val totalWorkouts = exercises.size
        val averageMinutesPerWorkout = if (totalWorkouts > 0) totalMinutes.toFloat() / totalWorkouts else 0f
        
        return mapOf(
            "totalMinutes" to totalMinutes.toFloat(),
            "totalCalories" to totalCalories.toFloat(),
            "totalWorkouts" to totalWorkouts.toFloat(),
            "averageMinutesPerWorkout" to averageMinutesPerWorkout
        )
    }
}