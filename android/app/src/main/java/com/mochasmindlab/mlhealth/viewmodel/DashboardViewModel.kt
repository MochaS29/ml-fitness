package com.mochasmindlab.mlhealth.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mochasmindlab.mlhealth.data.database.MLFitnessDatabase
import com.mochasmindlab.mlhealth.data.entities.*
import com.mochasmindlab.mlhealth.data.models.Achievement
import com.mochasmindlab.mlhealth.data.models.AchievementType
import com.mochasmindlab.mlhealth.services.HealthConnectManager
import com.mochasmindlab.mlhealth.services.LoggingStreakManager
import com.mochasmindlab.mlhealth.utils.PreferencesManager
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch
import java.time.LocalDate
import java.util.*
import javax.inject.Inject

@HiltViewModel
class DashboardViewModel @Inject constructor(
    private val database: MLFitnessDatabase,
    private val healthConnectManager: HealthConnectManager,
    private val preferencesManager: PreferencesManager,
    val streakManager: LoggingStreakManager
) : ViewModel() {
    
    private val _uiState = MutableStateFlow(DashboardUiState())
    val uiState: StateFlow<DashboardUiState> = _uiState.asStateFlow()
    
    private val _aiInsights = MutableStateFlow<List<AIInsight>>(emptyList())
    val aiInsights: StateFlow<List<AIInsight>> = _aiInsights.asStateFlow()
    
    init {
        loadDashboardData()
        generateAIInsights()
    }
    
    private fun loadDashboardData() {
        viewModelScope.launch {
            try {
                // Use start-of-day so the SQL `WHERE date = :date` exact-match
                // queries line up with FoodEntry rows whose `date` column was
                // also normalized to start-of-day (in SampleDataGenerator and
                // the diary log flows).
                val today = Calendar.getInstance().apply {
                    set(Calendar.HOUR_OF_DAY, 0)
                    set(Calendar.MINUTE, 0)
                    set(Calendar.SECOND, 0)
                    set(Calendar.MILLISECOND, 0)
                }.time
                val yesterday = Calendar.getInstance().apply {
                    time = today
                    add(Calendar.DAY_OF_YEAR, -1)
                }.time

                // Supplements that record macros (collagen, whey, fibre powders)
                // contribute to today's totals, mirroring iOS DiaryViewModel.
                val supplementsToday = try {
                    database.supplementDao().getEntriesForDay(today)
                } catch (e: Exception) {
                    emptyList()
                }

                // Load calories and macros - these might be null initially
                val totalCalories = (try {
                    database.foodDao().getTotalCaloriesForDate(today) ?: 0.0
                } catch (e: Exception) {
                    0.0
                }) + suppMacro(supplementsToday, "calories", "energy")

                val totalProtein = (try {
                    database.foodDao().getTotalProteinForDate(today) ?: 0.0
                } catch (e: Exception) {
                    0.0
                }) + suppMacro(supplementsToday, "protein")

                val totalCarbs = (try {
                    database.foodDao().getTotalCarbsForDate(today) ?: 0.0
                } catch (e: Exception) {
                    0.0
                }) + suppMacro(supplementsToday, "carbs", "carbohydrate", "carbohydrate, by difference", "total carbohydrate")

                val totalFat = (try {
                    database.foodDao().getTotalFatForDate(today) ?: 0.0
                } catch (e: Exception) {
                    0.0
                }) + suppMacro(supplementsToday, "fat", "total fat", "total lipid (fat)")

                // Load water
                val waterIntake = try {
                    database.waterDao().getTotalForDate(today) ?: 0.0
                } catch (e: Exception) {
                    0.0
                }

                // Load exercise
                val exerciseMinutes = try {
                    database.exerciseDao().getTotalMinutesForDate(today) ?: 0
                } catch (e: Exception) {
                    0
                }

                val manualBurn = try {
                    database.exerciseDao().getTotalCaloriesBurnedForDate(today) ?: 0.0
                } catch (e: Exception) {
                    0.0
                }

                // Load weight
                val latestWeight = try {
                    database.weightDao().getLatestEntry()
                } catch (e: Exception) {
                    null
                }

                // Read today's steps from Health Connect.
                // Falls back to 0 gracefully if HC is unavailable or not permitted.
                val todaySteps = try {
                    healthConnectManager.readStepsToday().toInt()
                } catch (e: Exception) {
                    0
                }

                // Burned tile: prefer the highest of manual exercise logging,
                // Health Connect active energy, and a weight-adjusted step
                // estimate. Mirrors iOS DiaryViewModel.refreshActiveEnergy — the
                // step fallback matters because HC often has no active-energy
                // samples even with thousands of steps logged.
                val activeEnergy = try {
                    healthConnectManager.readActiveCaloriesToday()
                } catch (e: Exception) {
                    0.0
                }
                val stepEstimate = todaySteps * caloriesPerStep(latestWeight?.weight ?: 0.0)
                val exerciseCalories = maxOf(manualBurn, activeEnergy, stepEstimate).toInt()

                // Weight trend: signed delta vs the previous logged entry.
                val recentWeights = try {
                    database.weightDao().getRecentEntries(2)
                } catch (e: Exception) {
                    emptyList()
                }
                val weightChange = if (recentWeights.size >= 2) {
                    (recentWeights[0].weight - recentWeights[1].weight).toFloat()
                } else 0f

                // Day-over-day signed-percent trends (real historical data).
                val yesterdayCalories = try {
                    database.foodDao().getTotalCaloriesForDate(yesterday) ?: 0.0
                } catch (e: Exception) { 0.0 }
                val yesterdaySteps = try {
                    healthConnectManager.readStepsForDate(LocalDate.now().minusDays(1)).toInt()
                } catch (e: Exception) { 0 }
                val yesterdayBurn = try {
                    database.exerciseDao().getTotalCaloriesBurnedForDate(yesterday) ?: 0.0
                } catch (e: Exception) { 0.0 }

                // User-configurable goals (set via the Goals screen → mirrored to DataStore).
                val calorieGoal = try { preferencesManager.dailyCalorieGoal.first() } catch (e: Exception) { 2200 }
                val waterGoal = try { preferencesManager.dailyWaterGoal.first() } catch (e: Exception) { 8 }
                val exerciseGoal = try { preferencesManager.dailyExerciseGoal.first() } catch (e: Exception) { 60 }

                _uiState.value = DashboardUiState(
                    userName = "You", // Default name until loaded from preferences
                    caloriesConsumed = totalCalories.toInt(),
                    calorieGoal = calorieGoal,
                    proteinGrams = totalProtein.toFloat(),
                    carbsGrams = totalCarbs.toFloat(),
                    fatGrams = totalFat.toFloat(),
                    waterCups = (waterIntake / 8).toInt(), // Convert oz to cups
                    waterGoal = waterGoal,
                    exerciseMinutes = exerciseMinutes,
                    exerciseGoal = exerciseGoal,
                    exerciseCalories = exerciseCalories,
                    currentWeight = latestWeight?.weight ?: 70.0,
                    weightChange = weightChange,
                    lastWeightDate = "Today",
                    steps = todaySteps,
                    caloriesTrend = trendPercent(totalCalories, yesterdayCalories),
                    stepsTrend = trendPercent(todaySteps.toDouble(), yesterdaySteps.toDouble()),
                    burnedTrend = trendPercent(exerciseCalories.toDouble(), yesterdayBurn),
                    selectedPeriod = DashboardPeriod.DAY
                )
            } catch (e: Exception) {
                // Handle any database errors gracefully
                _uiState.value = DashboardUiState(
                    userName = "You",
                    caloriesConsumed = 0,
                    calorieGoal = 2200,
                    waterCups = 0,
                    waterGoal = 8,
                    exerciseMinutes = 0,
                    exerciseGoal = 60,
                    currentWeight = 70.0,
                    selectedPeriod = DashboardPeriod.DAY
                )
            }
        }
    }
    
    private fun generateAIInsights() {
        viewModelScope.launch {
            try {
                val insights = mutableListOf<AIInsight>()
                
                // Check hydration
                val waterIntake = try {
                    database.waterDao().getTotalForDate(Date()) ?: 0.0
                } catch (e: Exception) {
                    0.0
                }
                
                if (waterIntake < 64) { // Less than 8 cups (64 oz)
                    val percentage = if (waterIntake > 0) ((waterIntake / 64) * 100).toInt() else 0
                    insights.add(
                        AIInsight(
                            id = UUID.randomUUID().toString(),
                            title = "Hydration Alert",
                            description = "You're ${100 - percentage}% below your daily water goal",
                            type = InsightType.HYDRATION,
                            priority = if (percentage < 30) InsightPriority.HIGH else InsightPriority.MEDIUM
                        )
                    )
                }
                
                // Check calorie balance
                val calories = try {
                    database.foodDao().getTotalCaloriesForDate(Date()) ?: 0.0
                } catch (e: Exception) {
                    0.0
                }
                
                if (calories > 2200) {
                    insights.add(
                        AIInsight(
                            id = UUID.randomUUID().toString(),
                            title = "Calorie Alert",
                            description = "You've exceeded your daily calorie goal",
                            type = InsightType.NUTRITION,
                            priority = InsightPriority.MEDIUM
                        )
                    )
                }
                
                // Check exercise
                val exerciseMinutes = try {
                    database.exerciseDao().getTotalMinutesForDate(Date()) ?: 0
                } catch (e: Exception) {
                    0
                }
                
                if (exerciseMinutes < 30) {
                    insights.add(
                        AIInsight(
                            id = UUID.randomUUID().toString(),
                            title = "Movement Reminder",
                            description = "Time to get moving! Only ${30 - exerciseMinutes} minutes to reach your goal",
                            type = InsightType.EXERCISE,
                            priority = InsightPriority.LOW
                        )
                    )
                }
                
                _aiInsights.value = insights
            } catch (e: Exception) {
                // If there's an error, just set empty insights
                _aiInsights.value = emptyList()
            }
        }
    }
    
    fun selectPeriod(period: DashboardPeriod) {
        _uiState.value = _uiState.value.copy(selectedPeriod = period)
        // Reload data for selected period
        when (period) {
            DashboardPeriod.DAY -> loadDashboardData()
            DashboardPeriod.WEEK -> loadWeekData()
            DashboardPeriod.MONTH -> loadMonthData()
        }
    }
    
    private fun loadWeekData() {
        viewModelScope.launch {
            // TODO: Implement week data aggregation
        }
    }
    
    private fun loadMonthData() {
        viewModelScope.launch {
            // TODO: Implement month data aggregation
        }
    }
    
    fun refreshData() {
        loadDashboardData()
        generateAIInsights()
    }

    /**
     * Sums a single macro across supplement entries, matching any alias
     * case-insensitively (USDA/Nutritionix names vary). Mirrors iOS suppSum.
     */
    private fun suppMacro(supplements: List<SupplementEntry>, vararg aliases: String): Double {
        val wanted = aliases.map { it.lowercase() }.toSet()
        return supplements.sumOf { sup ->
            sup.nutrients.entries
                .filter { it.key.trim().lowercase() in wanted }
                .sumOf { it.value }
        }
    }

    /**
     * Calories per step, weighted by the user's most recent logged weight.
     * Derived from the standard walking formula (≈ weight_lbs × 0.00027).
     * Falls back to 0.04 (≈ 148 lb adult) when no weight has been logged.
     * Mirrors iOS DiaryViewModel.caloriesPerStep.
     */
    private fun caloriesPerStep(weightLbs: Double): Double =
        if (weightLbs > 0) weightLbs * 0.00027 else 0.04

    /**
     * Signed day-over-day percent change. Returns null when there's no prior
     * value to compare against (so the card hides the trend rather than showing
     * a meaningless +100%).
     */
    private fun trendPercent(today: Double, previous: Double): Float? =
        if (previous > 0.0) (((today - previous) / previous) * 100.0).toFloat() else null
}

data class DashboardUiState(
    val userName: String = "",
    val caloriesConsumed: Int = 0,
    val calorieGoal: Int = 2200,
    val proteinGrams: Float = 0f,
    val carbsGrams: Float = 0f,
    val fatGrams: Float = 0f,
    val waterCups: Int = 0,
    val waterGoal: Int = 8,
    val exerciseMinutes: Int = 0,
    val exerciseGoal: Int = 60,
    val exerciseCalories: Int = 0,
    val currentWeight: Double = 0.0,
    val weightChange: Float = 0f,
    val lastWeightDate: String = "Today",
    val steps: Int = 0,
    // Signed day-over-day percent trends (null = no prior data, hide the trend).
    val caloriesTrend: Float? = null,
    val stepsTrend: Float? = null,
    val burnedTrend: Float? = null,
    val selectedPeriod: DashboardPeriod = DashboardPeriod.DAY,
    val isLoading: Boolean = false
)

enum class DashboardPeriod {
    DAY, WEEK, MONTH
}

data class AIInsight(
    val id: String,
    val title: String,
    val description: String,
    val type: InsightType,
    val priority: InsightPriority
)

enum class InsightType {
    NUTRITION, HYDRATION, EXERCISE, WEIGHT, SLEEP, GENERAL
}

enum class InsightPriority {
    LOW, MEDIUM, HIGH
}