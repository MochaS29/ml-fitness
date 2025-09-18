//
//  NutritionInfo+Extensions.swift
//  HealthTracker
//
//  Created by HealthTracker
//

import Foundation

extension NutritionInfo {
    
    // MARK: - Addition Operator
    
    static func + (lhs: NutritionInfo, rhs: NutritionInfo) -> NutritionInfo {
        var result = NutritionInfo(
            calories: lhs.calories + rhs.calories,
            protein: lhs.protein + rhs.protein,
            carbs: lhs.carbs + rhs.carbs,
            fat: lhs.fat + rhs.fat,
            fiber: (lhs.fiber ?? 0) + (rhs.fiber ?? 0),
            sugar: (lhs.sugar ?? 0) + (rhs.sugar ?? 0),
            sodium: (lhs.sodium ?? 0) + (rhs.sodium ?? 0)
        )

        // Combine vitamins
        result.vitaminA = (lhs.vitaminA ?? 0) + (rhs.vitaminA ?? 0)
        result.vitaminC = (lhs.vitaminC ?? 0) + (rhs.vitaminC ?? 0)
        result.vitaminD = (lhs.vitaminD ?? 0) + (rhs.vitaminD ?? 0)
        result.vitaminE = (lhs.vitaminE ?? 0) + (rhs.vitaminE ?? 0)
        result.vitaminK = (lhs.vitaminK ?? 0) + (rhs.vitaminK ?? 0)
        result.thiamin = (lhs.thiamin ?? 0) + (rhs.thiamin ?? 0)
        result.riboflavin = (lhs.riboflavin ?? 0) + (rhs.riboflavin ?? 0)
        result.niacin = (lhs.niacin ?? 0) + (rhs.niacin ?? 0)
        result.vitaminB6 = (lhs.vitaminB6 ?? 0) + (rhs.vitaminB6 ?? 0)
        result.folate = (lhs.folate ?? 0) + (rhs.folate ?? 0)
        result.vitaminB12 = (lhs.vitaminB12 ?? 0) + (rhs.vitaminB12 ?? 0)
        result.biotin = (lhs.biotin ?? 0) + (rhs.biotin ?? 0)
        result.pantothenicAcid = (lhs.pantothenicAcid ?? 0) + (rhs.pantothenicAcid ?? 0)
        result.choline = (lhs.choline ?? 0) + (rhs.choline ?? 0)

        // Combine minerals
        result.calcium = (lhs.calcium ?? 0) + (rhs.calcium ?? 0)
        result.iron = (lhs.iron ?? 0) + (rhs.iron ?? 0)
        result.magnesium = (lhs.magnesium ?? 0) + (rhs.magnesium ?? 0)
        result.phosphorus = (lhs.phosphorus ?? 0) + (rhs.phosphorus ?? 0)
        result.potassium = (lhs.potassium ?? 0) + (rhs.potassium ?? 0)
        result.zinc = (lhs.zinc ?? 0) + (rhs.zinc ?? 0)
        result.copper = (lhs.copper ?? 0) + (rhs.copper ?? 0)
        result.manganese = (lhs.manganese ?? 0) + (rhs.manganese ?? 0)
        result.selenium = (lhs.selenium ?? 0) + (rhs.selenium ?? 0)
        result.chromium = (lhs.chromium ?? 0) + (rhs.chromium ?? 0)
        result.molybdenum = (lhs.molybdenum ?? 0) + (rhs.molybdenum ?? 0)
        result.iodine = (lhs.iodine ?? 0) + (rhs.iodine ?? 0)

        // Combine special nutrients
        result.omega3 = (lhs.omega3 ?? 0) + (rhs.omega3 ?? 0)
        result.omega6 = (lhs.omega6 ?? 0) + (rhs.omega6 ?? 0)

        return result
    }
    
    // MARK: - Convenience Initializers
    
    init(calories: Double, protein: Double, carbs: Double, fat: Double, fiber: Double, sugar: Double, sodium: Double) {
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.fiber = fiber
        self.sugar = sugar
        self.sodium = sodium
    }
}