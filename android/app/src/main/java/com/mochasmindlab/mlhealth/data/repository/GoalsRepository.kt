package com.mochasmindlab.mlhealth.data.repository

import com.mochasmindlab.mlhealth.data.database.GoalsDao
import com.mochasmindlab.mlhealth.data.models.Goal
import com.mochasmindlab.mlhealth.data.models.GoalType
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.first
import java.time.LocalDate
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class GoalsRepository @Inject constructor(
    private val goalsDao: GoalsDao
) {
    suspend fun insertGoal(goal: Goal) = goalsDao.insertGoal(goal)
    
    suspend fun updateGoal(goal: Goal) = goalsDao.updateGoal(goal)
    
    suspend fun deleteGoal(id: Long) = goalsDao.deleteGoal(id)
    
    fun getAllGoals(): Flow<List<Goal>> = goalsDao.getAllGoals()
    
    fun getActiveGoals(): Flow<List<Goal>> = goalsDao.getActiveGoals()
    
    fun getCompletedGoals(): Flow<List<Goal>> = goalsDao.getCompletedGoals()
    
    fun getGoalById(id: Long): Flow<Goal?> = goalsDao.getGoalById(id)
    
    fun getGoalsByType(type: GoalType): Flow<List<Goal>> = goalsDao.getGoalsByType(type)
    
    suspend fun updateGoalProgress(goalId: Long, currentValue: Float) {
        val goal = goalsDao.getGoalByIdDirect(goalId)
        goal?.let {
            val progress = ((currentValue / it.targetValue) * 100).coerceIn(0f, 100f).toInt()
            val updatedGoal = it.copy(
                currentValue = currentValue,
                progress = progress,
                isCompleted = progress >= 100,
                completedDate = if (progress >= 100) LocalDate.now() else null
            )
            goalsDao.updateGoal(updatedGoal)
        }
    }
    
    suspend fun markGoalComplete(goalId: Long) {
        val goal = goalsDao.getGoalByIdDirect(goalId)
        goal?.let {
            val updatedGoal = it.copy(
                isCompleted = true,
                completedDate = LocalDate.now(),
                progress = 100,
                isActive = false
            )
            goalsDao.updateGoal(updatedGoal)
        }
    }
    
    suspend fun reactivateGoal(goalId: Long, newDeadline: LocalDate) {
        val goal = goalsDao.getGoalByIdDirect(goalId)
        goal?.let {
            val updatedGoal = it.copy(
                isCompleted = false,
                completedDate = null,
                isActive = true,
                deadline = newDeadline,
                progress = 0,
                currentValue = 0f
            )
            goalsDao.updateGoal(updatedGoal)
        }
    }
    
    suspend fun getGoalStatistics(): Map<String, Int> {
        val allGoals = goalsDao.getAllGoals().first()
        val activeGoals = allGoals.filter { it.isActive }
        val completedGoals = allGoals.filter { it.isCompleted }
        val overdueGoals = activeGoals.filter { it.deadline < LocalDate.now() }
        
        return mapOf(
            "total" to allGoals.size,
            "active" to activeGoals.size,
            "completed" to completedGoals.size,
            "overdue" to overdueGoals.size
        )
    }
    
    suspend fun getUpcomingDeadlines(days: Int = 7): List<Goal> {
        val futureDate = LocalDate.now().plusDays(days.toLong())
        val activeGoals = goalsDao.getActiveGoals().first()
        return activeGoals.filter { 
            it.deadline <= futureDate && it.deadline >= LocalDate.now()
        }.sortedBy { it.deadline }
    }
}