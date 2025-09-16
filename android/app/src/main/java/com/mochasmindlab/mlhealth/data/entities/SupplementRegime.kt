package com.mochasmindlab.mlhealth.data.entities

import androidx.room.Entity
import androidx.room.PrimaryKey
import java.util.UUID

@Entity(tableName = "supplement_regimes")
data class SupplementRegime(
    @PrimaryKey
    val id: UUID = UUID.randomUUID(),
    val name: String, // e.g., "Morning Vitamins", "Daily Stack"
    val supplements: List<RegimeSupplement> = emptyList(),
    val isActive: Boolean = true,
    val createdAt: Long = System.currentTimeMillis(),
    val updatedAt: Long = System.currentTimeMillis()
)

data class RegimeSupplement(
    val name: String,
    val brand: String? = null,
    val servingSize: String,
    val servingUnit: String,
    val servingCount: Double = 1.0,
    val barcode: String? = null,
    val nutrients: Map<String, Double> = emptyMap(),
    val notes: String? = null
)