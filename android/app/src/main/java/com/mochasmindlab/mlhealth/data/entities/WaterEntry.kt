package com.mochasmindlab.mlhealth.data.entities

import androidx.room.Entity
import androidx.room.PrimaryKey
import java.util.*

enum class WaterUnit {
    OZ, ML, CUP, L
}

@Entity(tableName = "water_entries")
data class WaterEntry(
    @PrimaryKey
    val id: String = UUID.randomUUID().toString(),
    val amount: Float, // in oz by default
    val unit: WaterUnit = WaterUnit.OZ,
    val timestamp: Date = Date(),
    val note: String? = null
) {
    fun getAmountInOz(): Float {
        return when (unit) {
            WaterUnit.OZ -> amount
            WaterUnit.ML -> amount * 0.033814f
            WaterUnit.CUP -> amount * 8f
            WaterUnit.L -> amount * 33.814f
        }
    }

    fun getAmountInMl(): Float {
        return when (unit) {
            WaterUnit.OZ -> amount * 29.5735f
            WaterUnit.ML -> amount
            WaterUnit.CUP -> amount * 236.588f
            WaterUnit.L -> amount * 1000f
        }
    }
}