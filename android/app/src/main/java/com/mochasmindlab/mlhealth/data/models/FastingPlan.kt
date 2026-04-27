package com.mochasmindlab.mlhealth.data.models

enum class FastingPlan(
    val displayName: String,
    val fastHours: Double,
    val eatHours: Double
) {
    SIXTEEN_EIGHT("16:8", 16.0, 8.0),
    EIGHTEEN_SIX("18:6", 18.0, 6.0),
    TWENTY_FOUR("20:4", 20.0, 4.0),
    FOURTEEN_TEN("14:10", 14.0, 10.0),
    OMAD("OMAD", 23.0, 1.0),
    CUSTOM("Custom", 16.0, 8.0)
}
