package com.mochasmindlab.mlhealth.utils

import com.mochasmindlab.mlhealth.data.entities.*
import com.mochasmindlab.mlhealth.data.models.FoodItem
import com.mochasmindlab.mlhealth.data.repository.*
import java.util.*
import javax.inject.Inject
import javax.inject.Singleton
import kotlin.random.Random

@Singleton
class DemoDataGenerator @Inject constructor(
    private val foodRepository: FoodRepository,
    private val exerciseRepository: ExerciseRepository,
    private val weightRepository: WeightRepository,
    private val waterRepository: WaterRepository,
    private val supplementRepository: SupplementRepository
) {

    suspend fun generateDemoData(daysBack: Int = 30) {
        generateFoodData(daysBack)
        generateExerciseData(daysBack)
        generateWeightData(daysBack)
        generateWaterData(daysBack)
        generateSupplementData(daysBack)
    }

    private suspend fun generateFoodData(daysBack: Int) {
        val calendar = Calendar.getInstance()
        val foods = getDemoFoods()

        for (day in 0 until daysBack) {
            calendar.time = Date()
            calendar.add(Calendar.DAY_OF_MONTH, -day)
            val date = calendar.time

            // Breakfast
            generateMealEntries(date, "BREAKFAST", foods.filter { it.category == "Breakfast" }, 1..2)

            // Lunch
            generateMealEntries(date, "LUNCH", foods.filter { it.category == "Lunch" }, 2..3)

            // Dinner
            generateMealEntries(date, "DINNER", foods.filter { it.category == "Dinner" }, 2..3)

            // Snacks
            generateMealEntries(date, "SNACK", foods.filter { it.category == "Snack" }, 0..2)
        }
    }

    private suspend fun generateMealEntries(
        date: Date,
        mealType: String,
        foods: List<DemoFood>,
        countRange: IntRange
    ) {
        val count = Random.nextInt(countRange.first, countRange.last + 1)
        val selectedFoods = foods.shuffled().take(count)

        selectedFoods.forEach { food ->
            val entry = FoodEntry(
                id = UUID.randomUUID().toString(),
                name = food.name,
                brand = food.brand,
                calories = food.calories,
                protein = food.protein,
                carbs = food.carbs,
                fat = food.fat,
                fiber = food.fiber ?: 0.0,
                sugar = food.sugar ?: 0.0,
                sodium = food.sodium ?: 0.0,
                servingSize = food.servingSize,
                servingUnit = food.servingUnit,
                servingCount = Random.nextDouble(0.5, 2.0).round(1),
                mealType = mealType,
                date = date,
                timestamp = date,
                barcode = null,
                imageUrl = null
            )
            foodRepository.addFoodEntry(entry)
        }
    }

    private suspend fun generateExerciseData(daysBack: Int) {
        val calendar = Calendar.getInstance()
        val exercises = getDemoExercises()

        for (day in 0 until daysBack) {
            calendar.time = Date()
            calendar.add(Calendar.DAY_OF_MONTH, -day)
            val date = calendar.time

            // 70% chance of exercise on any given day
            if (Random.nextDouble() < 0.7) {
                val exerciseCount = Random.nextInt(1, 4)
                val selectedExercises = exercises.shuffled().take(exerciseCount)

                selectedExercises.forEach { exercise ->
                    val duration = Random.nextInt(exercise.minDuration, exercise.maxDuration + 1)
                    val caloriesBurned = (exercise.caloriesPerMinute * duration).toInt()

                    val entry = ExerciseEntry(
                        id = UUID.randomUUID().toString(),
                        name = exercise.name,
                        category = exercise.category,
                        duration = duration,
                        caloriesBurned = caloriesBurned,
                        distance = if (exercise.hasDistance) Random.nextDouble(1.0, 10.0).round(1) else null,
                        distanceUnit = if (exercise.hasDistance) "km" else null,
                        notes = null,
                        date = date,
                        timestamp = date
                    )
                    exerciseRepository.addExerciseEntry(entry)
                }
            }
        }
    }

    private suspend fun generateWeightData(daysBack: Int) {
        val calendar = Calendar.getInstance()
        var currentWeight = 70.0 + Random.nextDouble(-5.0, 5.0) // Start around 70kg

        for (day in 0 until daysBack) {
            calendar.time = Date()
            calendar.add(Calendar.DAY_OF_MONTH, -day)
            val date = calendar.time

            // Weight entry every 2-3 days
            if (day % Random.nextInt(2, 4) == 0) {
                // Gradual weight change
                currentWeight += Random.nextDouble(-0.3, 0.2)

                val entry = WeightEntry(
                    id = UUID.randomUUID().toString(),
                    weight = currentWeight.round(1),
                    unit = "kg",
                    date = date,
                    timestamp = date,
                    bodyFatPercentage = if (Random.nextBoolean()) Random.nextDouble(15.0, 30.0).round(1) else null,
                    muscleMass = if (Random.nextBoolean()) Random.nextDouble(25.0, 40.0).round(1) else null,
                    notes = null
                )
                weightRepository.addWeightEntry(entry)
            }
        }
    }

    private suspend fun generateWaterData(daysBack: Int) {
        val calendar = Calendar.getInstance()

        for (day in 0 until daysBack) {
            calendar.time = Date()
            calendar.add(Calendar.DAY_OF_MONTH, -day)

            // Generate 4-10 water entries per day
            val entriesCount = Random.nextInt(4, 11)

            for (i in 0 until entriesCount) {
                calendar.set(Calendar.HOUR_OF_DAY, Random.nextInt(6, 22))
                calendar.set(Calendar.MINUTE, Random.nextInt(0, 60))

                val amounts = listOf(8f, 12f, 16f, 16.9f, 20f, 24f) // Common water amounts in oz

                val entry = WaterEntry(
                    id = UUID.randomUUID().toString(),
                    amount = amounts.random(),
                    unit = WaterUnit.OZ,
                    timestamp = calendar.time
                )
                waterRepository.addWaterEntry(entry)
            }
        }
    }

    private suspend fun generateSupplementData(daysBack: Int) {
        val calendar = Calendar.getInstance()
        val supplements = getDemoSupplements()

        for (day in 0 until daysBack) {
            calendar.time = Date()
            calendar.add(Calendar.DAY_OF_MONTH, -day)
            val date = calendar.time

            // 80% chance of taking supplements
            if (Random.nextDouble() < 0.8) {
                val selectedSupplements = supplements.shuffled().take(Random.nextInt(1, 4))

                selectedSupplements.forEach { supplement ->
                    val entry = SupplementEntry(
                        id = UUID.randomUUID().toString(),
                        name = supplement.name,
                        brand = supplement.brand,
                        dosage = supplement.dosage,
                        unit = supplement.unit,
                        quantity = 1,
                        date = date,
                        timestamp = date,
                        notes = null
                    )
                    supplementRepository.addSupplementEntry(entry)
                }
            }
        }
    }

    private fun getDemoFoods(): List<DemoFood> = listOf(
        // Breakfast
        DemoFood("Oatmeal with Berries", "Quaker", "Breakfast", 150.0, 5.0, 27.0, 3.0, 4.0, 6.0, 0.0, "1", "cup"),
        DemoFood("Greek Yogurt", "Chobani", "Breakfast", 130.0, 14.0, 11.0, 3.5, 0.0, 9.0, 65.0, "150", "g"),
        DemoFood("Scrambled Eggs", null, "Breakfast", 180.0, 12.0, 2.0, 14.0, 0.0, 1.0, 180.0, "2", "eggs"),
        DemoFood("Whole Wheat Toast", "Dave's Killer", "Breakfast", 110.0, 5.0, 22.0, 1.5, 5.0, 5.0, 170.0, "1", "slice"),
        DemoFood("Smoothie Bowl", null, "Breakfast", 280.0, 8.0, 45.0, 10.0, 6.0, 25.0, 45.0, "1", "bowl"),

        // Lunch
        DemoFood("Grilled Chicken Salad", null, "Lunch", 320.0, 35.0, 15.0, 15.0, 5.0, 8.0, 480.0, "1", "salad"),
        DemoFood("Turkey Sandwich", "Subway", "Lunch", 280.0, 18.0, 46.0, 4.5, 5.0, 7.0, 850.0, "6", "inch"),
        DemoFood("Quinoa Bowl", null, "Lunch", 380.0, 14.0, 55.0, 12.0, 8.0, 6.0, 320.0, "1", "bowl"),
        DemoFood("Salmon Wrap", null, "Lunch", 420.0, 28.0, 35.0, 18.0, 4.0, 5.0, 620.0, "1", "wrap"),
        DemoFood("Veggie Burger", "Beyond", "Lunch", 250.0, 20.0, 20.0, 14.0, 3.0, 3.0, 390.0, "1", "patty"),

        // Dinner
        DemoFood("Grilled Salmon", null, "Dinner", 367.0, 40.0, 0.0, 22.0, 0.0, 0.0, 90.0, "6", "oz"),
        DemoFood("Chicken Stir Fry", null, "Dinner", 420.0, 32.0, 38.0, 15.0, 4.0, 12.0, 890.0, "1.5", "cups"),
        DemoFood("Pasta Primavera", null, "Dinner", 380.0, 12.0, 58.0, 12.0, 6.0, 8.0, 420.0, "1.5", "cups"),
        DemoFood("Beef Tacos", null, "Dinner", 450.0, 28.0, 35.0, 22.0, 5.0, 4.0, 780.0, "3", "tacos"),
        DemoFood("Vegetable Curry", null, "Dinner", 320.0, 10.0, 48.0, 12.0, 8.0, 10.0, 580.0, "1.5", "cups"),

        // Snacks
        DemoFood("Apple", null, "Snack", 95.0, 0.5, 25.0, 0.3, 4.0, 19.0, 2.0, "1", "medium"),
        DemoFood("Protein Bar", "Quest", "Snack", 190.0, 20.0, 22.0, 8.0, 14.0, 1.0, 140.0, "1", "bar"),
        DemoFood("Mixed Nuts", "Planters", "Snack", 170.0, 6.0, 7.0, 15.0, 3.0, 1.0, 95.0, "28", "g"),
        DemoFood("Banana", null, "Snack", 105.0, 1.3, 27.0, 0.4, 3.0, 14.0, 1.0, "1", "medium"),
        DemoFood("Dark Chocolate", "Lindt", "Snack", 155.0, 1.4, 17.0, 9.0, 2.0, 14.0, 4.0, "30", "g")
    )

    private fun getDemoExercises(): List<DemoExercise> = listOf(
        DemoExercise("Running", "Cardio", 10.0, 15, 45, true),
        DemoExercise("Cycling", "Cardio", 8.0, 20, 60, true),
        DemoExercise("Swimming", "Cardio", 11.0, 20, 45, true),
        DemoExercise("Weight Training", "Strength", 6.0, 30, 60, false),
        DemoExercise("Yoga", "Flexibility", 3.0, 30, 90, false),
        DemoExercise("Walking", "Cardio", 4.0, 20, 60, true),
        DemoExercise("HIIT", "Cardio", 12.0, 15, 30, false),
        DemoExercise("Pilates", "Flexibility", 4.0, 30, 60, false),
        DemoExercise("Boxing", "Cardio", 9.0, 20, 45, false),
        DemoExercise("Dancing", "Cardio", 7.0, 30, 60, false)
    )

    private fun getDemoSupplements(): List<DemoSupplement> = listOf(
        DemoSupplement("Vitamin D3", "Nature Made", 2000.0, "IU"),
        DemoSupplement("Omega-3", "Nordic Naturals", 1000.0, "mg"),
        DemoSupplement("Multivitamin", "Centrum", 1.0, "tablet"),
        DemoSupplement("Vitamin C", "NOW Foods", 1000.0, "mg"),
        DemoSupplement("Probiotic", "Garden of Life", 50.0, "billion CFU"),
        DemoSupplement("Magnesium", "Natural Vitality", 325.0, "mg"),
        DemoSupplement("B-Complex", "Thorne", 1.0, "capsule"),
        DemoSupplement("Iron", "Solgar", 25.0, "mg"),
        DemoSupplement("Zinc", "Pure Encapsulations", 30.0, "mg"),
        DemoSupplement("Calcium", "Citracal", 630.0, "mg")
    )

    private fun Double.round(decimals: Int): Double {
        var multiplier = 1.0
        repeat(decimals) { multiplier *= 10 }
        return kotlin.math.round(this * multiplier) / multiplier
    }

    // Helper data classes
    private data class DemoFood(
        val name: String,
        val brand: String?,
        val category: String,
        val calories: Double,
        val protein: Double,
        val carbs: Double,
        val fat: Double,
        val fiber: Double?,
        val sugar: Double?,
        val sodium: Double?,
        val servingSize: String,
        val servingUnit: String
    )

    private data class DemoExercise(
        val name: String,
        val category: String,
        val caloriesPerMinute: Double,
        val minDuration: Int,
        val maxDuration: Int,
        val hasDistance: Boolean
    )

    private data class DemoSupplement(
        val name: String,
        val brand: String,
        val dosage: Double,
        val unit: String
    )
}