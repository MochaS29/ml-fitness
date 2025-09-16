package com.mochasmindlab.mlhealth.utils

import com.google.common.truth.Truth.assertThat
import com.mochasmindlab.mlhealth.data.models.WeightUnit
import org.junit.Test

class UnitConversionsTest {
    
    @Test
    fun `kgToLbs should convert correctly`() {
        // Given
        val kg = 70f
        
        // When
        val lbs = UnitConversions.kgToLbs(kg)
        
        // Then
        assertThat(lbs).isWithin(0.1f).of(154.32f) // 70 * 2.20462
    }
    
    @Test
    fun `lbsToKg should convert correctly`() {
        // Given
        val lbs = 150f
        
        // When
        val kg = UnitConversions.lbsToKg(lbs)
        
        // Then
        assertThat(kg).isWithin(0.1f).of(68.04f) // 150 / 2.20462
    }
    
    @Test
    fun `convertWeight should return same value when units are equal`() {
        // Given
        val value = 75f
        
        // When
        val resultKg = UnitConversions.convertWeight(value, WeightUnit.KG, WeightUnit.KG)
        val resultLbs = UnitConversions.convertWeight(value, WeightUnit.LBS, WeightUnit.LBS)
        
        // Then
        assertThat(resultKg).isEqualTo(value)
        assertThat(resultLbs).isEqualTo(value)
    }
    
    @Test
    fun `convertWeight should convert kg to lbs correctly`() {
        // Given
        val kg = 80f
        
        // When
        val lbs = UnitConversions.convertWeight(kg, WeightUnit.KG, WeightUnit.LBS)
        
        // Then
        assertThat(lbs).isWithin(0.1f).of(176.37f)
    }
    
    @Test
    fun `convertWeight should convert lbs to kg correctly`() {
        // Given
        val lbs = 200f
        
        // When
        val kg = UnitConversions.convertWeight(lbs, WeightUnit.LBS, WeightUnit.KG)
        
        // Then
        assertThat(kg).isWithin(0.1f).of(90.72f)
    }
    
    @Test
    fun `formatWeight should format kg correctly`() {
        // Given
        val weight = 75.5f
        
        // When
        val formatted = UnitConversions.formatWeight(weight, WeightUnit.KG)
        
        // Then
        assertThat(formatted).isEqualTo("75.5 kg")
    }
    
    @Test
    fun `formatWeight should format lbs correctly`() {
        // Given
        val weight = 165.3f
        
        // When
        val formatted = UnitConversions.formatWeight(weight, WeightUnit.LBS)
        
        // Then
        assertThat(formatted).isEqualTo("165.3 lbs")
    }
    
    @Test
    fun `cmToFeetInches should convert correctly`() {
        // Given
        val cm = 180f // Should be 5'11"
        
        // When
        val (feet, inches) = UnitConversions.cmToFeetInches(cm)
        
        // Then
        assertThat(feet).isEqualTo(5)
        assertThat(inches).isEqualTo(11)
    }
    
    @Test
    fun `cmToFeetInches should handle edge cases`() {
        // Test exact feet conversion
        val cm1 = 182.88f // Exactly 6 feet
        val (feet1, inches1) = UnitConversions.cmToFeetInches(cm1)
        assertThat(feet1).isEqualTo(6)
        assertThat(inches1).isIn(0..1) // Allow for rounding
        
        // Test small height
        val cm2 = 152.4f // 5 feet
        val (feet2, inches2) = UnitConversions.cmToFeetInches(cm2)
        assertThat(feet2).isEqualTo(5)
        assertThat(inches2).isEqualTo(0)
    }
    
    @Test
    fun `feetInchesToCm should convert correctly`() {
        // Given
        val feet = 5
        val inches = 10
        
        // When
        val cm = UnitConversions.feetInchesToCm(feet, inches)
        
        // Then
        // (5 * 12 + 10) * 2.54 = 70 * 2.54 = 177.8
        assertThat(cm).isWithin(0.1f).of(177.8f)
    }
    
    @Test
    fun `feetInchesToCm should handle zero inches`() {
        // Given
        val feet = 6
        val inches = 0
        
        // When
        val cm = UnitConversions.feetInchesToCm(feet, inches)
        
        // Then
        // 6 * 12 * 2.54 = 182.88
        assertThat(cm).isWithin(0.1f).of(182.88f)
    }
    
    @Test
    fun `formatHeight should format metric correctly`() {
        // Given
        val cm = 175.5f
        
        // When
        val formatted = UnitConversions.formatHeight(cm, isMetric = true)
        
        // Then
        assertThat(formatted).isEqualTo("176 cm") // Rounded
    }
    
    @Test
    fun `formatHeight should format imperial correctly`() {
        // Given
        val cm = 180f
        
        // When
        val formatted = UnitConversions.formatHeight(cm, isMetric = false)
        
        // Then
        assertThat(formatted).isEqualTo("5'11\"")
    }
    
    @Test
    fun `mlToOz should convert correctly`() {
        // Given
        val ml = 250f
        
        // When
        val oz = UnitConversions.mlToOz(ml)
        
        // Then
        assertThat(oz).isWithin(0.1f).of(8.45f) // 250 / 29.5735
    }
    
    @Test
    fun `ozToMl should convert correctly`() {
        // Given
        val oz = 8f
        
        // When
        val ml = UnitConversions.ozToMl(oz)
        
        // Then
        assertThat(ml).isWithin(0.1f).of(236.59f) // 8 * 29.5735
    }
    
    @Test
    fun `mlToCups should convert correctly`() {
        // Given
        val ml = 500f
        
        // When
        val cups = UnitConversions.mlToCups(ml)
        
        // Then
        assertThat(cups).isWithin(0.01f).of(2.11f) // 500 / 236.588
    }
    
    @Test
    fun `cupsToMl should convert correctly`() {
        // Given
        val cups = 2f
        
        // When
        val ml = UnitConversions.cupsToMl(cups)
        
        // Then
        assertThat(ml).isWithin(0.1f).of(473.18f) // 2 * 236.588
    }
    
    @Test
    fun `kmToMiles should convert correctly`() {
        // Given
        val km = 5f
        
        // When
        val miles = UnitConversions.kmToMiles(km)
        
        // Then
        assertThat(miles).isWithin(0.01f).of(3.11f) // 5 * 0.621371
    }
    
    @Test
    fun `milesToKm should convert correctly`() {
        // Given
        val miles = 3f
        
        // When
        val km = UnitConversions.milesToKm(miles)
        
        // Then
        assertThat(km).isWithin(0.01f).of(4.83f) // 3 / 0.621371
    }
    
    @Test
    fun `formatDistance should format metric correctly`() {
        // Given
        val km = 5.5f
        
        // When
        val formatted = UnitConversions.formatDistance(km, isMetric = true)
        
        // Then
        assertThat(formatted).isEqualTo("5.50 km")
    }
    
    @Test
    fun `formatDistance should format imperial correctly`() {
        // Given
        val km = 10f
        
        // When
        val formatted = UnitConversions.formatDistance(km, isMetric = false)
        
        // Then
        assertThat(formatted).isEqualTo("6.21 mi")
    }
    
    @Test
    fun `celsiusToFahrenheit should convert correctly`() {
        // Given
        val celsius = 25f
        
        // When
        val fahrenheit = UnitConversions.celsiusToFahrenheit(celsius)
        
        // Then
        assertThat(fahrenheit).isWithin(0.1f).of(77f) // 25 * 9/5 + 32
    }
    
    @Test
    fun `fahrenheitToCelsius should convert correctly`() {
        // Given
        val fahrenheit = 98.6f
        
        // When
        val celsius = UnitConversions.fahrenheitToCelsius(fahrenheit)
        
        // Then
        assertThat(celsius).isWithin(0.1f).of(37f) // (98.6 - 32) * 5/9
    }
}