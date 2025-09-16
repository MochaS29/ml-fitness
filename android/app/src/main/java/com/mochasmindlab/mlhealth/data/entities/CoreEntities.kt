package com.mochasmindlab.mlhealth.data.entities

import androidx.room.*
import java.util.*

// ===== EXERCISE ENTRY =====
@Entity(tableName = "exercise_entries")
data class ExerciseEntry(
    @PrimaryKey val id: UUID = UUID.randomUUID(),
    val name: String,
    val category: String,
    val type: String,
    val date: Date,
    val timestamp: Date = Date(),
    val duration: Int, // minutes
    val caloriesBurned: Double,
    val notes: String? = null
)

// ===== FOOD ENTRY =====
@Entity(tableName = "food_entries")
data class FoodEntry(
    @PrimaryKey val id: UUID = UUID.randomUUID(),
    val name: String,
    val brand: String? = null,
    val barcode: String? = null,
    val date: Date,
    val timestamp: Date = Date(),
    val mealType: String, // breakfast, lunch, dinner, snack
    val servingSize: String,
    val servingUnit: String,
    val servingCount: Double = 1.0,
    val calories: Double,
    val protein: Double,
    val carbs: Double,
    val fat: Double,
    val fiber: Double? = null,
    val sugar: Double? = null,
    val sodium: Double? = null
)

// ===== SUPPLEMENT ENTRY =====
@Entity(tableName = "supplement_entries")
data class SupplementEntry(
    @PrimaryKey val id: UUID = UUID.randomUUID(),
    val name: String,
    val brand: String? = null,
    val date: Date,
    val timestamp: Date = Date(),
    val servingSize: String,
    val servingUnit: String,
    val imageData: ByteArray? = null,
    @TypeConverters(NutrientMapConverter::class)
    val nutrients: Map<String, Double> = emptyMap()
)

// ===== WEIGHT ENTRY =====
@Entity(tableName = "weight_entries")
data class WeightEntry(
    @PrimaryKey val id: UUID = UUID.randomUUID(),
    val weight: Double,
    val date: Date,
    val timestamp: Date = Date(),
    val notes: String? = null
)

// ===== WATER ENTRY =====
@Entity(tableName = "water_entries")
data class WaterEntry(
    @PrimaryKey val id: UUID = UUID.randomUUID(),
    val amount: Double = 8.0,
    val unit: String = "oz",
    val timestamp: Date = Date()
)

// ===== CUSTOM FOOD =====
@Entity(tableName = "custom_foods")
data class CustomFood(
    @PrimaryKey val id: UUID = UUID.randomUUID(),
    val name: String,
    val brand: String? = null,
    val barcode: String? = null,
    val category: String? = null,
    val source: String? = null,
    val fdcId: Int? = null,
    val isUserCreated: Boolean = true,
    val createdDate: Date = Date(),
    val servingSize: String,
    val servingUnit: String,
    val calories: Double,
    val protein: Double,
    val carbs: Double,
    val fat: Double,
    val saturatedFat: Double? = null,
    val fiber: Double? = null,
    val sugar: Double? = null,
    val sodium: Double? = null,
    val cholesterol: Double? = null,
    @TypeConverters(NutrientMapConverter::class)
    val additionalNutrients: Map<String, Double> = emptyMap()
)

// ===== CUSTOM RECIPE =====
@Entity(tableName = "custom_recipes")
data class CustomRecipe(
    @PrimaryKey val id: UUID = UUID.randomUUID(),
    val name: String,
    val category: String,
    val source: String? = null,
    val isUserCreated: Boolean = true,
    val isFavorite: Boolean = false,
    val createdDate: Date = Date(),
    val prepTime: Int, // minutes
    val cookTime: Int, // minutes
    val servings: Int,
    val imageData: ByteArray? = null,
    @TypeConverters(StringListConverter::class)
    val ingredients: List<String> = emptyList(),
    @TypeConverters(StringListConverter::class)
    val instructions: List<String> = emptyList(),
    @TypeConverters(StringListConverter::class)
    val tags: List<String> = emptyList(),
    val calories: Double,
    val protein: Double,
    val carbs: Double,
    val fat: Double,
    val fiber: Double? = null,
    val sugar: Double? = null,
    val sodium: Double? = null
)

// ===== FAVORITE RECIPE =====
@Entity(tableName = "favorite_recipes")
data class FavoriteRecipe(
    @PrimaryKey val id: UUID = UUID.randomUUID(),
    val recipeId: String,
    val recipeName: String,
    val category: String,
    val source: String? = null,
    val imageURL: String? = null,
    val dateAdded: Date = Date(),
    val prepTime: Int,
    val cookTime: Int,
    val servings: Int,
    val rating: Int = 0
)

// ===== MEAL PLAN =====
@Entity(tableName = "meal_plans")
data class MealPlan(
    @PrimaryKey val id: UUID = UUID.randomUUID(),
    val date: Date,
    val mealType: String, // breakfast, lunch, dinner, snack
    val recipeId: UUID? = null,
    val recipeName: String,
    val servings: Int = 1,
    val notes: String? = null // JSON for additional nutrition data
)

// ===== GROCERY LIST =====
@Entity(tableName = "grocery_lists")
data class GroceryList(
    @PrimaryKey val id: UUID = UUID.randomUUID(),
    val name: String,
    val createdDate: Date = Date(),
    val isCompleted: Boolean = false,
    @TypeConverters(StringListConverter::class)
    val items: List<String> = emptyList()
)

// ===== TYPE CONVERTERS =====
class Converters {
    @TypeConverter
    fun fromTimestamp(value: Long?): Date? {
        return value?.let { Date(it) }
    }

    @TypeConverter
    fun dateToTimestamp(date: Date?): Long? {
        return date?.time
    }

    @TypeConverter
    fun fromUUID(uuid: String?): UUID? {
        return uuid?.let { UUID.fromString(it) }
    }

    @TypeConverter
    fun uuidToString(uuid: UUID?): String? {
        return uuid?.toString()
    }
}

class NutrientMapConverter {
    @TypeConverter
    fun fromNutrientMap(map: Map<String, Double>): String {
        return map.entries.joinToString(";") { "${it.key}:${it.value}" }
    }

    @TypeConverter
    fun toNutrientMap(value: String): Map<String, Double> {
        if (value.isEmpty()) return emptyMap()
        return value.split(";").associate {
            val (key, v) = it.split(":")
            key to v.toDouble()
        }
    }
}

class StringListConverter {
    @TypeConverter
    fun fromStringList(list: List<String>): String {
        return list.joinToString("|||")
    }

    @TypeConverter
    fun toStringList(value: String): List<String> {
        if (value.isEmpty()) return emptyList()
        return value.split("|||")
    }
}