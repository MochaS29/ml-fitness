package com.mochasmindlab.mlhealth.data.models

import androidx.room.Entity
import androidx.room.PrimaryKey
import java.time.LocalDateTime

@Entity(tableName = "food_items")
data class FoodItem(
    @PrimaryKey(autoGenerate = true)
    val id: Long = 0,
    val name: String,
    val brand: String? = null,
    val barcode: String? = null,
    val calories: Int,
    val protein: Float,
    val carbs: Float,
    val fat: Float,
    val fiber: Float = 0f,
    val sugar: Float = 0f,
    val sodium: Float = 0f,
    val servingSize: String = "1",
    val servingUnit: String = "serving",
    val emoji: String? = null,
    val isCustom: Boolean = false,
    val isFavorite: Boolean = false,
    val lastUsed: LocalDateTime? = null,
    val createdAt: LocalDateTime = LocalDateTime.now()
)