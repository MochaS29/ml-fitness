package com.mochasmindlab.mlhealth.utils

import com.mochasmindlab.mlhealth.data.models.WeightUnit
import kotlin.math.roundToInt

object UnitConversions {
    
    // Weight conversions
    fun kgToLbs(kg: Float): Float = kg * 2.20462f
    fun lbsToKg(lbs: Float): Float = lbs / 2.20462f
    
    fun convertWeight(value: Float, from: WeightUnit, to: WeightUnit): Float {
        return when {
            from == to -> value
            from == WeightUnit.KG && to == WeightUnit.LBS -> kgToLbs(value)
            from == WeightUnit.LBS && to == WeightUnit.KG -> lbsToKg(value)
            else -> value
        }
    }
    
    fun formatWeight(weight: Float, unit: WeightUnit): String {
        return when (unit) {
            WeightUnit.KG -> String.format("%.1f kg", weight)
            WeightUnit.LBS -> String.format("%.1f lbs", weight)
        }
    }
    
    fun formatWeightShort(weight: Float, unit: WeightUnit): String {
        return when (unit) {
            WeightUnit.KG -> String.format("%.1f", weight)
            WeightUnit.LBS -> String.format("%.1f", weight)
        }
    }
    
    // Height conversions (metric to imperial)
    fun cmToFeetInches(cm: Float): Pair<Int, Int> {
        val totalInches = cm / 2.54f
        val feet = (totalInches / 12).toInt()
        val inches = (totalInches % 12).roundToInt()
        return Pair(feet, inches)
    }
    
    fun feetInchesToCm(feet: Int, inches: Int): Float {
        val totalInches = feet * 12 + inches
        return totalInches * 2.54f
    }
    
    fun formatHeight(cm: Float, isMetric: Boolean = true): String {
        return if (isMetric) {
            String.format("%.0f cm", cm)
        } else {
            val (feet, inches) = cmToFeetInches(cm)
            "$feet'$inches\""
        }
    }
    
    // Temperature conversions (for recipes/cooking)
    fun celsiusToFahrenheit(celsius: Float): Float = celsius * 9/5 + 32
    fun fahrenheitToCelsius(fahrenheit: Float): Float = (fahrenheit - 32) * 5/9
    
    // Volume conversions (for water/liquid intake)
    fun mlToOz(ml: Float): Float = ml / 29.5735f
    fun ozToMl(oz: Float): Float = oz * 29.5735f
    fun mlToCups(ml: Float): Float = ml / 236.588f
    fun cupsToMl(cups: Float): Float = cups * 236.588f
    
    // Distance conversions (for exercise)
    fun kmToMiles(km: Float): Float = km * 0.621371f
    fun milesToKm(miles: Float): Float = miles / 0.621371f
    
    fun formatDistance(distance: Float, isMetric: Boolean = true): String {
        return if (isMetric) {
            String.format("%.2f km", distance)
        } else {
            String.format("%.2f mi", kmToMiles(distance))
        }
    }
}