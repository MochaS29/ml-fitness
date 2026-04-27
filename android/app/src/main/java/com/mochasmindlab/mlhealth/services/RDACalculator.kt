package com.mochasmindlab.mlhealth.services

import com.mochasmindlab.mlhealth.data.models.Gender
import com.mochasmindlab.mlhealth.data.models.RDAEntry
import com.mochasmindlab.mlhealth.data.models.RDAValues
import com.mochasmindlab.mlhealth.data.models.rdaFor
import javax.inject.Inject
import javax.inject.Singleton

/**
 * Stateless service that maps a consumed [RDAValues] snapshot against
 * the age/gender-adjusted RDA targets and returns a ranked list of
 * [RDAEntry] objects ready for display.
 *
 * Nutrients are returned in display order: macro goals first, limits last.
 */
@Singleton
class RDACalculator @Inject constructor() {

    /**
     * Produce one [RDAEntry] per tracked nutrient.
     *
     * @param consumed  Totals logged by the user today.
     * @param age       User age (from PreferencesManager.userProfile).
     * @param gender    User gender (from PreferencesManager.userProfile).
     */
    fun analyze(consumed: RDAValues, age: Int, gender: Gender): List<RDAEntry> {
        val goal = rdaFor(age, gender)
        return listOf(
            // ---- Goals (reach at least) ----
            RDAEntry(
                name = "Calories",
                current = consumed.calories,
                goal = goal.calories,
                unit = "kcal",
                isLimit = false
            ),
            RDAEntry(
                name = "Protein",
                current = consumed.protein,
                goal = goal.protein,
                unit = "g",
                isLimit = false
            ),
            RDAEntry(
                name = "Carbohydrates",
                current = consumed.carbs,
                goal = goal.carbs,
                unit = "g",
                isLimit = false
            ),
            RDAEntry(
                name = "Total Fat",
                current = consumed.fat,
                goal = goal.fat,
                unit = "g",
                isLimit = false
            ),
            RDAEntry(
                name = "Fiber",
                current = consumed.fiber,
                goal = goal.fiber,
                unit = "g",
                isLimit = false
            ),
            // ---- Limits (stay under) ----
            RDAEntry(
                name = "Sugar",
                current = consumed.sugar,
                goal = goal.sugar,
                unit = "g",
                isLimit = true
            ),
            RDAEntry(
                name = "Sodium",
                current = consumed.sodium,
                goal = goal.sodium,
                unit = "mg",
                isLimit = true
            ),
            RDAEntry(
                name = "Saturated Fat",
                current = consumed.saturatedFat,
                goal = goal.saturatedFat,
                unit = "g",
                isLimit = true
            ),
            RDAEntry(
                name = "Cholesterol",
                current = consumed.cholesterol,
                goal = goal.cholesterol,
                unit = "mg",
                isLimit = true
            )
        )
    }
}
