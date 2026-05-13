package com.mochasmindlab.mlhealth.data.models

import android.os.Parcelable
import androidx.room.Entity
import androidx.room.PrimaryKey
import kotlinx.parcelize.Parcelize
import java.util.Date

// @Parcelize lets Compose/NavController save FoodItem through process death.
// Without this, scanning a barcode crashed with "Can't put value with type class
// FoodItem into saved state" when the OS reaped the activity.
@Parcelize
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
    val lastLogged: Date? = null,
    val logCount: Int = 0,
    val createdAt: Date = Date()
) : Parcelable