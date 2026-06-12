package com.mochasmindlab.mlhealth.database

import androidx.room.Room
import androidx.test.core.app.ApplicationProvider
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.google.common.truth.Truth.assertThat
import com.mochasmindlab.mlhealth.data.database.MLFitnessDatabase
import com.mochasmindlab.mlhealth.data.entities.*
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.runTest
import org.junit.After
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import java.util.*

@ExperimentalCoroutinesApi
@RunWith(AndroidJUnit4::class)
class MLFitnessDatabaseTest {
    
    private lateinit var database: MLFitnessDatabase
    
    @Before
    fun setup() {
        database = Room.inMemoryDatabaseBuilder(
            ApplicationProvider.getApplicationContext(),
            MLFitnessDatabase::class.java
        ).allowMainThreadQueries().build()
    }
    
    @After
    fun tearDown() {
        database.close()
    }
    
    // ===== FOOD DAO TESTS =====
    
    @Test
    fun insertAndRetrieveFoodEntry() = runTest {
        // Given
        val foodEntry = FoodEntry(
            id = UUID.randomUUID(),
            name = "Apple",
            date = Date(),
            mealType = "breakfast",
            servingSize = "1",
            servingUnit = "medium",
            servingCount = 1.0,
            calories = 95.0,
            protein = 0.5,
            carbs = 25.0,
            fat = 0.3
        )
        
        // When
        database.foodDao().insert(foodEntry)
        val entries = database.foodDao().getEntriesForDate(foodEntry.date)
        
        // Then
        assertThat(entries).hasSize(1)
        assertThat(entries[0].name).isEqualTo("Apple")
        assertThat(entries[0].calories).isEqualTo(95.0)
    }
    
    @Test
    fun getFoodEntriesForMeal() = runTest {
        // Given
        val date = Date()
        val breakfastEntry = createFoodEntry("Eggs", "breakfast", date)
        val lunchEntry = createFoodEntry("Salad", "lunch", date)
        val dinnerEntry = createFoodEntry("Chicken", "dinner", date)
        
        // When
        database.foodDao().insert(breakfastEntry)
        database.foodDao().insert(lunchEntry)
        database.foodDao().insert(dinnerEntry)
        
        val breakfastEntries = database.foodDao().getEntriesForMeal("breakfast", date)
        
        // Then
        assertThat(breakfastEntries).hasSize(1)
        assertThat(breakfastEntries[0].name).isEqualTo("Eggs")
    }
    
    @Test
    fun calculateTotalCaloriesForDate() = runTest {
        // Given
        val date = Date()
        val entry1 = createFoodEntry("Food1", "breakfast", date, calories = 200.0, servingCount = 1.0)
        val entry2 = createFoodEntry("Food2", "lunch", date, calories = 300.0, servingCount = 2.0)
        
        // When
        database.foodDao().insert(entry1)
        database.foodDao().insert(entry2)
        
        val totalCalories = database.foodDao().getTotalCaloriesForDate(date)
        
        // Then
        assertThat(totalCalories).isEqualTo(800.0) // 200 + (300 * 2)
    }
    
    @Test
    fun updateFoodEntry() = runTest {
        // Given
        val foodEntry = createFoodEntry("Original", "breakfast", Date())
        database.foodDao().insert(foodEntry)
        
        // When
        val updatedEntry = foodEntry.copy(name = "Updated")
        database.foodDao().update(updatedEntry)
        
        val entries = database.foodDao().getEntriesForDate(foodEntry.date)
        
        // Then
        assertThat(entries).hasSize(1)
        assertThat(entries[0].name).isEqualTo("Updated")
    }
    
    @Test
    fun deleteFoodEntry() = runTest {
        // Given
        val foodEntry = createFoodEntry("ToDelete", "breakfast", Date())
        database.foodDao().insert(foodEntry)
        
        // When
        database.foodDao().delete(foodEntry)
        
        val entries = database.foodDao().getEntriesForDate(foodEntry.date)
        
        // Then
        assertThat(entries).isEmpty()
    }
    
    // ===== WATER DAO TESTS =====
    
    @Test
    fun insertAndRetrieveWaterEntry() = runTest {
        // Given
        val waterEntry = WaterEntry(
            id = UUID.randomUUID(),
            amount = 8.0,
            unit = "oz",
            timestamp = Date()
        )
        
        // When
        database.waterDao().insert(waterEntry)
        val entries = database.waterDao().getEntriesForDate(Date())
        
        // Then
        assertThat(entries).hasSize(1)
        assertThat(entries[0].amount).isEqualTo(8.0)
    }
    
    @Test
    fun calculateTotalWaterForDate() = runTest {
        // Given
        val date = Date()
        val entry1 = WaterEntry(amount = 8.0, timestamp = date)
        val entry2 = WaterEntry(amount = 12.0, timestamp = date)
        val entry3 = WaterEntry(amount = 16.0, timestamp = date)
        
        // When
        database.waterDao().insert(entry1)
        database.waterDao().insert(entry2)
        database.waterDao().insert(entry3)
        
        val total = database.waterDao().getTotalForDate(date)
        
        // Then
        assertThat(total).isEqualTo(36.0) // 8 + 12 + 16
    }
    
    // ===== EXERCISE DAO TESTS =====
    
    @Test
    fun insertAndRetrieveExerciseEntry() = runTest {
        // Given
        val exerciseEntry = ExerciseEntry(
            id = UUID.randomUUID(),
            name = "Running",
            type = "cardio",
            date = Date(),
            duration = 30,
            caloriesBurned = 300.0,
            distance = 5.0,
            distanceUnit = "km"
        )
        
        // When
        database.exerciseDao().insert(exerciseEntry)
        val entries = database.exerciseDao().getEntriesForDate(exerciseEntry.date)
        
        // Then
        assertThat(entries).hasSize(1)
        assertThat(entries[0].name).isEqualTo("Running")
        assertThat(entries[0].duration).isEqualTo(30)
    }
    
    @Test
    fun getTotalExerciseDurationForDate() = runTest {
        // Given
        val date = Date()
        val entry1 = ExerciseEntry(name = "Running", type = "cardio", date = date, duration = 30)
        val entry2 = ExerciseEntry(name = "Cycling", type = "cardio", date = date, duration = 45)
        
        // When
        database.exerciseDao().insert(entry1)
        database.exerciseDao().insert(entry2)
        
        val totalDuration = database.exerciseDao().getTotalDurationForDate(date)
        
        // Then
        assertThat(totalDuration).isEqualTo(75) // 30 + 45
    }
    
    @Test
    fun getExerciseEntriesInDateRange() = runTest {
        // Given
        val calendar = Calendar.getInstance()
        val today = calendar.time
        
        calendar.add(Calendar.DAY_OF_YEAR, -1)
        val yesterday = calendar.time
        
        calendar.add(Calendar.DAY_OF_YEAR, -1)
        val twoDaysAgo = calendar.time
        
        val entry1 = ExerciseEntry(name = "Day1", type = "cardio", date = twoDaysAgo, duration = 30)
        val entry2 = ExerciseEntry(name = "Day2", type = "cardio", date = yesterday, duration = 30)
        val entry3 = ExerciseEntry(name = "Day3", type = "cardio", date = today, duration = 30)
        
        // When
        database.exerciseDao().insert(entry1)
        database.exerciseDao().insert(entry2)
        database.exerciseDao().insert(entry3)
        
        val entries = database.exerciseDao().getEntriesInRange(yesterday, today)
        
        // Then
        assertThat(entries).hasSize(2)
        assertThat(entries.map { it.name }).containsExactly("Day2", "Day3")
    }
    
    // ===== WEIGHT DAO TESTS =====
    
    @Test
    fun insertAndGetLatestWeightEntry() = runTest {
        // Given
        val calendar = Calendar.getInstance()
        val today = calendar.time
        
        calendar.add(Calendar.DAY_OF_YEAR, -1)
        val yesterday = calendar.time
        
        val oldEntry = WeightEntry(weight = 75.0, date = yesterday)
        val newEntry = WeightEntry(weight = 74.5, date = today)
        
        // When
        database.weightDao().insert(oldEntry)
        database.weightDao().insert(newEntry)
        
        val latest = database.weightDao().getLatestEntry()
        
        // Then
        assertThat(latest).isNotNull()
        assertThat(latest?.weight).isEqualTo(74.5)
    }
    
    @Test
    fun getRecentWeightEntries() = runTest {
        // Given
        val entries = (1..5).map { i ->
            WeightEntry(
                weight = 70.0 + i,
                date = Date(System.currentTimeMillis() - i * 86400000L) // i days ago
            )
        }
        
        // When
        entries.forEach { database.weightDao().insert(it) }
        val recent = database.weightDao().getRecentEntries(3)
        
        // Then
        assertThat(recent).hasSize(3)
        assertThat(recent[0].weight).isEqualTo(71.0) // Most recent
    }
    
    // ===== SUPPLEMENT DAO TESTS =====
    
    @Test
    fun insertAndRetrieveSupplementEntry() = runTest {
        // Given
        val supplementEntry = SupplementEntry(
            id = UUID.randomUUID(),
            name = "Vitamin D",
            brand = "HealthBrand",
            date = Date(),
            servingSize = "1",
            servingUnit = "tablet",
            nutrients = mapOf("vitaminD" to 1000.0)
        )
        
        // When
        database.supplementDao().insert(supplementEntry)
        val entries = database.supplementDao().getEntriesForDate(supplementEntry.date)
        
        // Then
        assertThat(entries).hasSize(1)
        assertThat(entries[0].name).isEqualTo("Vitamin D")
        assertThat(entries[0].nutrients["vitaminD"]).isEqualTo(1000.0)
    }
    
    @Test
    fun getAllSupplementNames() = runTest {
        // Given
        val entry1 = SupplementEntry(name = "Vitamin C", date = Date(), servingSize = "1", servingUnit = "tablet")
        val entry2 = SupplementEntry(name = "Vitamin D", date = Date(), servingSize = "1", servingUnit = "tablet")
        val entry3 = SupplementEntry(name = "Vitamin C", date = Date(), servingSize = "1", servingUnit = "tablet") // Duplicate
        
        // When
        database.supplementDao().insert(entry1)
        database.supplementDao().insert(entry2)
        database.supplementDao().insert(entry3)
        
        val names = database.supplementDao().getAllSupplementNames()
        
        // Then
        assertThat(names).hasSize(2)
        assertThat(names).containsExactly("Vitamin C", "Vitamin D")
    }
    
    // ===== CUSTOM FOOD DAO TESTS =====
    
    @Test
    fun searchCustomFoods() = runTest {
        // Given
        val food1 = CustomFood(name = "Apple Pie", brand = "HomeMade", servingSize = "1", servingUnit = "slice")
        val food2 = CustomFood(name = "Banana Bread", brand = "BakeryBrand", servingSize = "1", servingUnit = "slice")
        val food3 = CustomFood(name = "Cherry Tart", brand = "HomeMade", servingSize = "1", servingUnit = "piece")
        
        // When
        database.customFoodDao().insert(food1)
        database.customFoodDao().insert(food2)
        database.customFoodDao().insert(food3)
        
        val searchResults = database.customFoodDao().searchFoods("apple")
        
        // Then
        assertThat(searchResults).hasSize(1)
        assertThat(searchResults[0].name).isEqualTo("Apple Pie")
    }
    
    @Test
    fun getFoodByBarcode() = runTest {
        // Given
        val food = CustomFood(
            name = "Test Product",
            barcode = "123456789",
            servingSize = "1",
            servingUnit = "package"
        )
        
        // When
        database.customFoodDao().insert(food)
        val found = database.customFoodDao().getFoodByBarcode("123456789")
        
        // Then
        assertThat(found).isNotNull()
        assertThat(found?.name).isEqualTo("Test Product")
    }
    
    // Helper function
    private fun createFoodEntry(
        name: String,
        mealType: String,
        date: Date,
        calories: Double = 100.0,
        servingCount: Double = 1.0
    ): FoodEntry {
        return FoodEntry(
            id = UUID.randomUUID(),
            name = name,
            date = date,
            mealType = mealType,
            servingSize = "1",
            servingUnit = "serving",
            servingCount = servingCount,
            calories = calories,
            protein = 10.0,
            carbs = 20.0,
            fat = 5.0
        )
    }
}