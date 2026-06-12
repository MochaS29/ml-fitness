// RDA values sourced from:
//   - USDA Dietary Guidelines for Americans 2020-2025
//   - Institute of Medicine / National Academies DRI tables
//   - FDA Daily Value reference (21 CFR 101.9)
//
// Scope: macros + fiber/sugar/sodium only. Vitamins/minerals deferred until
// per-food micronutrient data is available.

package com.mochasmindlab.mlhealth.data.models

// ---------------------------------------------------------------------------
// Core data classes
// ---------------------------------------------------------------------------

/**
 * A snapshot of all nutrients we can track against RDA for a single day.
 * Calories in kcal; sodium/cholesterol in mg; all others in grams.
 */
data class RDAValues(
    val calories: Double,
    val protein: Double,
    val carbs: Double,
    val fat: Double,
    val fiber: Double,
    val sugar: Double,
    val sodium: Double,         // mg
    val saturatedFat: Double,
    val cholesterol: Double     // mg
)

/**
 * One nutrient row in the RDA analysis list.
 *
 * @param isLimit  true = "stay under" (sugar, sodium, sat-fat, cholesterol);
 *                 false = "reach at least" (calories, protein, carbs, fat, fiber).
 */
data class RDAEntry(
    val name: String,
    val current: Double,
    val goal: Double,
    val unit: String,
    val isLimit: Boolean
)

// ---------------------------------------------------------------------------
// Life-stage enum
// ---------------------------------------------------------------------------

enum class LifeStage {
    CHILD,
    TEEN_MALE,
    TEEN_FEMALE,
    ADULT_MALE_19_50,
    ADULT_MALE_51_PLUS,
    ADULT_FEMALE_19_50,
    ADULT_FEMALE_51_PLUS
}

// ---------------------------------------------------------------------------
// RDA lookup
// ---------------------------------------------------------------------------

/**
 * Returns RDA/DV preset values for a given age + gender.
 *
 * Age cut-offs:
 *   < 13  → CHILD
 *   13-18 → TEEN (male/female)
 *   19-50 → ADULT 19-50 (male/female)
 *   51+   → ADULT 51+ (male/female)
 * GENDER.OTHER uses female values (conservative baseline; mirrors iOS behaviour).
 *
 * Sources:
 *   Calories — DGA 2020-2025 estimated needs (moderate activity).
 *   Protein  — IOM DRI: 0.8 g/kg reference weight; canonical values 46/56 g.
 *   Carbs    — IOM minimum RDA 130 g (brain glucose requirement).
 *   Fat      — FDA 65 g DV (≈ 30% of 2 000 kcal); iOS default retained.
 *   Fiber    — IOM AI: 38 g male 19-50, 25 g female 19-50, 30/21 g 51+.
 *   Sugar    — WHO/AHA free-sugar limit: 50 g/day (≤10% of kcal at 2 000).
 *   Sodium   — DGA/FDA UL: 2 300 mg across all adult stages.
 *   Sat fat  — AHA recommendation: < 22 g (≤10% of 2 000 kcal).
 *   Chol     — FDA DV: 300 mg.
 */
fun rdaFor(age: Int, gender: Gender): RDAValues {
    val stage = when {
        age < 13              -> LifeStage.CHILD
        age <= 18 && gender == Gender.MALE   -> LifeStage.TEEN_MALE
        age <= 18             -> LifeStage.TEEN_FEMALE
        age <= 50 && gender == Gender.MALE   -> LifeStage.ADULT_MALE_19_50
        age <= 50             -> LifeStage.ADULT_FEMALE_19_50
        gender == Gender.MALE -> LifeStage.ADULT_MALE_51_PLUS
        else                  -> LifeStage.ADULT_FEMALE_51_PLUS
    }
    return when (stage) {
        LifeStage.ADULT_MALE_19_50 -> RDAValues(
            calories = 2500.0, protein = 56.0, carbs = 130.0, fat = 65.0,
            fiber = 38.0, sugar = 50.0, sodium = 2300.0,
            saturatedFat = 22.0, cholesterol = 300.0
        )
        LifeStage.ADULT_MALE_51_PLUS -> RDAValues(
            calories = 2200.0, protein = 56.0, carbs = 130.0, fat = 65.0,
            fiber = 30.0, sugar = 50.0, sodium = 2300.0,
            saturatedFat = 20.0, cholesterol = 300.0
        )
        LifeStage.ADULT_FEMALE_19_50 -> RDAValues(
            calories = 2000.0, protein = 46.0, carbs = 130.0, fat = 65.0,
            fiber = 25.0, sugar = 50.0, sodium = 2300.0,
            saturatedFat = 22.0, cholesterol = 300.0
        )
        LifeStage.ADULT_FEMALE_51_PLUS -> RDAValues(
            calories = 1800.0, protein = 46.0, carbs = 130.0, fat = 65.0,
            fiber = 21.0, sugar = 50.0, sodium = 2300.0,
            saturatedFat = 20.0, cholesterol = 300.0
        )
        LifeStage.TEEN_MALE -> RDAValues(
            calories = 2800.0, protein = 52.0, carbs = 130.0, fat = 73.0,
            fiber = 38.0, sugar = 50.0, sodium = 2300.0,
            saturatedFat = 25.0, cholesterol = 300.0
        )
        LifeStage.TEEN_FEMALE -> RDAValues(
            calories = 2200.0, protein = 46.0, carbs = 130.0, fat = 65.0,
            fiber = 26.0, sugar = 50.0, sodium = 2300.0,
            saturatedFat = 22.0, cholesterol = 300.0
        )
        LifeStage.CHILD -> RDAValues(
            calories = 1800.0, protein = 34.0, carbs = 130.0, fat = 55.0,
            fiber = 20.0, sugar = 25.0, sodium = 1900.0,
            saturatedFat = 17.0, cholesterol = 300.0
        )
    }
}
