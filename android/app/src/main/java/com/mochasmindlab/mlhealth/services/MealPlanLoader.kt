package com.mochasmindlab.mlhealth.services

import android.content.Context
import com.mochasmindlab.mlhealth.data.models.DailyMealPlan
import com.mochasmindlab.mlhealth.data.models.DietPlan
import com.mochasmindlab.mlhealth.data.models.MealPlanJson
import com.mochasmindlab.mlhealth.data.models.PlanRecipe
import com.mochasmindlab.mlhealth.data.models.PlanRecipeJson
import com.mochasmindlab.mlhealth.data.models.WeeklyMealPlan
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.serialization.json.Json
import java.util.concurrent.ConcurrentHashMap
import javax.inject.Inject
import javax.inject.Singleton

/**
 * Loads bundled meal plan JSON files from `assets/MealPlans/`.
 * Mirrors iOS MealPlanLoader.swift.
 */
@Singleton
class MealPlanLoader @Inject constructor(
    @ApplicationContext private val context: Context
) {
    private val cache = ConcurrentHashMap<String, DietPlan>()

    private val json = Json {
        ignoreUnknownKeys = true
        coerceInputValues = true
    }

    suspend fun loadAll(): List<DietPlan> = withContext(Dispatchers.IO) {
        DIET_FILES.mapNotNull { (id, file) -> loadDietPlan(id, file) }
    }

    suspend fun loadDietPlan(dietId: String, file: String? = null): DietPlan? = withContext(Dispatchers.IO) {
        cache[dietId]?.let { return@withContext it }

        val fileName = file ?: dietId
        val plan = runCatching {
            val text = context.assets.open("MealPlans/$fileName.json").use { input ->
                input.bufferedReader().readText()
            }
            val parsed = json.decodeFromString(MealPlanJson.serializer(), text)
            convert(parsed)
        }.getOrNull()

        plan?.also { cache[dietId] = it }
    }

    private fun convert(parsed: MealPlanJson): DietPlan {
        val recipeMap = parsed.meals.mapValues { (id, recipe) -> recipe.toPlanRecipe(id) }

        val weeks = parsed.weeks.map { week ->
            WeeklyMealPlan(
                weekNumber = week.weekNumber,
                days = week.days.map { day ->
                    DailyMealPlan(
                        dayName = day.day,
                        breakfast = recipeMap[day.breakfast] ?: missingPlanRecipe(day.breakfast),
                        lunch = recipeMap[day.lunch] ?: missingPlanRecipe(day.lunch),
                        dinner = recipeMap[day.dinner] ?: missingPlanRecipe(day.dinner),
                        snack = recipeMap[day.snack] ?: missingPlanRecipe(day.snack)
                    )
                }
            )
        }

        return DietPlan(
            id = parsed.dietType,
            name = parsed.displayName,
            description = parsed.description,
            benefits = parsed.benefits,
            restrictions = parsed.restrictions,
            weeks = weeks
        )
    }

    private fun PlanRecipeJson.toPlanRecipe(id: String) = PlanRecipe(
        id = id,
        name = name,
        description = description,
        calories = calories,
        protein = protein,
        carbs = carbs,
        fat = fat,
        fiber = fiber,
        prepTime = prepTime,
        cookTime = cookTime,
        ingredients = ingredients,
        instructions = instructions,
        tags = tags
    )

    private fun missingPlanRecipe(id: String) = PlanRecipe(
        id = id,
        name = "Meal",
        description = "",
        calories = 0,
        protein = 0.0,
        carbs = 0.0,
        fat = 0.0,
        fiber = 0.0,
        prepTime = 0,
        cookTime = 0,
        ingredients = emptyList(),
        instructions = emptyList(),
        tags = emptyList()
    )

    companion object {
        // (dietId, fileName) — matches iOS list, order = display order.
        private val DIET_FILES = listOf(
            "mediterranean" to "mediterranean",
            "keto" to "keto",
            "high_protein" to "high_protein",
            "balanced" to "balanced",
            "low_carb" to "low_carb",
            "paleo" to "paleo",
            "whole30" to "whole30",
            "vegan" to "vegan"
        )
    }
}
