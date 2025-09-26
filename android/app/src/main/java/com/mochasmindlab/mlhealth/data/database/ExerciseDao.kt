package com.mochasmindlab.mlhealth.data.database

import androidx.room.*
import com.mochasmindlab.mlhealth.data.models.ExerciseEntry
import kotlinx.coroutines.flow.Flow
import java.time.LocalDate

@Dao
interface ExerciseDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertExercise(exercise: ExerciseEntry): Long
    
    @Update
    suspend fun updateExercise(exercise: ExerciseEntry)
    
    @Query("DELETE FROM exercise_entries WHERE id = :id")
    suspend fun deleteExercise(id: Long)
    
    @Query("SELECT * FROM exercise_entries ORDER BY date DESC, timestamp DESC")
    fun getAllExercises(): Flow<List<ExerciseEntry>>
    
    @Query("SELECT * FROM exercise_entries WHERE date = :date ORDER BY timestamp DESC")
    fun getExercisesForDate(date: LocalDate): Flow<List<ExerciseEntry>>
    
    @Query("SELECT * FROM exercise_entries WHERE date BETWEEN :startDate AND :endDate ORDER BY date DESC")
    fun getExercisesBetweenDates(startDate: LocalDate, endDate: LocalDate): Flow<List<ExerciseEntry>>
    
    @Query("SELECT SUM(minutes) FROM exercise_entries WHERE date = :date")
    suspend fun getTotalMinutesForDate(date: LocalDate): Int?
    
    @Query("SELECT SUM(caloriesBurned) FROM exercise_entries WHERE date = :date")
    suspend fun getTotalCaloriesForDate(date: LocalDate): Int?
    
    @Query("SELECT * FROM exercise_entries WHERE id = :id")
    fun getExerciseById(id: Long): Flow<ExerciseEntry?>
    
    @Query("DELETE FROM exercise_entries")
    suspend fun deleteAllExercises()
}