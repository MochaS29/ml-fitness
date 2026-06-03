package com.mochasmindlab.mlhealth.data.database

import android.content.Context
import androidx.room.*
import androidx.room.migration.Migration
import androidx.sqlite.db.SupportSQLiteDatabase
import com.mochasmindlab.mlhealth.data.entities.*
import com.mochasmindlab.mlhealth.data.models.Goal
// Sleep tracking import — added by sleep-tracking agent
import com.mochasmindlab.mlhealth.data.entities.SleepEntry
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
        Goal::class,
        BodyMeasurementEntry::class,
        // Sleep tracking — added by sleep-tracking agent (gap #10).
        SleepEntry::class,
        // Intermittent fasting — added by fasting agent (gap #9). Bumps DB v4 → v5.
        // fallbackToDestructiveMigration() in DatabaseModule handles it safely.
        com.mochasmindlab.mlhealth.data.entities.FastingSession::class
    ],
    // v6: cholesterol / saturatedFat / additionalNutrients columns added to
    // food_entries + food_items so USDA vitamins/minerals reach the diary.
    // MIGRATION_5_6 preserves existing tester data (no destructive wipe).
    version = 6,
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
    abstract fun bodyMeasurementDao(): BodyMeasurementDao
    abstract fun sleepDao(): SleepDao
    abstract fun fastingDao(): FastingDao

    companion object {
        /**
         * v5 → v6: add extended-nutrient columns to food_entries + food_items so
         * vitamins/minerals (and cholesterol / saturated fat) from the bundled
         * USDA DB flow through to the diary. Additive, nullable/defaulted columns
         * → no data loss for existing testers. additionalNutrients is NOT NULL
         * with a '' default to match the Room entity (Map persisted as a string).
         */
        val MIGRATION_5_6 = object : Migration(5, 6) {
            override fun migrate(db: SupportSQLiteDatabase) {
                listOf("food_entries", "food_items").forEach { table ->
                    db.execSQL("ALTER TABLE $table ADD COLUMN cholesterol REAL")
                    db.execSQL("ALTER TABLE $table ADD COLUMN saturatedFat REAL")
                    db.execSQL("ALTER TABLE $table ADD COLUMN additionalNutrients TEXT NOT NULL DEFAULT ''")
                }
            }
        }

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
// ExerciseDao is defined in ExerciseDao.kt

@Dao
interface FoodDao {
    // All date-filter queries use SQL DATE() so they match by calendar day
    // regardless of the time-of-day component in the stored millis value.
    // This matches WaterDao's pattern and is robust to inserts that don't
    // bother to normalize to start-of-day.
    @Query("SELECT * FROM food_entries WHERE DATE(date/1000, 'unixepoch') = DATE(:date/1000, 'unixepoch') ORDER BY timestamp DESC")
    suspend fun getEntriesForDate(date: Date): List<FoodEntry>

    @Query("SELECT * FROM food_entries WHERE mealType = :mealType AND DATE(date/1000, 'unixepoch') = DATE(:date/1000, 'unixepoch')")
    suspend fun getEntriesForMeal(mealType: String, date: Date): List<FoodEntry>

    @Insert
    suspend fun insert(entry: FoodEntry)

    @Update
    suspend fun update(entry: FoodEntry)

    @Delete
    suspend fun delete(entry: FoodEntry)

    @Query("SELECT SUM(calories * servingCount) FROM food_entries WHERE DATE(date/1000, 'unixepoch') = DATE(:date/1000, 'unixepoch')")
    suspend fun getTotalCaloriesForDate(date: Date): Double?

    @Query("SELECT SUM(protein * servingCount) FROM food_entries WHERE DATE(date/1000, 'unixepoch') = DATE(:date/1000, 'unixepoch')")
    suspend fun getTotalProteinForDate(date: Date): Double?

    @Query("SELECT SUM(carbs * servingCount) FROM food_entries WHERE DATE(date/1000, 'unixepoch') = DATE(:date/1000, 'unixepoch')")
    suspend fun getTotalCarbsForDate(date: Date): Double?
    
    @Query("SELECT SUM(fat * servingCount) FROM food_entries WHERE DATE(date/1000, 'unixepoch') = DATE(:date/1000, 'unixepoch')")
    suspend fun getTotalFatForDate(date: Date): Double?

    /** Returns all distinct logged dates (as timestamps), newest first. Suspend version for one-shot queries. */
    @Query("SELECT DISTINCT date FROM food_entries ORDER BY date DESC")
    suspend fun getAllLoggedDates(): List<Date>

    /** Room Flow version — emits a new list whenever food_entries changes. Used by LoggingStreakManager. */
    @Query("SELECT DISTINCT date FROM food_entries ORDER BY date DESC")
    fun getAllLoggedDatesFlow(): kotlinx.coroutines.flow.Flow<List<Date>>

    /** All-time count of food entries. Used by AchievementManager. */
    @Query("SELECT COUNT(*) FROM food_entries")
    suspend fun getTotalFoodEntryCount(): Int
}

@Dao
interface SupplementDao {
    @Query("SELECT * FROM supplement_entries WHERE date = :date ORDER BY timestamp DESC")
    suspend fun getEntriesForDate(date: Date): List<SupplementEntry>

    /**
     * Calendar-day match via SQL DATE() — robust to a time-of-day component on
     * either the stored or query date (unlike the exact `date = :date` above,
     * which silently returns nothing when the diary's selectedDate is "now").
     * Used for daily totals on the Diary and Dashboard.
     */
    @Query("SELECT * FROM supplement_entries WHERE DATE(date/1000, 'unixepoch') = DATE(:date/1000, 'unixepoch') ORDER BY timestamp DESC")
    suspend fun getEntriesForDay(date: Date): List<SupplementEntry>
    
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

    // Additional methods for WeightRepository
    @Insert
    suspend fun insertWeightEntry(entry: WeightEntry)

    @Update
    suspend fun updateWeightEntry(entry: WeightEntry)

    @Query("DELETE FROM weight_entries WHERE id = :id")
    suspend fun deleteWeightEntry(id: UUID)

    @Query("SELECT * FROM weight_entries ORDER BY date DESC")
    fun getAllWeightEntries(): kotlinx.coroutines.flow.Flow<List<WeightEntry>>

    @Query("SELECT * FROM weight_entries WHERE id = :id LIMIT 1")
    fun getWeightEntryById(id: UUID): kotlinx.coroutines.flow.Flow<WeightEntry?>

    @Query("SELECT * FROM weight_entries WHERE date BETWEEN :startDate AND :endDate ORDER BY date ASC")
    fun getWeightEntriesBetweenDates(startDate: Date, endDate: Date): kotlinx.coroutines.flow.Flow<List<WeightEntry>>

    @Query("SELECT * FROM weight_entries ORDER BY date DESC LIMIT 1")
    suspend fun getLatestWeight(): WeightEntry?

    @Query("SELECT * FROM weight_entries WHERE date = :date LIMIT 1")
    suspend fun getWeightOnDate(date: Date): WeightEntry?
}

// WaterDao is defined in WaterDao.kt

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