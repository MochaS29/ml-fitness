import Foundation
import CoreData

// MARK: - USDA FoodData Central API Service

class FoodDatabaseAPI: ObservableObject {
    static let shared = FoodDatabaseAPI()

    @Published var isSearching = false
    @Published var searchResults: [USDAFood] = []

    // Get your free API key from: https://fdc.nal.usda.gov/api-key-signup.html
    private let apiKey = "YOUR_API_KEY_HERE" // Replace with your API key
    private let baseURL = "https://api.nal.usda.gov/fdc/v1"

    private init() {}

    // MARK: - Search Foods

    func searchFoods(_ query: String, completion: @escaping (Result<[USDAFood], Error>) -> Void) {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            completion(.success([]))
            return
        }

        isSearching = true

        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "\(baseURL)/foods/search?query=\(encodedQuery)&pageSize=50&api_key=\(apiKey)"

        guard let url = URL(string: urlString) else {
            completion(.failure(APIError.invalidURL))
            isSearching = false
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isSearching = false

                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = data else {
                    completion(.failure(APIError.noData))
                    return
                }

                do {
                    let response = try JSONDecoder().decode(USDASearchResponse.self, from: data)
                    self?.searchResults = response.foods
                    completion(.success(response.foods))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    // MARK: - Get Food Details

    func getFoodDetails(fdcId: Int, completion: @escaping (Result<USDAFoodDetail, Error>) -> Void) {
        let urlString = "\(baseURL)/food/\(fdcId)?api_key=\(apiKey)"

        guard let url = URL(string: urlString) else {
            completion(.failure(APIError.invalidURL))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = data else {
                    completion(.failure(APIError.noData))
                    return
                }

                do {
                    let foodDetail = try JSONDecoder().decode(USDAFoodDetail.self, from: data)
                    completion(.success(foodDetail))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    // MARK: - Save to Core Data

    func saveFoodToDatabase(_ food: USDAFood, context: NSManagedObjectContext) {
        let entry = FoodEntry(context: context)
        entry.id = UUID()
        entry.name = food.description
        entry.brand = food.brandName ?? food.brandOwner
        entry.timestamp = Date()
        entry.date = Date()

        // Map nutrients
        if let nutrients = food.foodNutrients {
            for nutrient in nutrients {
                switch nutrient.nutrientId {
                case 1008: // Calories
                    entry.calories = nutrient.value ?? 0
                case 1003: // Protein
                    entry.protein = nutrient.value ?? 0
                case 1004: // Fat
                    entry.fat = nutrient.value ?? 0
                case 1005: // Carbohydrates
                    entry.carbs = nutrient.value ?? 0
                case 1079: // Fiber
                    entry.fiber = nutrient.value ?? 0
                case 2000: // Sugar
                    entry.sugar = nutrient.value ?? 0
                case 1093: // Sodium
                    entry.sodium = nutrient.value ?? 0
                // case 1253: // Cholesterol
                //     entry.cholesterol = nutrient.value ?? 0
                default:
                    break
                }
            }
        }

        // Set serving size
        if let servingSize = food.servingSize, let servingUnit = food.servingSizeUnit {
            entry.servingSize = "\(servingSize)"
            entry.servingUnit = servingUnit
        } else {
            entry.servingSize = "100"
            entry.servingUnit = "g"
        }

        do {
            try context.save()
        } catch {
            print("Error saving USDA food: \(error)")
        }
    }
}

// MARK: - API Models

struct USDASearchResponse: Codable {
    let foods: [USDAFood]
    let totalHits: Int?
    let currentPage: Int?
    let totalPages: Int?
}

struct USDAFood: Codable, Identifiable {
    let fdcId: Int
    let description: String
    let dataType: String?
    let brandOwner: String?
    let brandName: String?
    let ingredients: String?
    let marketCountry: String?
    let foodCategory: String?
    let allHighlightFields: String?
    let score: Double?
    let servingSize: Double?
    let servingSizeUnit: String?
    let foodNutrients: [USDANutrient]?

    var id: Int { fdcId }
}

struct USDANutrient: Codable {
    let nutrientId: Int
    let nutrientName: String?
    let nutrientNumber: String?
    let unitName: String?
    let value: Double?
    let derivationCode: String?
    let derivationDescription: String?
}

struct USDAFoodDetail: Codable {
    let fdcId: Int
    let description: String
    let dataType: String?
    let brandOwner: String?
    let brandName: String?
    let ingredients: String?
    let servingSize: Double?
    let servingSizeUnit: String?
    let labelNutrients: LabelNutrients?
    let foodNutrients: [USDANutrient]?
}

struct LabelNutrients: Codable {
    let calories: NutrientValue?
    let protein: NutrientValue?
    let fat: NutrientValue?
    let carbohydrates: NutrientValue?
    let fiber: NutrientValue?
    let sugars: NutrientValue?
    let sodium: NutrientValue?
    let cholesterol: NutrientValue?
    let saturatedFat: NutrientValue?
    let transFat: NutrientValue?
}

struct NutrientValue: Codable {
    let value: Double?
}

// MARK: - Error Types

enum APIError: LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case networkError(String)
    case apiKeyMissing

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode response"
        case .networkError(let message):
            return "Network error: \(message)"
        case .apiKeyMissing:
            return "API key not configured"
        }
    }
}

// MARK: - Alternative: Nutritionix API

class NutritionixAPI {
    static let shared = NutritionixAPI()

    private let appId = "YOUR_APP_ID"
    private let appKey = "YOUR_APP_KEY"
    private let baseURL = "https://trackapi.nutritionix.com/v2"

    func searchInstant(_ query: String, completion: @escaping (Result<[NutritionixFood], Error>) -> Void) {
        let urlString = "\(baseURL)/search/instant?query=\(query)"

        guard let url = URL(string: urlString) else {
            completion(.failure(APIError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.setValue(appId, forHTTPHeaderField: "x-app-id")
        request.setValue(appKey, forHTTPHeaderField: "x-app-key")

        URLSession.shared.dataTask(with: request) { data, response, error in
            // Parse response
        }.resume()
    }

    func getNutrients(query: String, completion: @escaping (Result<NutritionixNutrients, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/natural/nutrients")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(appId, forHTTPHeaderField: "x-app-id")
        request.setValue(appKey, forHTTPHeaderField: "x-app-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["query": query]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            // Parse response
        }.resume()
    }
}

struct NutritionixFood: Codable {
    let foodName: String
    let brandName: String?
    let servingQty: Double?
    let servingUnit: String?
    let nfCalories: Double?
    let nfTotalFat: Double?
    let nfProtein: Double?
    let nfTotalCarbohydrate: Double?
    let nfDietaryFiber: Double?
    let nfSugars: Double?
    let nfSodium: Double?
}

struct NutritionixNutrients: Codable {
    let foods: [NutritionixFood]
}

// MARK: - Configuration

struct FoodAPIConfig {
    static var current: FoodAPIProvider = .usda

    enum FoodAPIProvider {
        case usda
        case nutritionix
        case edamam
        case spoonacular
    }

    static func configure(provider: FoodAPIProvider, apiKey: String) {
        // Store in Keychain for production
        UserDefaults.standard.set(apiKey, forKey: "\(provider)_api_key")
        current = provider
    }
}