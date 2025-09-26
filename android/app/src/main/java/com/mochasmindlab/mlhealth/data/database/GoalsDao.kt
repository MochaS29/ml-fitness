package com.mochasmindlab.mlhealth.data.database

import androidx.room.*
import com.mochasmindlab.mlhealth.data.models.Goal
import com.mochasmindlab.mlhealth.data.models.GoalType
import kotlinx.coroutines.flow.Flow

@Dao
interface GoalsDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertGoal(goal: Goal): Long
    
    @Update
    suspend fun updateGoal(goal: Goal)
    
    @Query("DELETE FROM goals WHERE id = :id")
    suspend fun deleteGoal(id: Long)
    
    @Query("SELECT * FROM goals ORDER BY isActive DESC, deadline ASC")
    fun getAllGoals(): Flow<List<Goal>>
    
    @Query("SELECT * FROM goals WHERE isActive = 1 ORDER BY deadline ASC")
    fun getActiveGoals(): Flow<List<Goal>>
    
    @Query("SELECT * FROM goals WHERE isCompleted = 1 ORDER BY completedDate DESC")
    fun getCompletedGoals(): Flow<List<Goal>>
    
    @Query("SELECT * FROM goals WHERE id = :id")
    fun getGoalById(id: Long): Flow<Goal?>
    
    @Query("SELECT * FROM goals WHERE id = :id")
    suspend fun getGoalByIdDirect(id: Long): Goal?
    
    @Query("SELECT * FROM goals WHERE type = :type ORDER BY isActive DESC, deadline ASC")
    fun getGoalsByType(type: GoalType): Flow<List<Goal>>
    
    @Query("DELETE FROM goals")
    suspend fun deleteAllGoals()
}