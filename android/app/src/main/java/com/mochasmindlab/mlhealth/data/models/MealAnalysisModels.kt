package com.mochasmindlab.mlhealth.data.models

import kotlinx.serialization.Serializable

@Serializable
data class MealAnalysis(
    val items: List<DetectedFood>,
    val totalCalories: Int,
    val confidence: Double
)

@Serializable
data class DetectedFood(
    val name: String,
    val quantity: String,
    val calories: Double,
    val protein: Double,
    val carbs: Double,
    val fat: Double,
    val fiber: Double? = null,
    val confidence: Double
)
