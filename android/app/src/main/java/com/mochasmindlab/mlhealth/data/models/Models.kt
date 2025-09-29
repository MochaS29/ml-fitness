package com.mochasmindlab.mlhealth.data.models

import kotlinx.serialization.Serializable
import java.util.*



@Serializable
data class UserFoodPreferences(
    var allergies: List<AllergyInfo> = emptyList(),
    var intolerances: List<FoodIntolerance> = emptyList(),
    var dietaryPreferences: List<DietaryPreference> = emptyList(),
    var dislikedFoods: List<String> = emptyList(),
    var avoidIngredients: List<String> = emptyList(),
    var cuisinePreferences: List<CuisinePreference> = emptyList(),
    var mealPreferences: MealPreferences = MealPreferences()
)

@Serializable
data class AllergyInfo(
    val id: String = UUID.randomUUID().toString(),
    val allergy: FoodAllergy,
    var severity: AllergySeverity,
    var notes: String? = null
)

@Serializable
data class MealPreferences(
    var breakfastTime: Long? = null, // Time as timestamp
    var lunchTime: Long? = null,
    var dinnerTime: Long? = null,
    var snackPreferences: List<String> = emptyList(),
    var portionSize: PortionPreference = PortionPreference.NORMAL,
    var spiceLevel: SpiceLevel = SpiceLevel.MEDIUM
)

@Serializable
data class CuisinePreference(
    val cuisine: String,
    val preference: PreferenceLevel
)

// ===== FASTING =====
@Serializable
data class FastingSession(
    val id: String = UUID.randomUUID().toString(),
    var startTime: Long, // Timestamp
    var plannedDuration: Long, // Duration in milliseconds
    var actualEndTime: Long? = null,
    var fastingPlan: FastingPlan,
    var notes: String? = null
)

// ===== RECIPE =====
@Serializable
data class Recipe(
    val id: String = UUID.randomUUID().toString(),
    var name: String,
    var category: RecipeCategory,
    var prepTime: Int, // minutes
    var cookTime: Int, // minutes
    var servings: Int,
    var ingredients: List<Ingredient> = emptyList(),
    var instructions: List<String> = emptyList(),
    var nutrition: NutritionInfo? = null,
    var imageURL: String? = null,
    var source: String? = null,
    var tags: List<String> = emptyList(),
    var isFavorite: Boolean = false,
    var rating: Int = 0
)

@Serializable
data class Ingredient(
    val id: String = UUID.randomUUID().toString(),
    var name: String,
    var amount: Double,
    var unit: IngredientUnit,
    var notes: String? = null,
    var category: GroceryCategory = GroceryCategory.OTHER
)

@Serializable
data class NutritionInfo(
    var calories: Double,
    var protein: Double,
    var carbs: Double,
    var fat: Double,
    var fiber: Double? = null,
    var sugar: Double? = null,
    var sodium: Double? = null
)

// ===== ACHIEVEMENT =====
data class Achievement(
    val id: String = UUID.randomUUID().toString(),
    val type: AchievementType,
    val title: String,
    val description: String,
    val dateEarned: Long, // Timestamp
    val value: String? = null
)

// ===== RDA (Recommended Daily Allowance) =====
@Serializable
data class RDAValue(
    val amount: Double,
    val unit: NutrientUnit,
    val upperLimit: Double? = null,
    val aiValue: Double? = null // Adequate Intake when RDA not established
)

@Serializable
data class NutrientRDA(
    val nutrientId: String,
    val name: String,
    val maleValues: Map<AgeGroup, RDAValue> = emptyMap(),
    val femaleValues: Map<AgeGroup, RDAValue> = emptyMap(),
    val pregnancyValues: Map<PregnancyTrimester, RDAValue> = emptyMap(),
    val breastfeedingValue: RDAValue? = null
)

@Serializable
data class MealNutritionData(
    var breakfastCalories: Int = 0,
    var lunchCalories: Int = 0,
    var dinnerCalories: Int = 0,
    var breakfastProtein: Int = 0,
    var lunchProtein: Int = 0,
    var dinnerProtein: Int = 0,
    var planType: String? = null,
    var dietaryPreference: String? = null,
    var familySize: Int = 1
)

// ===== ENUMERATIONS =====

@Serializable
enum class MealType {
    BREAKFAST, LUNCH, DINNER, SNACK
}

@Serializable
enum class Gender {
    MALE, FEMALE, OTHER
}

@Serializable
enum class WeightUnit {
    KG, LBS
}

@Serializable
enum class HeightUnit {
    CM, FEET_INCHES
}

@Serializable
enum class AgeGroup {
    CHILD, ADULT_19_TO_30, ADULT_31_TO_50, ADULT_51_TO_70, ADULT_71_PLUS
}

@Serializable
enum class ActivityLevel {
    SEDENTARY, LIGHT, MODERATE, ACTIVE, VERY_ACTIVE
}

@Serializable
enum class PregnancyTrimester {
    FIRST, SECOND, THIRD
}

@Serializable
enum class DietaryRestriction {
    VEGETARIAN, VEGAN, GLUTEN_FREE, DAIRY_FREE, NUT_ALLERGY, KOSHER, HALAL
}

@Serializable
enum class HealthCondition {
    DIABETES, HYPERTENSION, HEART_DISEASE, OSTEOPOROSIS, ANEMIA, THYROID_DISORDER
}

@Serializable
enum class RecipeCategory {
    BREAKFAST, LUNCH, DINNER, DESSERT, SNACK, APPETIZER, BEVERAGE, SALAD, SOUP, SIDE_DISH
}

@Serializable
enum class IngredientUnit {
    CUP, TABLESPOON, TEASPOON, OUNCE, POUND, GRAM, KILOGRAM, MILLILITER, LITER, 
    PIECE, CLOVE, PINCH, DASH, CAN, PACKAGE, BUNCH
}

@Serializable
enum class GroceryCategory {
    PRODUCE, MEAT, DAIRY, BAKERY, PANTRY, FROZEN, BEVERAGES, SNACKS, CONDIMENTS, SPICES, OTHER
}

@Serializable
enum class FoodAllergy {
    MILK, EGGS, FISH, SHELLFISH, TREE_NUTS, PEANUTS, WHEAT, SOYBEANS, SESAME, GLUTEN,
    CORN, SULFITES, MUSTARD, CELERY, LUPIN, MOLLUSKS, LATEX, RED_MEAT, POULTRY,
    CITRUS, TOMATO, CHOCOLATE, STRAWBERRY
}

@Serializable
enum class AllergySeverity {
    MILD, MODERATE, SEVERE, LIFE_THREATENING
}

@Serializable
enum class FoodIntolerance {
    LACTOSE, FRUCTOSE, HISTAMINE, FODMAP, NIGHTSHADES, CAFFEINE, ALCOHOL, MSG
}

@Serializable
enum class DietaryPreference {
    VEGETARIAN, VEGAN, PESCATARIAN, FLEXITARIAN, KOSHER, HALAL, LOW_CARB, KETO,
    PALEO, MEDITERRANEAN, WHOLE30, DASH, FODMAP, GLUTEN_FREE, DAIRY_FREE,
    RAW_FOOD, MACROBIOTIC, ZONE, ATKINS, SOUTH_BEACH, WEIGHT_WATCHERS
}

@Serializable
enum class PreferenceLevel {
    LOVE, LIKE, NEUTRAL, DISLIKE, AVOID
}

@Serializable
enum class PortionPreference {
    SMALL, NORMAL, LARGE
}

@Serializable
enum class SpiceLevel {
    NONE, MILD, MEDIUM, HOT, VERY_HOT
}

@Serializable
enum class GoalCategory {
    WEIGHT_LOSS, WEIGHT_GAIN, NUTRITION, EXERCISE, HYDRATION, SLEEP, MINDFULNESS, CUSTOM
}

@Serializable
enum class GoalTargetType {
    REACH_TARGET, STAY_BELOW, STAY_ABOVE, MAINTAIN_RANGE
}

@Serializable
enum class GoalFrequency {
    DAILY, WEEKLY, MONTHLY, TOTAL
}

@Serializable
enum class AchievementType {
    WEIGHT_LOSS, CALORIE_GOAL, EXERCISE_STREAK, NUTRITION_BALANCE, WATER_INTAKE,
    STEP_GOAL, SUPPLEMENT_CONSISTENCY, STREAK, OTHER
}

@Serializable
enum class FastingPlan {
    SIXTEEN_EIGHT, EIGHTEEN_SIX, TWENTY_FOUR, FIVE_TWO, OMAD, CUSTOM
}

@Serializable
enum class NutrientUnit {
    MG, MCG, G, IU
}

@Serializable
enum class LifeStage {
    STANDARD, PREGNANT, BREASTFEEDING
}