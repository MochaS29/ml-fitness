package com.mochasmindlab.mlhealth.data.database

import android.content.Context
import androidx.room.*
import com.mochasmindlab.mlhealth.data.entities.*
import com.mochasmindlab.mlhealth.data.models.Goal
import java.util.Date
import java.util.UUID

@Database(
    entities = [
        ExerciseEntry::class,
        FoodEntry::class,
        SupplementEntry::class,
        WeightEntry::class,
        WaterEntry::class,
        CustomFood::class,
        CustomRecipe::class,
        FavoriteRecipe::class,
        MealPlan::class,
        GroceryList::class,
        com.mochasmindlab.mlhealth.data.models.FoodItem::class,
        com.mochasmindlab.mlhealth.data.models.UserProfile::class,
        Goal::class
    ],
    version = 2,
    exportSchema = false
)
@TypeConverters(Converters::class, NutrientMapConverter::class, StringListConverter::class)
abstract class MLFitnessDatabase : RoomDatabase() {
    
    abstract fun exerciseDao(): ExerciseDao
    abstract fun foodDao(): FoodDao
    abstract fun supplementDao(): SupplementDao
    abstract fun weightDao(): WeightDao
    abstract fun waterDao(): WaterDao
    abstract fun customFoodDao(): CustomFoodDao
    abstract fun customRecipeDao(): CustomRecipeDao
    abstract fun favoriteRecipeDao(): FavoriteRecipeDao
    abstract fun mealPlanDao(): MealPlanDao
    abstract fun groceryListDao(): GroceryListDao
    abstract fun foodItemDao(): FoodItemDao
    abstract fun userProfileDao(): UserProfileDao
    abstract fun goalsDao(): GoalsDao
    
    companion object {
        @Volatile
        private var INSTANCE: MLFitnessDatabase? = null
        
        fun getDatabase(context: Context): MLFitnessDatabase {
            return INSTANCE ?: synchronized(this) {
                val instance = Room.databaseBuilder(
                    context.applicationContext,
                    MLFitnessDatabase::class.java,
                    "mlfitness_database"
                ).build()
                INSTANCE = instance
                instance
            }
        }
    }
}

// ===== DAOs =====

@Dao
interface ExerciseDao {
    @Query("SELECT * FROM exercise_entries WHERE date = :date ORDER BY timestamp DESC")
    suspend fun getEntriesForDate(date: Date): List<ExerciseEntry>
    
    @Query("SELECT * FROM exercise_entries WHERE date BETWEEN :startDate AND :endDate ORDER BY timestamp DESC")
    suspend fun getEntriesInRange(startDate: Date, endDate: Date): List<ExerciseEntry>
    
    @Insert
    suspend fun insert(entry: ExerciseEntry)
    
    @Update
    suspend fun update(entry: ExerciseEntry)
    
    @Delete
    suspend fun delete(entry: ExerciseEntry)
    
    @Query("SELECT SUM(caloriesBurned) FROM exercise_entries WHERE date = :date")
    suspend fun getTotalCaloriesForDate(date: Date): Double?
    
    @Query("SELECT SUM(duration) FROM exercise_entries WHERE date = :date")
    suspend fun getTotalDurationForDate(date: Date): Int?
}

@Dao
interface FoodDao {
    @Query("SELECT * FROM food_entries WHERE date = :date ORDER BY timestamp DESC")
    suspend fun getEntriesForDate(date: Date): List<FoodEntry>
    
    @Query("SELECT * FROM food_entries WHERE mealType = :mealType AND date = :date")
    suspend fun getEntriesForMeal(mealType: String, date: Date): List<FoodEntry>
    
    @Insert
    suspend fun insert(entry: FoodEntry)
    
    @Update
    suspend fun update(entry: FoodEntry)
    
    @Delete
    suspend fun delete(entry: FoodEntry)
    
    @Query("SELECT SUM(calories * servingCount) FROM food_entries WHERE date = :date")
    suspend fun getTotalCaloriesForDate(date: Date): Double?
    
    @Query("SELECT SUM(protein * servingCount) FROM food_entries WHERE date = :date")
    suspend fun getTotalProteinForDate(date: Date): Double?
    
    @Query("SELECT SUM(carbs * servingCount) FROM food_entries WHERE date = :date")
    suspend fun getTotalCarbsForDate(date: Date): Double?
    
    @Query("SELECT SUM(fat * servingCount) FROM food_entries WHERE date = :date")
    suspend fun getTotalFatForDate(date: Date): Double?
}

@Dao
interface SupplementDao {
    @Query("SELECT * FROM supplement_entries WHERE date = :date ORDER BY timestamp DESC")
    suspend fun getEntriesForDate(date: Date): List<SupplementEntry>
    
    @Insert
    suspend fun insert(entry: SupplementEntry)
    
    @Update
    suspend fun update(entry: SupplementEntry)
    
    @Delete
    suspend fun delete(entry: SupplementEntry)
    
    @Query("SELECT DISTINCT name FROM supplement_entries ORDER BY name")
    suspend fun getAllSupplementNames(): List<String>
}

@Dao
interface WeightDao {
    @Query("SELECT * FROM weight_entries ORDER BY date DESC LIMIT 1")
    suspend fun getLatestEntry(): WeightEntry?
    
    @Query("SELECT * FROM weight_entries WHERE date BETWEEN :startDate AND :endDate ORDER BY date ASC")
    suspend fun getEntriesInRange(startDate: Date, endDate: Date): List<WeightEntry>
    
    @Query("SELECT * FROM weight_entries ORDER BY date DESC LIMIT :limit")
    suspend fun getRecentEntries(limit: Int): List<WeightEntry>
    
    @Insert
    suspend fun insert(entry: WeightEntry)
    
    @Update
    suspend fun update(entry: WeightEntry)
    
    @Delete
    suspend fun delete(entry: WeightEntry)
}

@Dao
interface WaterDao {
    @Query("SELECT * FROM water_entries WHERE DATE(timestamp / 1000, 'unixepoch') = DATE(:date / 1000, 'unixepoch')")
    suspend fun getEntriesForDate(date: Date): List<WaterEntry>
    
    @Query("SELECT SUM(amount) FROM water_entries WHERE DATE(timestamp / 1000, 'unixepoch') = DATE(:date / 1000, 'unixepoch')")
    suspend fun getTotalForDate(date: Date): Double?
    
    @Insert
    suspend fun insert(entry: WaterEntry)
    
    @Update
    suspend fun update(entry: WaterEntry)
    
    @Delete
    suspend fun delete(entry: WaterEntry)
}

@Dao
interface CustomFoodDao {
    @Query("SELECT * FROM custom_foods WHERE name LIKE '%' || :query || '%' OR brand LIKE '%' || :query || '%' ORDER BY name")
    suspend fun searchFoods(query: String): List<CustomFood>
    
    @Query("SELECT * FROM custom_foods WHERE barcode = :barcode LIMIT 1")
    suspend fun getFoodByBarcode(barcode: String): CustomFood?
    
    @Query("SELECT * FROM custom_foods WHERE isUserCreated = 1 ORDER BY createdDate DESC")
    suspend fun getUserCreatedFoods(): List<CustomFood>
    
    @Insert
    suspend fun insert(food: CustomFood)
    
    @Update
    suspend fun update(food: CustomFood)
    
    @Delete
    suspend fun delete(food: CustomFood)
}

@Dao
interface CustomRecipeDao {
    @Query("SELECT * FROM custom_recipes ORDER BY name")
    suspend fun getAllRecipes(): List<CustomRecipe>
    
    @Query("SELECT * FROM custom_recipes WHERE isFavorite = 1 ORDER BY name")
    suspend fun getFavoriteRecipes(): List<CustomRecipe>
    
    @Query("SELECT * FROM custom_recipes WHERE category = :category ORDER BY name")
    suspend fun getRecipesByCategory(category: String): List<CustomRecipe>
    
    @Query("SELECT * FROM custom_recipes WHERE name LIKE '%' || :query || '%' ORDER BY name")
    suspend fun searchRecipes(query: String): List<CustomRecipe>
    
    @Insert
    suspend fun insert(recipe: CustomRecipe)
    
    @Update
    suspend fun update(recipe: CustomRecipe)
    
    @Delete
    suspend fun delete(recipe: CustomRecipe)
}

@Dao
interface FavoriteRecipeDao {
    @Query("SELECT * FROM favorite_recipes ORDER BY dateAdded DESC")
    suspend fun getAllFavorites(): List<FavoriteRecipe>
    
    @Query("SELECT * FROM favorite_recipes WHERE recipeId = :recipeId LIMIT 1")
    suspend fun getFavoriteByRecipeId(recipeId: String): FavoriteRecipe?
    
    @Insert
    suspend fun insert(favorite: FavoriteRecipe)
    
    @Update
    suspend fun update(favorite: FavoriteRecipe)
    
    @Delete
    suspend fun delete(favorite: FavoriteRecipe)
}

@Dao
interface MealPlanDao {
    @Query("SELECT * FROM meal_plans WHERE date = :date ORDER BY mealType")
    suspend fun getMealPlansForDate(date: Date): List<MealPlan>
    
    @Query("SELECT * FROM meal_plans WHERE date BETWEEN :startDate AND :endDate ORDER BY date, mealType")
    suspend fun getMealPlansInRange(startDate: Date, endDate: Date): List<MealPlan>
    
    @Insert
    suspend fun insert(mealPlan: MealPlan)
    
    @Update
    suspend fun update(mealPlan: MealPlan)
    
    @Delete
    suspend fun delete(mealPlan: MealPlan)
    
    @Query("DELETE FROM meal_plans WHERE date = :date")
    suspend fun deleteAllForDate(date: Date)
}

@Dao
interface GroceryListDao {
    @Query("SELECT * FROM grocery_lists WHERE isCompleted = 0 ORDER BY createdDate DESC")
    suspend fun getActiveGroceryLists(): List<GroceryList>
    
    @Query("SELECT * FROM grocery_lists ORDER BY createdDate DESC")
    suspend fun getAllGroceryLists(): List<GroceryList>
    
    @Insert
    suspend fun insert(groceryList: GroceryList)
    
    @Update
    suspend fun update(groceryList: GroceryList)
    
    @Delete
    suspend fun delete(groceryList: GroceryList)
}