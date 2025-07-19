import Foundation
import CoreData

class USDACSVImporter {
    
    // USDA Nutrient IDs
    enum USDANutrientID: Int {
        case calories = 1008
        case protein = 1003
        case totalFat = 1004
        case carbohydrate = 1005
        case fiber = 1079
        case sugar = 2000
        case calcium = 1087
        case iron = 1089
        case magnesium = 1090
        case phosphorus = 1091
        case potassium = 1092
        case sodium = 1093
        case zinc = 1095
        case vitaminC = 1162
        case thiamin = 1165
        case riboflavin = 1166
        case niacin = 1167
        case vitaminB6 = 1175
        case folate = 1177
        case vitaminB12 = 1178
        case vitaminA = 1106
        case vitaminE = 1109
        case vitaminD = 1114
        case vitaminK = 1185
        case saturatedFat = 1258
        case cholesterol = 1253
    }
    
    static func importUSDADatabase(from csvPath: String, context: NSManagedObjectContext, progress: @escaping (Float, String) -> Void) async throws {
        let fileManager = FileManager.default
        
        // Check if CSV files exist
        guard fileManager.fileExists(atPath: csvPath) else {
            throw ImportError.fileNotFound
        }
        
        // Import foods
        try await importFoods(from: csvPath, context: context, progress: progress)
        
        // Import nutrients
        try await importNutrients(from: csvPath, context: context, progress: progress)
        
        // Save context
        try context.save()
    }
    
    private static func importFoods(from basePath: String, context: NSManagedObjectContext, progress: @escaping (Float, String) -> Void) async throws {
        let foodPath = "\(basePath)/food.csv"
        
        progress(0.1, "Reading food data...")
        
        // Read and parse food.csv
        let foodData = try String(contentsOfFile: foodPath, encoding: .utf8)
        let foodLines = foodData.components(separatedBy: .newlines).filter { !$0.isEmpty }
        
        // Skip header
        guard foodLines.count > 1 else { return }
        
        let totalFoods = foodLines.count - 1
        var processedFoods = 0
        
        // Create a batch context for better performance
        let batchContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        batchContext.parent = context
        
        // Process foods in batches
        let batchSize = 1000
        for batchStart in stride(from: 1, to: foodLines.count, by: batchSize) {
            let batchEnd = min(batchStart + batchSize, foodLines.count)
            
            try await batchContext.perform {
                for i in batchStart..<batchEnd {
                    let line = foodLines[i]
                    let columns = parseCSVLine(line)
                    
                    guard columns.count >= 4 else { continue }
                    
                    let food = CustomFood(context: batchContext)
                    food.id = UUID()
                    food.fdcId = Int32(columns[0]) ?? 0
                    food.name = cleanFoodName(columns[2])
                    food.source = "USDA"
                    food.isUserCreated = false
                    food.createdDate = Date()
                    
                    // Set default values
                    food.calories = 0
                    food.protein = 0
                    food.carbs = 0
                    food.fat = 0
                    food.fiber = 0
                    food.sugar = 0
                    food.sodium = 0
                    food.cholesterol = 0
                    food.saturatedFat = 0
                    
                    // Default serving size
                    food.servingSize = "100"
                    food.servingUnit = "g"
                    
                    processedFoods += 1
                }
                
                // Save batch
                try batchContext.save()
            }
            
            let currentProgress = Float(processedFoods) / Float(totalFoods) * 0.4 + 0.1
            progress(currentProgress, "Imported \(processedFoods) of \(totalFoods) foods")
        }
        
        // Save parent context
        try await context.perform {
            try context.save()
        }
    }
    
    private static func importNutrients(from basePath: String, context: NSManagedObjectContext, progress: @escaping (Float, String) -> Void) async throws {
        let nutrientPath = "\(basePath)/food_nutrient.csv"
        
        progress(0.5, "Reading nutrient data...")
        
        // Read and parse food_nutrient.csv
        let nutrientData = try String(contentsOfFile: nutrientPath, encoding: .utf8)
        let nutrientLines = nutrientData.components(separatedBy: .newlines).filter { !$0.isEmpty }
        
        guard nutrientLines.count > 1 else { return }
        
        // Create lookup for foods by FDC ID
        let foodRequest = NSFetchRequest<CustomFood>(entityName: "CustomFood")
        let allFoods = try context.fetch(foodRequest)
        let foodLookup = Dictionary(uniqueKeysWithValues: allFoods.compactMap { food in
            food.fdcId > 0 ? (food.fdcId, food) : nil
        })
        
        let totalNutrients = nutrientLines.count - 1
        var processedNutrients = 0
        
        // Process nutrients
        for i in stride(from: 1, to: nutrientLines.count, by: 10000) {
            let end = min(i + 10000, nutrientLines.count)
            
            for j in i..<end {
                let line = nutrientLines[j]
                let columns = parseCSVLine(line)
                
                guard columns.count >= 5 else { continue }
                
                let fdcId = Int32(columns[1]) ?? 0
                let nutrientId = Int(columns[2]) ?? 0
                let amount = Double(columns[3]) ?? 0
                
                // Find the food
                guard let food = foodLookup[fdcId] else { continue }
                
                // Update nutrient values based on USDA nutrient IDs
                switch nutrientId {
                case USDANutrientID.calories.rawValue:
                    food.calories = amount
                case USDANutrientID.protein.rawValue:
                    food.protein = amount
                case USDANutrientID.totalFat.rawValue:
                    food.fat = amount
                case USDANutrientID.carbohydrate.rawValue:
                    food.carbs = amount
                case USDANutrientID.fiber.rawValue:
                    food.fiber = amount
                case USDANutrientID.sugar.rawValue:
                    food.sugar = amount
                case USDANutrientID.sodium.rawValue:
                    food.sodium = amount
                case USDANutrientID.cholesterol.rawValue:
                    food.cholesterol = amount
                case USDANutrientID.saturatedFat.rawValue:
                    food.saturatedFat = amount
                default:
                    // Store other nutrients in additionalNutrients
                    if food.additionalNutrients == nil {
                        food.additionalNutrients = [:]
                    }
                    food.additionalNutrients?[String(nutrientId)] = amount
                }
                
                processedNutrients += 1
            }
            
            let currentProgress = Float(processedNutrients) / Float(totalNutrients) * 0.4 + 0.5
            progress(currentProgress, "Processed \(processedNutrients) of \(totalNutrients) nutrients")
        }
        
        progress(0.9, "Saving database...")
        try context.save()
        progress(1.0, "Import complete!")
    }
    
    private static func parseCSVLine(_ line: String) -> [String] {
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
        
        if !currentField.isEmpty {
            result.append(currentField)
        }
        
        return result
    }
    
    private static func cleanFoodName(_ name: String) -> String {
        // Remove quotes and clean up the name
        var cleaned = name.trimmingCharacters(in: .whitespacesAndNewlines)
        cleaned = cleaned.replacingOccurrences(of: "\"", with: "")
        
        // Capitalize properly
        let words = cleaned.lowercased().components(separatedBy: " ")
        let capitalized = words.map { word in
            guard !word.isEmpty else { return word }
            let firstChar = word.prefix(1).uppercased()
            let rest = word.dropFirst()
            return firstChar + rest
        }
        
        return capitalized.joined(separator: " ")
    }
    
    enum ImportError: LocalizedError {
        case fileNotFound
        case invalidFormat
        case saveFailed
        
        var errorDescription: String? {
            switch self {
            case .fileNotFound:
                return "CSV files not found"
            case .invalidFormat:
                return "Invalid CSV format"
            case .saveFailed:
                return "Failed to save data"
            }
        }
    }
}

// Extension to make import available from UI
extension USDACSVImporter {
    static func performImport(context: NSManagedObjectContext, completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                // Get the path to the USDA CSV files
                let basePath = "/Users/mocha/HealthTracker/Resources/Databases/FoodData_Central_csv_2023-10-26"
                
                try await importUSDADatabase(
                    from: basePath,
                    context: context,
                    progress: { progress, message in
                        DispatchQueue.main.async {
                            print("Import progress: \(progress) - \(message)")
                        }
                    }
                )
                
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}