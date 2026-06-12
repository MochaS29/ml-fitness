package com.mochasmindlab.mlhealth.data.database

import androidx.room.*
import com.mochasmindlab.mlhealth.data.entities.ExerciseEntry
import kotlinx.coroutines.flow.Flow
import java.util.*

@Dao
interface ExerciseDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertExercise(exercise: ExerciseEntry): Long

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(exercise: ExerciseEntry): Long

    @Update
    suspend fun updateExercise(exercise: ExerciseEntry)

    @Delete
    suspend fun deleteExercise(exercise: ExerciseEntry)

    @Query("DELETE FROM exercise_entries WHERE id = :id")
    suspend fun deleteExerciseById(id: UUID)

    @Query("SELECT * FROM exercise_entries ORDER BY date DESC, timestamp DESC")
    fun getAllExercises(): Flow<List<ExerciseEntry>>

    @Query("SELECT * FROM exercise_entries WHERE date BETWEEN :startDate AND :endDate ORDER BY date DESC, timestamp DESC")
    fun getExercisesBetweenDates(startDate: Date, endDate: Date): Flow<List<ExerciseEntry>>

    @Query("SELECT * FROM exercise_entries WHERE date = :date ORDER BY timestamp DESC")
    fun getExercisesForDate(date: Date): Flow<List<ExerciseEntry>>

    @Query("SELECT * FROM exercise_entries WHERE date = :date ORDER BY timestamp DESC")
    suspend fun getExercisesForDateOnce(date: Date): List<ExerciseEntry>

    @Query("SELECT SUM(duration) FROM exercise_entries WHERE date = :date")
    suspend fun getTotalMinutesForDate(date: Date): Int?

    @Query("SELECT SUM(caloriesBurned) FROM exercise_entries WHERE date = :date")
    suspend fun getTotalCaloriesBurnedForDate(date: Date): Double?

    @Query("DELETE FROM exercise_entries")
    suspend fun deleteAllExercises()

    @Query("SELECT * FROM exercise_entries WHERE category = :category ORDER BY date DESC")
    fun getExercisesByCategory(category: String): Flow<List<ExerciseEntry>>

    @Query("SELECT DISTINCT category FROM exercise_entries ORDER BY category ASC")
    suspend fun getAllCategories(): List<String>
}