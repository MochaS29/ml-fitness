package com.mlhealth.app.data.local

import androidx.room.*
import java.util.Date

/**
 * Room entity for storing recipes locally
 */
@Entity(tableName = "recipes")
data class RecipeEntity(
    @PrimaryKey
    val id: String,
    val name: String,
    val description: String,
    val imageUrl: String?,
    val category: String,
    val cuisine: String?,

    // Time
    val prepTime: Int,
    val cookTime: Int,
    val totalTime: Int,
    val servings: Int,

    // Nutrition
    val calories: Int,
    val protein: Double,
    val carbs: Double,
    val fat: Double,
    val fiber: Double,

    // Complex data stored as JSON
    @ColumnInfo(name = "ingredients_json")
    val ingredientsJson: String, // JSON string of List<Ingredient>

    @ColumnInfo(name = "instructions_json")
    val instructionsJson: String, // JSON string of List<Instruction>

    // Arrays stored as comma-separated strings
    val dietaryTags: String?, // comma-separated
    val mealPlans: String?, // comma-separated
    val tags: String?, // comma-separated

    // Metadata
    val difficulty: String,
    val rating: Double,

    // User data
    val isFavorite: Boolean = false,
    val userNotes: String? = null,
    val cookedCount: Int = 0,
    val lastCookedDate: Date? = null,

    // Sync metadata
    val isFromAPI: Boolean = false,
    val lastUpdated: Date = Date()
)

/**
 * Data class for ingredients (stored as JSON)
 */
data class Ingredient(
    val name: String,
    val amount: Double,
    val unit: String,
    val category: String? = null
)

/**
 * Data class for instructions (stored as JSON)
 */
data class Instruction(
    val stepNumber: Int,
    val instruction: String,
    val duration: Int? = null
)

/**
 * Room DAO for recipe operations
 */
@Dao
interface RecipeDao {
    @Query("SELECT * FROM recipes ORDER BY isFavorite DESC, rating DESC, name ASC")
    suspend fun getAllRecipes(): List<RecipeEntity>

    @Query("""
        SELECT * FROM recipes
        WHERE (:category IS NULL OR category = :category)
        AND (:mealPlan IS NULL OR mealPlans LIKE '%' || :mealPlan || '%')
        AND (:searchText IS NULL OR name LIKE '%' || :searchText || '%' OR description LIKE '%' || :searchText || '%')
        AND (:favoritesOnly = 0 OR isFavorite = 1)
        ORDER BY isFavorite DESC, rating DESC, name ASC
    """)
    suspend fun getFilteredRecipes(
        category: String?,
        mealPlan: String?,
        searchText: String?,
        favoritesOnly: Boolean
    ): List<RecipeEntity>

    @Query("SELECT * FROM recipes WHERE id = :recipeId LIMIT 1")
    suspend fun getRecipeById(recipeId: String): RecipeEntity?

    @Query("SELECT * FROM recipes WHERE isFavorite = 1 ORDER BY name ASC")
    suspend fun getFavoriteRecipes(): List<RecipeEntity>

    @Query("SELECT * FROM recipes WHERE category = :category ORDER BY rating DESC LIMIT :limit")
    suspend fun getRecipesByCategory(category: String, limit: Int = 20): List<RecipeEntity>

    @Query("SELECT * FROM recipes WHERE mealPlans LIKE '%' || :mealPlan || '%' ORDER BY rating DESC")
    suspend fun getRecipesByMealPlan(mealPlan: String): List<RecipeEntity>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertRecipe(recipe: RecipeEntity)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertRecipes(recipes: List<RecipeEntity>)

    @Update
    suspend fun updateRecipe(recipe: RecipeEntity)

    @Query("UPDATE recipes SET isFavorite = NOT isFavorite WHERE id = :recipeId")
    suspend fun toggleFavorite(recipeId: String)

    @Query("UPDATE recipes SET userNotes = :notes WHERE id = :recipeId")
    suspend fun updateNotes(recipeId: String, notes: String)

    @Query("UPDATE recipes SET cookedCount = cookedCount + 1, lastCookedDate = :date WHERE id = :recipeId")
    suspend fun markAsCooked(recipeId: String, date: Date = Date())

    @Delete
    suspend fun deleteRecipe(recipe: RecipeEntity)

    @Query("DELETE FROM recipes")
    suspend fun deleteAllRecipes()

    @Query("SELECT COUNT(*) FROM recipes")
    suspend fun getRecipeCount(): Int
}

/**
 * Type converters for Room database
 */
class RecipeTypeConverters {
    @TypeConverter
    fun fromDate(date: Date?): Long? {
        return date?.time
    }

    @TypeConverter
    fun toDate(timestamp: Long?): Date? {
        return timestamp?.let { Date(it) }
    }
}

/**
 * Recipe repository for managing local data and API sync
 */
class RecipeRepository(
    private val recipeDao: RecipeDao,
    private val apiService: RecipeApiService? = null // Optional API service
) {
    // Load recipes from local database
    suspend fun getLocalRecipes(
        category: String? = null,
        mealPlan: String? = null,
        searchText: String? = null,
        favoritesOnly: Boolean = false
    ): List<RecipeEntity> {
        return recipeDao.getFilteredRecipes(category, mealPlan, searchText, favoritesOnly)
    }

    // Fetch recipes from API and save locally
    suspend fun fetchAndSaveRecipesFromAPI(mealPlan: String? = null) {
        try {
            apiService?.let { api ->
                val response = api.getRecipes(mealPlan = mealPlan, limit = 50)
                if (response.success) {
                    val entities = response.recipes.map { apiRecipe ->
                        apiRecipe.toEntity()
                    }
                    recipeDao.insertRecipes(entities)
                }
            }
        } catch (e: Exception) {
            // Handle API error - continue with local data
            println("API fetch failed: ${e.message}")
        }
    }

    // Toggle favorite status
    suspend fun toggleFavorite(recipeId: String) {
        recipeDao.toggleFavorite(recipeId)
    }

    // Update user notes
    suspend fun updateNotes(recipeId: String, notes: String) {
        recipeDao.updateNotes(recipeId, notes)
    }

    // Mark recipe as cooked
    suspend fun markAsCooked(recipeId: String) {
        recipeDao.markAsCooked(recipeId)
    }

    // Get single recipe
    suspend fun getRecipe(recipeId: String): RecipeEntity? {
        return recipeDao.getRecipeById(recipeId)
    }

    // Load initial bundled recipes
    suspend fun loadBundledRecipes(context: android.content.Context) {
        val prefs = context.getSharedPreferences("recipe_prefs", android.content.Context.MODE_PRIVATE)
        val hasInitialData = prefs.getBoolean("has_initial_data", false)

        if (!hasInitialData) {
            try {
                val jsonString = context.assets.open("initial_recipes.json").bufferedReader().use { it.readText() }
                val recipes = com.google.gson.Gson().fromJson(jsonString, Array<RecipeData>::class.java)

                val entities = recipes.map { it.toEntity() }
                recipeDao.insertRecipes(entities)

                prefs.edit().putBoolean("has_initial_data", true).apply()
            } catch (e: Exception) {
                println("Failed to load bundled recipes: ${e.message}")
            }
        }
    }
}

/**
 * Extension functions for data conversion
 */
fun APIRecipe.toEntity(): RecipeEntity {
    val gson = com.google.gson.Gson()
    return RecipeEntity(
        id = this.id,
        name = this.name,
        description = this.description,
        imageUrl = this.imageUrl,
        category = this.category,
        cuisine = this.cuisine,
        prepTime = this.prepTime,
        cookTime = this.cookTime,
        totalTime = this.prepTime + this.cookTime,
        servings = this.servings,
        calories = this.nutrition.calories,
        protein = this.nutrition.protein,
        carbs = this.nutrition.carbs,
        fat = this.nutrition.fat,
        fiber = this.nutrition.fiber,
        ingredientsJson = gson.toJson(this.ingredients.map {
            Ingredient(it.name, it.amount, it.unit, it.category)
        }),
        instructionsJson = gson.toJson(this.instructions.map {
            Instruction(it.stepNumber, it.instruction, it.duration)
        }),
        dietaryTags = this.dietaryTags.joinToString(","),
        mealPlans = this.mealPlans.joinToString(","),
        tags = this.tags.joinToString(","),
        difficulty = this.difficulty,
        rating = this.rating.average,
        isFromAPI = true
    )
}

fun RecipeData.toEntity(): RecipeEntity {
    val gson = com.google.gson.Gson()
    return RecipeEntity(
        id = this.id,
        name = this.name,
        description = this.description,
        imageUrl = this.imageUrl,
        category = this.category,
        cuisine = this.cuisine,
        prepTime = this.prepTime,
        cookTime = this.cookTime,
        totalTime = this.prepTime + this.cookTime,
        servings = this.servings,
        calories = this.nutrition.calories,
        protein = this.nutrition.protein,
        carbs = this.nutrition.carbs,
        fat = this.nutrition.fat,
        fiber = this.nutrition.fiber,
        ingredientsJson = gson.toJson(this.ingredients),
        instructionsJson = gson.toJson(this.instructions),
        dietaryTags = this.dietaryTags.joinToString(","),
        mealPlans = this.mealPlans.joinToString(","),
        tags = this.tags.joinToString(","),
        difficulty = this.difficulty,
        rating = this.rating
    )
}

fun RecipeEntity.getIngredientsList(): List<Ingredient> {
    return try {
        com.google.gson.Gson().fromJson(ingredientsJson, Array<Ingredient>::class.java).toList()
    } catch (e: Exception) {
        emptyList()
    }
}

fun RecipeEntity.getInstructionsList(): List<Instruction> {
    return try {
        com.google.gson.Gson().fromJson(instructionsJson, Array<Instruction>::class.java).toList()
    } catch (e: Exception) {
        emptyList()
    }
}

fun RecipeEntity.getDietaryTagsList(): List<String> {
    return dietaryTags?.split(",")?.filter { it.isNotBlank() } ?: emptyList()
}

fun RecipeEntity.getMealPlansList(): List<String> {
    return mealPlans?.split(",")?.filter { it.isNotBlank() } ?: emptyList()
}

/**
 * Data models for API and bundled data
 */
data class RecipeData(
    val id: String,
    val name: String,
    val description: String,
    val imageUrl: String?,
    val category: String,
    val cuisine: String?,
    val prepTime: Int,
    val cookTime: Int,
    val servings: Int,
    val nutrition: NutritionData,
    val ingredients: List<Ingredient>,
    val instructions: List<Instruction>,
    val dietaryTags: List<String>,
    val mealPlans: List<String>,
    val tags: List<String>,
    val difficulty: String,
    val rating: Double
)

data class NutritionData(
    val calories: Int,
    val protein: Double,
    val carbs: Double,
    val fat: Double,
    val fiber: Double
)

data class APIRecipe(
    val id: String,
    val name: String,
    val description: String,
    val imageUrl: String?,
    val category: String,
    val cuisine: String?,
    val prepTime: Int,
    val cookTime: Int,
    val servings: Int,
    val nutrition: APINutrition,
    val ingredients: List<APIIngredient>,
    val instructions: List<APIInstruction>,
    val dietaryTags: List<String>,
    val mealPlans: List<String>,
    val tags: List<String>,
    val difficulty: String,
    val rating: APIRating
)

data class APINutrition(
    val calories: Int,
    val protein: Double,
    val carbs: Double,
    val fat: Double,
    val fiber: Double
)

data class APIIngredient(
    val name: String,
    val amount: Double,
    val unit: String,
    val category: String?
)

data class APIInstruction(
    val stepNumber: Int,
    val instruction: String,
    val duration: Int?
)

data class APIRating(
    val average: Double,
    val count: Int
)

data class RecipeApiResponse(
    val success: Boolean,
    val recipes: List<APIRecipe>
)

/**
 * API Service interface (optional - can work offline)
 */
interface RecipeApiService {
    suspend fun getRecipes(
        mealPlan: String? = null,
        category: String? = null,
        limit: Int = 20
    ): RecipeApiResponse
}