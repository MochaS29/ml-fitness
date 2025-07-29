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
        return NutritionInfo(
            calories: lhs.calories + rhs.calories,
            protein: lhs.protein + rhs.protein,
            carbs: lhs.carbs + rhs.carbs,
            fat: lhs.fat + rhs.fat,
            fiber: (lhs.fiber ?? 0) + (rhs.fiber ?? 0),
            sugar: (lhs.sugar ?? 0) + (rhs.sugar ?? 0),
            sodium: (lhs.sodium ?? 0) + (rhs.sodium ?? 0)
        )
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