package com.mochasmindlab.mlhealth.utils

import com.mochasmindlab.mlhealth.data.database.MLFitnessDatabase
import com.mochasmindlab.mlhealth.data.entities.*
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.util.*
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class SampleDataGenerator @Inject constructor(
    private val database: MLFitnessDatabase
) {
    fun generateSampleData() {
        CoroutineScope(Dispatchers.IO).launch {
            // Check if data already exists
            val existingFood = database.foodDao().getEntriesForDate(Date())
            if (existingFood.isNotEmpty()) {
                return@launch // Data already exists
            }
            
            // Generate sample data for today
            val today = Date()
            val yesterday = Date(System.currentTimeMillis() - 86400000)
            val twoDaysAgo = Date(System.currentTimeMillis() - 172800000)
            val threeDaysAgo = Date(System.currentTimeMillis() - 259200000)
            val fourDaysAgo = Date(System.currentTimeMillis() - 345600000)
            val fiveDaysAgo = Date(System.currentTimeMillis() - 432000000)
            val sixDaysAgo = Date(System.currentTimeMillis() - 518400000)
            
            // Add food entries for today
            val todayFoods = listOf(
                FoodEntry(
                    name = "Oatmeal with Berries",
                    date = today,
                    mealType = "breakfast",
                    servingSize = "1",
                    servingUnit = "bowl",
                    servingCount = 1.0,
                    calories = 320.0,
                    protein = 12.0,
                    carbs = 58.0,
                    fat = 6.0,
                    timestamp = Date(today.time + 28800000) // 8 AM
                ),
                FoodEntry(
                    name = "Greek Yogurt",
                    date = today,
                    mealType = "breakfast",
                    servingSize = "150",
                    servingUnit = "g",
                    servingCount = 1.0,
                    calories = 130.0,
                    protein = 15.0,
                    carbs = 8.0,
                    fat = 4.0,
                    timestamp = Date(today.time + 29700000) // 8:15 AM
                ),
                FoodEntry(
                    name = "Grilled Chicken Salad",
                    date = today,
                    mealType = "lunch",
                    servingSize = "1",
                    servingUnit = "large",
                    servingCount = 1.0,
                    calories = 420.0,
                    protein = 35.0,
                    carbs = 20.0,
                    fat = 22.0,
                    timestamp = Date(today.time + 43200000) // 12 PM
                ),
                FoodEntry(
                    name = "Apple",
                    date = today,
                    mealType = "snack",
                    servingSize = "1",
                    servingUnit = "medium",
                    servingCount = 1.0,
                    calories = 95.0,
                    protein = 0.5,
                    carbs = 25.0,
                    fat = 0.3,
                    timestamp = Date(today.time + 54000000) // 3 PM
                ),
                FoodEntry(
                    name = "Protein Shake",
                    date = today,
                    mealType = "snack",
                    servingSize = "1",
                    servingUnit = "scoop",
                    servingCount = 1.0,
                    calories = 120.0,
                    protein = 24.0,
                    carbs = 3.0,
                    fat = 1.5,
                    timestamp = Date(today.time + 57600000) // 4 PM
                ),
                FoodEntry(
                    name = "Salmon with Quinoa",
                    date = today,
                    mealType = "dinner",
                    servingSize = "6",
                    servingUnit = "oz",
                    servingCount = 1.0,
                    calories = 485.0,
                    protein = 42.0,
                    carbs = 35.0,
                    fat = 18.0,
                    timestamp = Date(today.time + 68400000) // 7 PM
                )
            )
            
            todayFoods.forEach { database.foodDao().insert(it) }
            
            // Add water entries for today
            val waterEntries = listOf(
                WaterEntry(amount = 16.0, unit = "oz", timestamp = Date(today.time + 28800000)), // 8 AM
                WaterEntry(amount = 8.0, unit = "oz", timestamp = Date(today.time + 36000000)), // 10 AM
                WaterEntry(amount = 16.0, unit = "oz", timestamp = Date(today.time + 43200000)), // 12 PM
                WaterEntry(amount = 8.0, unit = "oz", timestamp = Date(today.time + 54000000)), // 3 PM
                WaterEntry(amount = 16.0, unit = "oz", timestamp = Date(today.time + 61200000)) // 5 PM
            )
            
            waterEntries.forEach { database.waterDao().insert(it) }
            
            // Add exercise entries for today
            val exerciseEntries = listOf(
                ExerciseEntry(
                    name = "Morning Run",
                    category = "cardio",
                    type = "running",
                    date = today,
                    duration = 30,
                    caloriesBurned = 320.0,
                    timestamp = Date(today.time + 25200000) // 7 AM
                ),
                ExerciseEntry(
                    name = "Weight Training - Upper Body",
                    category = "strength",
                    type = "weights",
                    date = today,
                    duration = 45,
                    caloriesBurned = 180.0,
                    timestamp = Date(today.time + 61200000) // 5 PM
                )
            )
            
            exerciseEntries.forEach { database.exerciseDao().insert(it) }
            
            // Add weight entries for the past week
            val weightEntries = listOf(
                WeightEntry(weight = 165.5, date = today),
                WeightEntry(weight = 166.0, date = yesterday),
                WeightEntry(weight = 166.2, date = twoDaysAgo),
                WeightEntry(weight = 166.8, date = threeDaysAgo),
                WeightEntry(weight = 167.0, date = fourDaysAgo),
                WeightEntry(weight = 167.2, date = fiveDaysAgo),
                WeightEntry(weight = 167.3, date = sixDaysAgo)
            )
            
            weightEntries.forEach { database.weightDao().insert(it) }
            
            // Add supplement entries for today
            val supplementEntries = listOf(
                SupplementEntry(
                    name = "Multivitamin",
                    brand = "NatureMade",
                    date = today,
                    servingSize = "1",
                    servingUnit = "tablet",
                    nutrients = mapOf(
                        "Vitamin A" to 900.0,
                        "Vitamin C" to 90.0,
                        "Vitamin D" to 25.0,
                        "Vitamin E" to 15.0,
                        "Vitamin K" to 120.0
                    ),
                    timestamp = Date(today.time + 28800000) // 8 AM
                ),
                SupplementEntry(
                    name = "Omega-3",
                    brand = "Nordic Naturals",
                    date = today,
                    servingSize = "2",
                    servingUnit = "softgels",
                    nutrients = mapOf(
                        "EPA" to 650.0,
                        "DHA" to 450.0
                    ),
                    timestamp = Date(today.time + 28800000) // 8 AM
                ),
                SupplementEntry(
                    name = "Vitamin D3",
                    brand = "NOW Foods",
                    date = today,
                    servingSize = "1",
                    servingUnit = "softgel",
                    nutrients = mapOf(
                        "Vitamin D3" to 50.0 // 2000 IU
                    ),
                    timestamp = Date(today.time + 43200000) // 12 PM
                )
            )
            
            supplementEntries.forEach { database.supplementDao().insert(it) }
            
            // Add some historical data for charts
            for (i in 1..6) {
                val date = Date(System.currentTimeMillis() - (i * 86400000L))
                
                // Add food entries
                val historicalFoods = listOf(
                    FoodEntry(
                        name = "Breakfast Meal",
                        date = date,
                        mealType = "breakfast",
                        servingSize = "1",
                        servingUnit = "meal",
                        servingCount = 1.0,
                        calories = 400.0 + (Math.random() * 100 - 50),
                        protein = 20.0 + (Math.random() * 10 - 5),
                        carbs = 50.0 + (Math.random() * 20 - 10),
                        fat = 15.0 + (Math.random() * 5 - 2.5)
                    ),
                    FoodEntry(
                        name = "Lunch Meal",
                        date = date,
                        mealType = "lunch",
                        servingSize = "1",
                        servingUnit = "meal",
                        servingCount = 1.0,
                        calories = 600.0 + (Math.random() * 100 - 50),
                        protein = 35.0 + (Math.random() * 10 - 5),
                        carbs = 60.0 + (Math.random() * 20 - 10),
                        fat = 25.0 + (Math.random() * 5 - 2.5)
                    ),
                    FoodEntry(
                        name = "Dinner Meal",
                        date = date,
                        mealType = "dinner",
                        servingSize = "1",
                        servingUnit = "meal",
                        servingCount = 1.0,
                        calories = 700.0 + (Math.random() * 100 - 50),
                        protein = 40.0 + (Math.random() * 10 - 5),
                        carbs = 70.0 + (Math.random() * 20 - 10),
                        fat = 30.0 + (Math.random() * 5 - 2.5)
                    )
                )
                historicalFoods.forEach { database.foodDao().insert(it) }
                
                // Add water
                val waterAmount = 48.0 + (Math.random() * 32 - 16) // 48-80 oz
                database.waterDao().insert(WaterEntry(amount = waterAmount, unit = "oz", timestamp = date))
                
                // Add exercise
                if (i % 2 == 0) { // Exercise every other day
                    database.exerciseDao().insert(
                        ExerciseEntry(
                            name = "Workout",
                            category = "mixed",
                            type = "general",
                            date = date,
                            duration = (30 + Math.random() * 30).toInt(),
                            caloriesBurned = 200.0 + Math.random() * 200
                        )
                    )
                }
            }
        }
    }
}