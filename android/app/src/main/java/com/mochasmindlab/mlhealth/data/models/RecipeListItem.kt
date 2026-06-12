package com.mochasmindlab.mlhealth.data.models

import com.mochasmindlab.mlhealth.data.entities.CustomRecipe

// ---------------------------------------------------------------------------
// LibraryTab — which top-level tab is visible in RecipeLibraryScreen
// ---------------------------------------------------------------------------

enum class LibraryTab { LIBRARY, MY_RECIPES }

// ---------------------------------------------------------------------------
// RecipeCategory — mirrors iOS RecipeCategory enum
// ---------------------------------------------------------------------------

enum class RecipeCategory(val displayName: String) {
    BREAKFAST("Breakfast"),
    LUNCH("Lunch"),
    DINNER("Dinner"),
    SNACK("Snack"),
    OTHER("Other");

    companion object {
        fun fromString(raw: String?): RecipeCategory =
            entries.firstOrNull { it.displayName.equals(raw, ignoreCase = true) }
                ?: OTHER

        /** Infer category from a PlanRecipe's position in DailyMealPlan. */
        fun fromPlanPosition(position: String): RecipeCategory = when (position) {
            "breakfast" -> BREAKFAST
            "lunch"     -> LUNCH
            "dinner"    -> DINNER
            "snack"     -> SNACK
            else        -> OTHER
        }
    }
}

// ---------------------------------------------------------------------------
// RecipeListItem — sealed wrapper for Library (bundled) or My Recipes (custom)
// ---------------------------------------------------------------------------

sealed class RecipeListItem {

    abstract val id: String
    abstract val name: String
    abstract val category: RecipeCategory
    abstract val calories: Int
    abstract val protein: Double
    abstract val carbs: Double
    abstract val fat: Double
    abstract val totalTimeMinutes: Int
    abstract val description: String

    /** Bundled recipe from a meal-plan JSON asset. */
    data class Bundled(
        val recipe: PlanRecipe,
        val position: String          // "breakfast" | "lunch" | "dinner" | "snack"
    ) : RecipeListItem() {
        override val id: String get() = recipe.id
        override val name: String get() = recipe.name
        override val category: RecipeCategory get() = RecipeCategory.fromPlanPosition(position)
        override val calories: Int get() = recipe.calories
        override val protein: Double get() = recipe.protein
        override val carbs: Double get() = recipe.carbs
        override val fat: Double get() = recipe.fat
        override val totalTimeMinutes: Int get() = recipe.totalTime
        override val description: String get() = recipe.description
    }

    /** User-created or imported recipe stored in Room. */
    data class Custom(val recipe: CustomRecipe) : RecipeListItem() {
        override val id: String get() = recipe.id.toString()
        override val name: String get() = recipe.name
        override val category: RecipeCategory get() = RecipeCategory.fromString(recipe.category)
        override val calories: Int get() = recipe.calories.toInt()
        override val protein: Double get() = recipe.protein
        override val carbs: Double get() = recipe.carbs
        override val fat: Double get() = recipe.fat
        override val totalTimeMinutes: Int get() = recipe.prepTime + recipe.cookTime
        override val description: String get() = ""
    }
}
