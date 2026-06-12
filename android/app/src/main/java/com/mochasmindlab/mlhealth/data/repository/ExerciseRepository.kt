package com.mochasmindlab.mlhealth.data.repository

import com.mochasmindlab.mlhealth.data.database.ExerciseDao
import com.mochasmindlab.mlhealth.data.entities.ExerciseEntry
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.first
import java.util.*
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class ExerciseRepository @Inject constructor(
    private val exerciseDao: ExerciseDao
) {
    suspend fun insertExercise(exercise: ExerciseEntry) = exerciseDao.insertExercise(exercise)

    suspend fun updateExercise(exercise: ExerciseEntry) = exerciseDao.updateExercise(exercise)

    suspend fun deleteExercise(exercise: ExerciseEntry) = exerciseDao.deleteExercise(exercise)

    fun getAllExercises(): Flow<List<ExerciseEntry>> = exerciseDao.getAllExercises()

    fun getExercisesForDate(date: Date): Flow<List<ExerciseEntry>> =
        exerciseDao.getExercisesForDate(date)

    fun getExercisesBetweenDates(startDate: Date, endDate: Date): Flow<List<ExerciseEntry>> =
        exerciseDao.getExercisesBetweenDates(startDate, endDate)

    suspend fun getTotalMinutesForDate(date: Date): Int =
        exerciseDao.getTotalMinutesForDate(date) ?: 0

    suspend fun getTotalCaloriesBurnedForDate(date: Date): Double =
        exerciseDao.getTotalCaloriesBurnedForDate(date) ?: 0.0
}