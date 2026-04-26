package com.mochasmindlab.mlhealth.data.models

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

/**
 * In-memory representation of a meal plan loaded from a bundled diet JSON.
 * Mirrors iOS MealPlanType / WeeklyMealPlan / DailyMealPlan / Meal.
 */
data class DietPlan(
    val id: String,
    val name: String,
    val description: String,
    val benefits: List<String>,
    val restrictions: List<String>,
    val weeks: List<WeeklyMealPlan>
)

data class WeeklyMealPlan(
    val weekNumber: Int,
    val days: List<DailyMealPlan>
)

data class DailyMealPlan(
    val dayName: String,
    val breakfast: PlanRecipe,
    val lunch: PlanRecipe,
    val dinner: PlanRecipe,
    val snack: PlanRecipe
) {
    val totalCalories: Int get() = breakfast.calories + lunch.calories + dinner.calories + snack.calories
    val totalProtein: Double get() = breakfast.protein + lunch.protein + dinner.protein + snack.protein
    val totalCarbs: Double get() = breakfast.carbs + lunch.carbs + dinner.carbs + snack.carbs
    val totalFat: Double get() = breakfast.fat + lunch.fat + dinner.fat + snack.fat
}

data class PlanRecipe(
    val id: String,
    val name: String,
    val description: String,
    val calories: Int,
    val protein: Double,
    val carbs: Double,
    val fat: Double,
    val fiber: Double,
    val prepTime: Int,
    val cookTime: Int,
    val ingredients: List<String>,
    val instructions: List<String>,
    val tags: List<String>
) {
    val totalTime: Int get() = prepTime + cookTime
}

// JSON DTOs — match the schema of bundled meal plan files exactly.

@Serializable
internal data class MealPlanJson(
    @SerialName("dietType") val dietType: String,
    @SerialName("displayName") val displayName: String,
    @SerialName("description") val description: String,
    @SerialName("benefits") val benefits: List<String> = emptyList(),
    @SerialName("restrictions") val restrictions: List<String> = emptyList(),
    @SerialName("meals") val meals: Map<String, PlanRecipeJson>,
    @SerialName("weeks") val weeks: List<WeekJson> = emptyList()
)

@Serializable
internal data class PlanRecipeJson(
    val name: String,
    val description: String = "",
    val calories: Int,
    val protein: Double,
    val carbs: Double,
    val fat: Double,
    val fiber: Double = 0.0,
    val prepTime: Int = 0,
    val cookTime: Int = 0,
    val ingredients: List<String> = emptyList(),
    val instructions: List<String> = emptyList(),
    val tags: List<String> = emptyList()
)

@Serializable
internal data class WeekJson(
    val weekNumber: Int,
    val days: List<DayScheduleJson>
)

@Serializable
internal data class DayScheduleJson(
    val day: String,
    val breakfast: String,
    val lunch: String,
    val dinner: String,
    val snack: String
)
