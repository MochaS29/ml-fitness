package com.mochasmindlab.mlhealth.data.models

import java.util.Date

// ===== PERIOD ENUM =====

enum class Period { DAY, WEEK, MONTH }

// ===== PER-DAY TOTALS (used for Week/Month bar chart data) =====

data class DailyTotals(
    val date: Date,
    val calories: Double,
    val protein: Double,
    val carbs: Double,
    val fat: Double,
    val fiber: Double,
    val sugar: Double,
    val sodium: Double
)

// ===== PER-MEAL BREAKDOWN (used for Today's per-meal bar chart) =====

data class MealTotals(
    val mealType: String,   // "Breakfast", "Lunch", "Dinner", "Snack"
    val calories: Double
)

// ===== TODAY'S FULL TOTALS + MEAL BREAKDOWN =====

data class NutritionDailyTotals(
    val calories: Double = 0.0,
    val protein: Double = 0.0,
    val carbs: Double = 0.0,
    val fat: Double = 0.0,
    val fiber: Double = 0.0,
    val sugar: Double = 0.0,
    val sodium: Double = 0.0,
    val mealBreakdown: List<MealTotals> = emptyList()
)

// ===== MACRO GOALS =====

data class MacroGoals(
    val calories: Int = 2000,
    val protein: Double = 50.0,
    val carbs: Double = 275.0,
    val fat: Double = 65.0,
    val fiber: Double = 28.0,
    val sugar: Double = 50.0,    // daily limit
    val sodium: Double = 2300.0  // daily limit (mg)
)
