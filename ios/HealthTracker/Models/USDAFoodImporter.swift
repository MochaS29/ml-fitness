import Foundation
import CoreData

class USDAFoodImporter {
    private let viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }
    
    // Structure to match USDA food.csv
    struct USDAFood {
        let fdcId: Int
        let dataType: String
        let description: String
        let foodCategoryId: Int?
        let publicationDate: String
    }
    
    // Structure to match USDA food_nutrient.csv
    struct USDAFoodNutrient {
        let id: Int
        let fdcId: Int
        let nutrientId: Int
        let amount: Double
        let dataPoints: Int?
        let derivationId: Int?
        let min: Double?
        let max: Double?
        let median: Double?
        let footnote: String?
        let minYearAcquired: Int?
    }
    
    // Structure to match USDA nutrient.csv
    struct USDANutrient {
        let id: Int
        let name: String
        let unitName: String
        let nutrientNbr: String
        let rank: Int?
    }
    
    // Map USDA nutrient IDs to our nutrient types
    private let nutrientMapping: [Int: String] = [
        1008: "calories",     // Energy (kcal)
        1003: "protein",      // Protein
        1004: "fat",          // Total lipid (fat)
        1005: "carbs",        // Carbohydrate, by difference
        1079: "fiber",        // Fiber, total dietary
        2000: "sugar",        // Sugars, total
        1093: "sodium",       // Sodium
        1253: "cholesterol",  // Cholesterol
        1258: "saturatedFat", // Fatty acids, total saturated
        
        // Vitamins
        1106: "vitamin_a",    // Vitamin A, RAE
        1162: "vitamin_c",    // Vitamin C
        1114: "vitamin_d",    // Vitamin D (D2 + D3)
        1109: "vitamin_e",    // Vitamin E (alpha-tocopherol)
        1185: "vitamin_k",    // Vitamin K (phylloquinone)
        1165: "thiamin",      // Thiamin
        1166: "riboflavin",   // Riboflavin
        1167: "niacin",       // Niacin
        1175: "vitamin_b6",   // Vitamin B-6
        1178: "vitamin_b12",  // Vitamin B-12
        1177: "folate",       // Folate, total
        
        // Minerals
        1087: "calcium",      // Calcium
        1089: "iron",         // Iron
        1090: "magnesium",    // Magnesium
        1091: "phosphorus",   // Phosphorus
        1092: "potassium",    // Potassium
        1095: "zinc",         // Zinc
        1098: "copper",       // Copper
        1101: "manganese",    // Manganese
        1103: "selenium"      // Selenium
    ]
    
    func importUSDADatabase(foodCSVPath: String, nutrientCSVPath: String, foodNutrientCSVPath: String) async throws {
        // This would be called from a background task
        print("Starting USDA database import...")
        
        // Parse CSV files
        let foods = try parseUSDAFoodCSV(at: foodCSVPath)
        let nutrients = try parseNutrientCSV(at: nutrientCSVPath)
        let foodNutrients = try parseFoodNutrientCSV(at: foodNutrientCSVPath)
        
        // Create a mapping of nutrient IDs to names
        var nutrientNameMap: [Int: USDANutrient] = [:]
        for nutrient in nutrients {
            nutrientNameMap[nutrient.id] = nutrient
        }
        
        // Process foods in batches
        let batchSize = 1000
        for i in stride(from: 0, to: foods.count, by: batchSize) {
            let batch = Array(foods[i..<min(i + batchSize, foods.count)])
            
            try await viewContext.perform {
                for food in batch {
                    // Create CustomFood entity
                    let customFood = CustomFood(context: self.viewContext)
                    customFood.id = UUID()
                    customFood.name = food.description
                    customFood.source = "USDA"
                    customFood.fdcId = Int32(food.fdcId)
                    customFood.isUserCreated = false
                    customFood.createdDate = Date()
                    
                    // Get nutrients for this food
                    let nutrientsForFood = foodNutrients.filter { $0.fdcId == food.fdcId }
                    
                    // Aggregate nutrients
                    var nutrientData: [String: Double] = [:]
                    
                    for foodNutrient in nutrientsForFood {
                        if let mappedName = self.nutrientMapping[foodNutrient.nutrientId] {
                            nutrientData[mappedName] = foodNutrient.amount
                        }
                    }
                    
                    // Set basic macros
                    customFood.calories = nutrientData["calories"] ?? 0
                    customFood.protein = nutrientData["protein"] ?? 0
                    customFood.carbs = nutrientData["carbs"] ?? 0
                    customFood.fat = nutrientData["fat"] ?? 0
                    customFood.fiber = nutrientData["fiber"] ?? 0
                    customFood.sugar = nutrientData["sugar"] ?? 0
                    customFood.sodium = nutrientData["sodium"] ?? 0
                    customFood.cholesterol = nutrientData["cholesterol"] ?? 0
                    customFood.saturatedFat = nutrientData["saturatedFat"] ?? 0
                    
                    // Store additional nutrients as JSON
                    customFood.additionalNutrients = nutrientData
                }
                
                // Save batch
                if self.viewContext.hasChanges {
                    try self.viewContext.save()
                }
            }
        }
        
        print("USDA database import completed!")
    }
    
    private func parseUSDAFoodCSV(at path: String) throws -> [USDAFood] {
        let data = try String(contentsOfFile: path, encoding: .utf8)
        let lines = data.components(separatedBy: .newlines)
        
        var foods: [USDAFood] = []
        
        // Skip header
        for i in 1..<lines.count {
            let line = lines[i]
            guard !line.isEmpty else { continue }
            
            let components = parseCSVLine(line)
            guard components.count >= 5 else { continue }
            
            let food = USDAFood(
                fdcId: Int(components[0]) ?? 0,
                dataType: components[1],
                description: components[2],
                foodCategoryId: Int(components[3]),
                publicationDate: components[4]
            )
            
            foods.append(food)
        }
        
        return foods
    }
    
    private func parseNutrientCSV(at path: String) throws -> [USDANutrient] {
        // Similar parsing logic for nutrients
        return []
    }
    
    private func parseFoodNutrientCSV(at path: String) throws -> [USDAFoodNutrient] {
        // Similar parsing logic for food nutrients
        return []
    }
    
    private func parseCSVLine(_ line: String) -> [String] {
        // Simple CSV parser that handles quoted values
        var result: [String] = []
        var currentField = ""
        var inQuotes = false
        
        for char in line {
            if char == "\"" {
                inQuotes.toggle()
            } else if char == "," && !inQuotes {
                result.append(currentField)
                currentField = ""
            } else {
                currentField.append(char)
            }
        }
        
        result.append(currentField)
        return result
    }
}