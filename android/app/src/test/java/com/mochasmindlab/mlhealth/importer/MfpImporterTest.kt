package com.mochasmindlab.mlhealth.importer

import com.mochasmindlab.mlhealth.data.importer.MfpImporter
import com.mochasmindlab.mlhealth.data.models.MealType
import org.junit.Assert.assertEquals
import org.junit.Assert.assertThrows
import org.junit.Assert.assertTrue
import org.junit.Test

/**
 * JVM unit tests for the pure parse / detect / map logic of the MyFitnessPal
 * importer (mirrors the iOS MFPImportTests). The Room insert + dedupe path is a
 * direct mirror of the iOS insert path, which is proven by the iOS integration
 * test running against real Core Data.
 */
class MfpImporterTest {

    @Test
    fun nutritionDetectedAndMapped() {
        val s = MfpImporter.preview(NUTRITION)
        assertEquals(MfpImporter.Kind.NUTRITION, s.kind)
        assertEquals(18, s.importableRows)
        assertEquals(0, s.skippedRows)
        assertEquals(5, s.mealCounts[MealType.BREAKFAST])
        assertEquals(3, s.mealCounts[MealType.SNACK])
        // First mapped food keeps its full macros.
        val oatmeal = s.foodEntries.first { it.name.startsWith("Oatmeal") }
        assertEquals(166.0, oatmeal.calories, 0.001)
        assertEquals(6.0, oatmeal.protein, 0.001)
    }

    @Test
    fun quotedCommaNamePreserved() {
        val s = MfpImporter.preview(NUTRITION)
        assertTrue(
            "RFC-4180 parser must keep the comma inside the quoted food name",
            s.foodEntries.any { it.name == "Oatmeal, rolled oats - 1 cup cooked" }
        )
    }

    @Test
    fun exerciseDetectedAndMapped() {
        val s = MfpImporter.preview(EXERCISE)
        assertEquals(MfpImporter.Kind.EXERCISE, s.kind)
        assertEquals(7, s.importableRows)
        val running = s.exerciseEntries.first { it.name == "Running" }
        assertEquals("Cardio", running.category)
        assertEquals(30, running.durationMinutes)
        assertEquals(320.0, running.caloriesBurned, 0.001)
        val bench = s.exerciseEntries.first { it.name == "Bench Press" }
        assertEquals("Strength", bench.category)
    }

    @Test
    fun weightDetectedAndUnitConversion() {
        val s = MfpImporter.preview(WEIGHT)
        assertEquals(MfpImporter.Kind.WEIGHT, s.kind)
        assertEquals(8, s.importableRows)
        val first = s.weightEntries.first()
        assertEquals(165.2, first.rawWeight, 0.001)
        // pounds -> unchanged; kilograms -> converted
        assertEquals(165.2, first.rawWeight * MfpImporter.WeightUnit.POUNDS.toPounds, 0.01)
        assertEquals(364.2, first.rawWeight * MfpImporter.WeightUnit.KILOGRAMS.toPounds, 0.1)
    }

    @Test
    fun unrecognizedThrows() {
        assertThrows(MfpImporter.ImportException::class.java) {
            MfpImporter.preview("Foo,Bar\n1,2\n")
        }
    }

    companion object {
        const val NUTRITION = """Date,Meal,Food,Calories,"Fat (g)","Saturated Fat","Polyunsaturated Fat","Monounsaturated Fat","Trans Fat","Cholesterol","Sodium (mg)","Potassium","Carbohydrates (g)",Fiber,Sugar,"Protein (g)","Vitamin A","Vitamin C",Calcium,Iron
2026-06-01,Breakfast,"Oatmeal, rolled oats - 1 cup cooked",166,3.6,0.6,1.3,1.1,0,0,9,164,28,4,1,6,0,0,2,10
2026-06-01,Breakfast,"Blueberries, raw - 1/2 cup",42,0.2,0,0.1,0,0,0,1,57,11,2,7,1,1,7,1,1
2026-06-01,Lunch,"Chicken breast, grilled - 6 oz",276,6,1.7,1.3,2.1,0,144,124,440,0,0,0,52,0,0,2,6
2026-06-01,Lunch,"Brown rice, cooked - 1 cup",216,1.8,0.4,0.6,0.6,0,0,10,84,45,4,0,5,0,0,2,5
2026-06-01,Dinner,"Salmon, Atlantic, baked - 5 oz",280,12.5,2.5,5,3.8,0,90,86,628,0,0,0,39,2,0,2,4
2026-06-01,Dinner,"Asparagus, boiled - 1 cup",40,0.4,0.1,0.2,0,0,0,26,404,7,3,2,4,20,14,4,16
2026-06-01,Snacks,"Greek yogurt, plain, nonfat - 1 container (170g)",100,0.7,0.2,0,0.2,0,10,68,240,6,0,4,17,0,0,20,0
2026-06-02,Breakfast,"Eggs, scrambled - 2 large",182,13,3.9,2.5,5,0,372,180,138,2,0,2,12,10,0,8,8
2026-06-02,Breakfast,"Whole wheat toast - 2 slices",138,2,0.4,0.8,0.4,0,0,264,140,24,4,3,7,0,0,6,8
2026-06-02,Lunch,"Turkey sandwich, deli - 1 sandwich",320,9,2.5,2,3,0.2,45,910,320,38,4,6,24,4,8,15,12
2026-06-02,Lunch,"Apple, medium - 1 apple",95,0.3,0.1,0.1,0,0,0,2,195,25,4,19,0,2,14,1,1
2026-06-02,Dinner,"Spaghetti with marinara, homemade - 1.5 cups",340,6,1.2,2,2.5,0,5,620,480,60,6,10,12,12,20,6,14
2026-06-02,Snacks,"Almonds, raw - 1 oz (23 nuts)",164,14,1.1,3.5,9,0,0,0,208,6,3.5,1,6,0,0,7,6
2026-06-03,Breakfast,"Protein smoothie, banana & whey - 1 serving",290,4,1.5,0.5,1,0,30,180,600,34,4,20,30,4,20,25,6
2026-06-03,Lunch,"Caesar salad with chicken - 1 bowl",470,32,7,6,15,0.3,95,1080,520,14,4,4,32,60,12,20,10
2026-06-03,Dinner,"Beef stir-fry with vegetables - 1.5 cups",410,18,5,3,8,0.5,80,890,720,26,5,9,38,80,60,6,22
2026-06-03,Dinner,"Jasmine rice, cooked - 1 cup",205,0.4,0.1,0.1,0.1,0,0,2,55,45,1,0,4,0,0,2,10
2026-06-03,Snacks,"Dark chocolate, 70% - 1 oz",170,12,7,0.4,3.5,0,5,6,200,13,3,7,2,0,0,3,20"""

        const val EXERCISE = """Date,Exercise,Type,"Exercise Calories","Exercise Minutes",Sets,Reps,Weight
2026-06-01,Running,Cardiovascular,320,30,,,
2026-06-01,"Cycling, stationary",Cardiovascular,250,40,,,
2026-06-02,"Walking, brisk",Cardiovascular,180,45,,,
2026-06-02,Bench Press,Strength Training,0,0,3,10,135
2026-06-03,Swimming,Cardiovascular,410,35,,,
2026-06-03,"Yoga, Hatha",Cardiovascular,120,50,,,
2026-06-03,Squats,Strength Training,0,0,4,8,185"""

        const val WEIGHT = """Date,Weight
2026-06-01,165.2
2026-06-05,164.1
2026-06-09,163.5
2026-06-13,162.8
2026-06-17,161.9
2026-06-21,161.2
2026-06-25,160.4
2026-06-29,159.7"""
    }
}
