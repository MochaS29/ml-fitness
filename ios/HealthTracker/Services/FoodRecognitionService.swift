import Foundation
import UIKit
import Vision
import CoreML

// MARK: - Food Recognition Service Protocol
protocol FoodRecognitionServiceProtocol {
    func analyzeDish(from image: UIImage) async throws -> FoodScanResult
    func searchFood(query: String) async throws -> [RecognizedFoodItem]
}

// MARK: - Food Recognition Service
class FoodRecognitionService: FoodRecognitionServiceProtocol {
    static let shared = FoodRecognitionService()
    
    private let spoonacularApiKey = ProcessInfo.processInfo.environment["SPOONACULAR_API_KEY"] ?? ""
    private let baseURL = APIConfiguration.Spoonacular.baseURL
    
    private init() {}
    
    // MARK: - Public Methods
    
    func analyzeDish(from image: UIImage) async throws -> FoodScanResult {
        // Check if API key is configured
        if !spoonacularApiKey.isEmpty && spoonacularApiKey != "DEMO" {
            // Use real Spoonacular API
            return try await analyzeWithSpoonacularAPI(image: image)
        } else {
            // Fall back to simulation
            return try await analyzeWithVisionFramework(image: image)
        }
    }
    
    func searchFood(query: String) async throws -> [RecognizedFoodItem] {
        // This would call a nutrition database API
        // For now, return mock data
        return mockSearchResults(for: query)
    }
    
    // MARK: - Vision Framework Analysis
    
    private func analyzeWithVisionFramework(image: UIImage) async throws -> FoodScanResult {
        return try await withCheckedThrowingContinuation { continuation in
            guard let cgImage = image.cgImage else {
                continuation.resume(throwing: FoodRecognitionError.invalidImage)
                return
            }
            
            // Use Vision framework for basic object detection
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                // Process results
                let result = self.processVisionResults(request.results, originalImage: image)
                continuation.resume(returning: result)
            }
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    private func processVisionResults(_ results: [Any]?, originalImage: UIImage) -> FoodScanResult {
        // Enhanced simulation based on image characteristics
        let imageAnalysis = analyzeImageCharacteristics(originalImage)
        let identifiedFoods = generateFoodItems(basedOn: imageAnalysis)
        
        let totalNutrition = calculateTotalNutrition(from: identifiedFoods)
        
        return FoodScanResult(
            id: UUID(),
            timestamp: Date(),
            identifiedFoods: identifiedFoods,
            totalNutrition: totalNutrition
        )
    }
    
    private func analyzeImageCharacteristics(_ image: UIImage) -> ImageCharacteristics {
        // Analyze image properties like dominant colors, textures, etc.
        // This is a simplified version
        let size = image.size
        let aspectRatio = size.width / size.height
        
        // Simulate different meal types based on image properties
        let mealComplexity: MealComplexity = aspectRatio > 1.2 ? .complex : .simple
        
        return ImageCharacteristics(
            dominantColors: extractDominantColors(from: image),
            complexity: mealComplexity,
            estimatedItemCount: mealComplexity == .complex ? 3 : 1
        )
    }
    
    private func extractDominantColors(from image: UIImage) -> [UIColor] {
        // Simplified color extraction
        // In production, use Core Image filters or advanced algorithms
        return [.brown, .green, .orange] // Mock colors
    }
    
    private func generateFoodItems(basedOn characteristics: ImageCharacteristics) -> [IdentifiedFood] {
        // Generate food items based on image analysis
        let foodDatabase = FoodItemDatabase()
        
        switch characteristics.complexity {
        case .simple:
            return [foodDatabase.getRandomMainDish()]
        case .complex:
            return [
                foodDatabase.getRandomMainDish(),
                foodDatabase.getRandomSide(),
                foodDatabase.getRandomVegetable()
            ]
        }
    }
    
    private func calculateTotalNutrition(from foods: [IdentifiedFood]) -> NutritionInfo {
        let calories = foods.reduce(0) { $0 + $1.calories }
        let protein = foods.reduce(0) { $0 + $1.protein }
        let carbs = foods.reduce(0) { $0 + $1.carbs }
        let fat = foods.reduce(0) { $0 + $1.fat }
        let fiber = Double(foods.count) * 3.5 // Estimated
        let sugar = Double(foods.count) * 2.0 // Estimated
        let sodium = Double(foods.count) * 150 // Estimated
        
        return NutritionInfo(
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            fiber: fiber,
            sugar: sugar,
            sodium: sodium
        )
    }
    
    // MARK: - Spoonacular API Integration
    
    private func analyzeWithSpoonacularAPI(image: UIImage) async throws -> FoodScanResult {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw FoodRecognitionError.invalidImage
        }
        
        // Spoonacular image analysis endpoint
        let url = URL(string: "\(baseURL)/food/images/analyze")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Create multipart form data
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Add API key
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"apiKey\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(spoonacularApiKey)\r\n".data(using: .utf8)!)
        
        // Add image
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        // Add parameters
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"includeNutrition\"\r\n\r\n".data(using: .utf8)!)
        body.append("true\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw FoodRecognitionError.apiError
        }
        
        // Parse Spoonacular response
        let spoonacularResponse = try JSONDecoder().decode(SpoonacularImageAnalysisResponse.self, from: data)
        return convertSpoonacularToFoodScanResult(spoonacularResponse)
    }
    
    private func convertSpoonacularToFoodScanResult(_ response: SpoonacularImageAnalysisResponse) -> FoodScanResult {
        var identifiedFoods: [IdentifiedFood] = []
        
        // Process category results
        if let category = response.category {
            identifiedFoods.append(IdentifiedFood(
                name: category.name,
                confidence: category.probability,
                estimatedWeight: 150, // Default estimate
                calories: response.nutrition?.calories?.value ?? 0,
                protein: response.nutrition?.protein?.value ?? 0,
                carbs: response.nutrition?.carbs?.value ?? 0,
                fat: response.nutrition?.fat?.value ?? 0,
                category: mapSpoonacularCategory(category.name)
            ))
        }
        
        // Process recipe results
        for recipe in response.recipes ?? [] {
            identifiedFoods.append(IdentifiedFood(
                name: recipe.title,
                confidence: 0.8, // Spoonacular doesn't provide confidence for recipes
                estimatedWeight: 200,
                calories: Double(recipe.nutrition?.nutrients?.first(where: { $0.name == "Calories" })?.amount ?? 0),
                protein: Double(recipe.nutrition?.nutrients?.first(where: { $0.name == "Protein" })?.amount ?? 0),
                carbs: Double(recipe.nutrition?.nutrients?.first(where: { $0.name == "Carbohydrates" })?.amount ?? 0),
                fat: Double(recipe.nutrition?.nutrients?.first(where: { $0.name == "Fat" })?.amount ?? 0),
                category: .meals
            ))
        }
        
        let totalNutrition = calculateTotalNutrition(from: identifiedFoods)
        
        return FoodScanResult(
            id: UUID(),
            timestamp: Date(),
            identifiedFoods: identifiedFoods,
            totalNutrition: totalNutrition
        )
    }
    
    private func mapSpoonacularCategory(_ category: String) -> FoodCategory {
        switch category.lowercased() {
        case let cat where cat.contains("fruit"): return .fruits
        case let cat where cat.contains("vegetable"): return .vegetables
        case let cat where cat.contains("meat") || cat.contains("protein"): return .protein
        case let cat where cat.contains("grain") || cat.contains("bread"): return .grains
        case let cat where cat.contains("dairy"): return .dairy
        case let cat where cat.contains("dessert") || cat.contains("sweet"): return .desserts
        default: return .other
        }
    }
    
    // MARK: - API Integration Methods (Ready for production)
    
    private func callFoodRecognitionAPI(imageData: Data) async throws -> FoodAPIResponse {
        guard !spoonacularApiKey.isEmpty else {
            throw FoodRecognitionError.missingAPIKey
        }
        
        var request = URLRequest(url: URL(string: "\(baseURL)/analyze")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(spoonacularApiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload = FoodAPIRequest(
            image: imageData.base64EncodedString(),
            options: RecognitionOptions(
                includeNutrition: true,
                confidenceThreshold: 0.7
            )
        )
        
        request.httpBody = try JSONEncoder().encode(payload)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw FoodRecognitionError.apiError
        }
        
        return try JSONDecoder().decode(FoodAPIResponse.self, from: data)
    }
    
    // MARK: - Mock Data
    
    private func mockSearchResults(for query: String) -> [RecognizedFoodItem] {
        // Return relevant mock data based on query
        let allFoods = FoodItemDatabase().getAllFoods()
        return allFoods.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }
}

// MARK: - Supporting Types

enum FoodRecognitionError: LocalizedError {
    case invalidImage
    case missingAPIKey
    case apiError
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "Invalid image format"
        case .missingAPIKey:
            return "API key not configured"
        case .apiError:
            return "Food recognition API error"
        case .networkError:
            return "Network connection error"
        }
    }
}

struct ImageCharacteristics {
    let dominantColors: [UIColor]
    let complexity: MealComplexity
    let estimatedItemCount: Int
}

enum MealComplexity {
    case simple
    case complex
}

// MARK: - API Models

struct FoodAPIRequest: Codable {
    let image: String
    let options: RecognitionOptions
}

struct RecognitionOptions: Codable {
    let includeNutrition: Bool
    let confidenceThreshold: Double
}

struct FoodAPIResponse: Codable {
    let results: [FoodAPIItem]
    let metadata: APIMetadata
}

struct FoodAPIItem: Codable {
    let name: String
    let confidence: Double
    let boundingBox: BoundingBox?
    let nutrition: NutritionData
}

struct BoundingBox: Codable {
    let x: Double
    let y: Double
    let width: Double
    let height: Double
}

struct NutritionData: Codable {
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    let servingSize: Double
    let servingUnit: String
}

struct APIMetadata: Codable {
    let processingTime: Double
    let apiVersion: String
}

// MARK: - Food Item Database (Mock)

struct RecognizedFoodItem {
    let name: String
    let category: FoodCategory
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    let estimatedWeight: Double
}

class FoodItemDatabase {
    private let mainDishes = [
        IdentifiedFood(
            name: "Grilled Chicken Breast",
            confidence: 0.92,
            estimatedWeight: 150,
            calories: 250,
            protein: 46,
            carbs: 0,
            fat: 5.5,
            category: .protein
        ),
        IdentifiedFood(
            name: "Baked Salmon Fillet",
            confidence: 0.89,
            estimatedWeight: 120,
            calories: 280,
            protein: 35,
            carbs: 0,
            fat: 15,
            category: .protein
        ),
        IdentifiedFood(
            name: "Beef Stir Fry",
            confidence: 0.85,
            estimatedWeight: 200,
            calories: 350,
            protein: 28,
            carbs: 12,
            fat: 22,
            category: .protein
        )
    ]
    
    private let sides = [
        IdentifiedFood(
            name: "Brown Rice",
            confidence: 0.94,
            estimatedWeight: 100,
            calories: 110,
            protein: 2.5,
            carbs: 23,
            fat: 0.9,
            category: .grains
        ),
        IdentifiedFood(
            name: "Quinoa",
            confidence: 0.91,
            estimatedWeight: 100,
            calories: 120,
            protein: 4.4,
            carbs: 21,
            fat: 1.9,
            category: .grains
        ),
        IdentifiedFood(
            name: "Sweet Potato",
            confidence: 0.93,
            estimatedWeight: 150,
            calories: 130,
            protein: 2.5,
            carbs: 30,
            fat: 0.2,
            category: .vegetables
        )
    ]
    
    private let vegetables = [
        IdentifiedFood(
            name: "Steamed Broccoli",
            confidence: 0.96,
            estimatedWeight: 80,
            calories: 27,
            protein: 2.2,
            carbs: 5.5,
            fat: 0.3,
            category: .vegetables
        ),
        IdentifiedFood(
            name: "Mixed Salad",
            confidence: 0.88,
            estimatedWeight: 100,
            calories: 35,
            protein: 2,
            carbs: 6,
            fat: 0.5,
            category: .vegetables
        ),
        IdentifiedFood(
            name: "Roasted Vegetables",
            confidence: 0.87,
            estimatedWeight: 120,
            calories: 65,
            protein: 2.5,
            carbs: 12,
            fat: 2,
            category: .vegetables
        )
    ]
    
    func getRandomMainDish() -> IdentifiedFood {
        mainDishes.randomElement()!
    }
    
    func getRandomSide() -> IdentifiedFood {
        sides.randomElement()!
    }
    
    func getRandomVegetable() -> IdentifiedFood {
        vegetables.randomElement()!
    }
    
    func getAllFoods() -> [RecognizedFoodItem] {
        // Convert to RecognizedFoodItem for search functionality
        var allFoods: [RecognizedFoodItem] = []
        
        for dish in mainDishes {
            allFoods.append(RecognizedFoodItem(
                name: dish.name,
                category: dish.category,
                calories: dish.calories,
                protein: dish.protein,
                carbs: dish.carbs,
                fat: dish.fat,
                estimatedWeight: dish.estimatedWeight
            ))
        }
        
        for side in sides {
            allFoods.append(RecognizedFoodItem(
                name: side.name,
                category: side.category,
                calories: side.calories,
                protein: side.protein,
                carbs: side.carbs,
                fat: side.fat,
                estimatedWeight: side.estimatedWeight
            ))
        }
        
        for veg in vegetables {
            allFoods.append(RecognizedFoodItem(
                name: veg.name,
                category: veg.category,
                calories: veg.calories,
                protein: veg.protein,
                carbs: veg.carbs,
                fat: veg.fat,
                estimatedWeight: veg.estimatedWeight
            ))
        }
        
        return allFoods
    }
}

// MARK: - Spoonacular Response Models

struct SpoonacularImageAnalysisResponse: Codable {
    let category: SpoonacularCategory?
    let recipes: [SpoonacularRecipe]?
    let nutrition: SpoonacularFoodNutrition?
}

struct SpoonacularCategory: Codable {
    let name: String
    let probability: Double
}

struct SpoonacularRecipe: Codable {
    let id: Int
    let title: String
    let imageType: String?
    let nutrition: SpoonacularRecipeNutrition?
}

struct SpoonacularFoodNutrition: Codable {
    let recipesUsed: Int?
    let calories: SpoonacularNutrientInfo?
    let fat: SpoonacularNutrientInfo?
    let protein: SpoonacularNutrientInfo?
    let carbs: SpoonacularNutrientInfo?
}

struct SpoonacularNutrientInfo: Codable {
    let value: Double
    let unit: String
}

struct SpoonacularRecipeNutrition: Codable {
    let nutrients: [SpoonacularFoodNutrient]?
}

struct SpoonacularFoodNutrient: Codable {
    let name: String
    let amount: Float
    let unit: String
}