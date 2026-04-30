import Foundation
import CoreData

extension NutritionInfo {
    /// Apply a `[String: Double]` extras dict (using the keys produced by
    /// AddCustomFoodView / ManualFoodEntrySheet — "calcium", "vitamin_a", …) onto
    /// this NutritionInfo. Mirrors the switch in `fromSupplements`.
    mutating func applyAdditionalNutrients(_ extras: [String: Double]) {
        for (key, amount) in extras {
            switch key {
            case "vitamin_a":         vitaminA = (vitaminA ?? 0) + amount
            case "vitamin_c":         vitaminC = (vitaminC ?? 0) + amount
            case "vitamin_d":         vitaminD = (vitaminD ?? 0) + amount
            case "vitamin_e":         vitaminE = (vitaminE ?? 0) + amount
            case "vitamin_k":         vitaminK = (vitaminK ?? 0) + amount
            case "thiamin", "vitamin_b1":   thiamin = (thiamin ?? 0) + amount
            case "riboflavin", "vitamin_b2": riboflavin = (riboflavin ?? 0) + amount
            case "niacin", "vitamin_b3":    niacin = (niacin ?? 0) + amount
            case "vitamin_b6":        vitaminB6 = (vitaminB6 ?? 0) + amount
            case "folate":            folate = (folate ?? 0) + amount
            case "vitamin_b12":       vitaminB12 = (vitaminB12 ?? 0) + amount
            case "biotin":            biotin = (biotin ?? 0) + amount
            case "pantothenic_acid", "vitamin_b5": pantothenicAcid = (pantothenicAcid ?? 0) + amount
            case "calcium":           calcium = (calcium ?? 0) + amount
            case "iron":              iron = (iron ?? 0) + amount
            case "magnesium":         magnesium = (magnesium ?? 0) + amount
            case "phosphorus":        phosphorus = (phosphorus ?? 0) + amount
            case "potassium":         potassium = (potassium ?? 0) + amount
            case "zinc":              zinc = (zinc ?? 0) + amount
            case "copper":            copper = (copper ?? 0) + amount
            case "manganese":         manganese = (manganese ?? 0) + amount
            case "selenium":          selenium = (selenium ?? 0) + amount
            case "chromium":          chromium = (chromium ?? 0) + amount
            case "molybdenum":        molybdenum = (molybdenum ?? 0) + amount
            case "iodine":            iodine = (iodine ?? 0) + amount
            case "omega_3":           omega3 = (omega3 ?? 0) + amount
            case "omega_6":           omega6 = (omega6 ?? 0) + amount
            case "choline":           choline = (choline ?? 0) + amount
            default: break
            }
        }
    }

    static func fromFoodEntries(_ entries: [FoodEntry]) -> NutritionInfo {
        var total = NutritionInfo(calories: 0, protein: 0, carbs: 0, fat: 0, fiber: 0, sugar: 0, sodium: 0)
        for entry in entries {
            total.calories += entry.calories
            total.protein  += entry.protein
            total.carbs    += entry.carbs
            total.fat      += entry.fat
            total.fiber    = (total.fiber ?? 0)  + entry.fiber
            total.sugar    = (total.sugar ?? 0)  + entry.sugar
            total.sodium   = (total.sodium ?? 0) + entry.sodium
            if let extras = entry.additionalNutrients {
                total.applyAdditionalNutrients(extras)
            }
        }
        return total
    }

    static func fromCustomFood(_ food: CustomFood) -> NutritionInfo {
        var n = NutritionInfo(
            calories: food.calories,
            protein:  food.protein,
            carbs:    food.carbs,
            fat:      food.fat,
            fiber:    food.fiber,
            sugar:    food.sugar,
            sodium:   food.sodium
        )
        if let extras = food.additionalNutrients {
            n.applyAdditionalNutrients(extras)
        }
        return n
    }

    static func fromCustomRecipe(_ recipe: CustomRecipe) -> NutritionInfo {
        var n = NutritionInfo(
            calories: recipe.calories,
            protein:  recipe.protein,
            carbs:    recipe.carbs,
            fat:      recipe.fat,
            fiber:    recipe.fiber,
            sugar:    recipe.sugar,
            sodium:   recipe.sodium
        )
        if let extras = recipe.additionalNutrients {
            n.applyAdditionalNutrients(extras)
        }
        return n
    }
}

extension Dictionary where Key == String, Value == Double {
    /// Sum two `[String: Double]` nutrient dicts.
    static func + (lhs: [String: Double], rhs: [String: Double]) -> [String: Double] {
        var result = lhs
        for (key, value) in rhs {
            result[key, default: 0] += value
        }
        return result
    }
}
