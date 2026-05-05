import Foundation

/// Service for searching USDA FoodData Central database
/// Contains over 1.5 million food items with comprehensive nutrition data
class USDAFoodService: ObservableObject {
    static let shared = USDAFoodService()

    // USDA FoodData Central API
    // API key from: https://fdc.nal.usda.gov/api-guide.html
    private let apiKey = "Prq1Udw3TZOvlFdBdIflKXfphbASsabuyG4zGp4A" // 3,600 requests/hour, 10,000 requests/day
    private let baseURL = "https://api.nal.usda.gov/fdc/v1"

    @Published var searchResults: [USDAFoodItem] = []
    @Published var isSearching = false
    @Published var searchError: String?

    private init() {}

    /// Search USDA database for foods
    /// - Parameter query: Search term (e.g., "chicken breast", "apple", "coca cola")
    /// - Returns: Array of matching food items with nutrition data
    func searchFoods(_ query: String) async throws -> [USDAFoodItem] {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return []
        }

        // Comment out to use real API instead of mock data
        // return getMockResults(for: query)

        // Production API call (when you have a real API key)
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "\(baseURL)/foods/search?query=\(encodedQuery)&api_key=\(apiKey)&limit=50"

        guard let url = URL(string: urlString) else {
            throw USDAError.invalidURL
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(USDAServiceSearchResponse.self, from: data)

        return response.foods.map { $0.toUSDAFood() }
    }

    /// Get detailed nutrition information for a specific food
    func getFoodDetails(fdcId: Int) async throws -> USDAFoodItem? {
        // Implementation for getting detailed food info
        // Would use: GET /v1/food/{fdcId}?api_key={api_key}
        return nil
    }

    /// Mock data for testing without API key
    private func getMockResults(for query: String) -> [USDAFoodItem] {
        let lowercaseQuery = query.lowercased()

        // Comprehensive mock database for testing
        let mockDatabase = [
            // Fruits
            USDAFoodItem(fdcId: 1, name: "Apple, raw, with skin", brand: nil, servingSize: 182, servingUnit: "g", calories: 95, protein: 0.5, carbs: 25, fat: 0.3, fiber: 4.4, sugar: 19, sodium: 2),
            USDAFoodItem(fdcId: 2, name: "Banana, raw", brand: nil, servingSize: 118, servingUnit: "g", calories: 105, protein: 1.3, carbs: 27, fat: 0.4, fiber: 3.1, sugar: 14, sodium: 1),
            USDAFoodItem(fdcId: 3, name: "Orange, raw", brand: nil, servingSize: 154, servingUnit: "g", calories: 62, protein: 1.2, carbs: 15.4, fat: 0.2, fiber: 3.1, sugar: 12.2, sodium: 0),
            USDAFoodItem(fdcId: 4, name: "Strawberries, raw", brand: nil, servingSize: 152, servingUnit: "g", calories: 49, protein: 1, carbs: 11.7, fat: 0.5, fiber: 3, sugar: 7.4, sodium: 2),
            USDAFoodItem(fdcId: 5, name: "Blueberries, raw", brand: nil, servingSize: 148, servingUnit: "g", calories: 84, protein: 1.1, carbs: 21.4, fat: 0.5, fiber: 3.6, sugar: 15, sodium: 1),

            // Proteins
            USDAFoodItem(fdcId: 100, name: "Chicken breast, boneless, skinless, cooked", brand: nil, servingSize: 85, servingUnit: "g", calories: 140, protein: 26, carbs: 0, fat: 3, fiber: 0, sugar: 0, sodium: 74),
            USDAFoodItem(fdcId: 101, name: "Beef, ground, 93% lean, cooked", brand: nil, servingSize: 85, servingUnit: "g", calories: 164, protein: 25, carbs: 0, fat: 7, fiber: 0, sugar: 0, sodium: 66),
            USDAFoodItem(fdcId: 102, name: "Salmon, Atlantic, cooked", brand: nil, servingSize: 85, servingUnit: "g", calories: 175, protein: 19, carbs: 0, fat: 11, fiber: 0, sugar: 0, sodium: 52),
            USDAFoodItem(fdcId: 103, name: "Eggs, whole, cooked", brand: nil, servingSize: 50, servingUnit: "g", calories: 78, protein: 6, carbs: 0.6, fat: 5, fiber: 0, sugar: 0.6, sodium: 62),
            USDAFoodItem(fdcId: 104, name: "Turkey breast, sliced", brand: nil, servingSize: 85, servingUnit: "g", calories: 104, protein: 24, carbs: 0, fat: 0.5, fiber: 0, sugar: 0, sodium: 730),

            // Grains
            USDAFoodItem(fdcId: 200, name: "Rice, white, cooked", brand: nil, servingSize: 158, servingUnit: "g", calories: 205, protein: 4.3, carbs: 44.5, fat: 0.4, fiber: 0.6, sugar: 0.1, sodium: 1),
            USDAFoodItem(fdcId: 201, name: "Bread, whole wheat", brand: nil, servingSize: 28, servingUnit: "g", calories: 69, protein: 3.6, carbs: 12, fat: 1, fiber: 1.9, sugar: 1.4, sodium: 132),
            USDAFoodItem(fdcId: 202, name: "Pasta, cooked", brand: nil, servingSize: 140, servingUnit: "g", calories: 220, protein: 8, carbs: 43, fat: 1.3, fiber: 2.5, sugar: 0.8, sodium: 1),
            USDAFoodItem(fdcId: 203, name: "Oatmeal, cooked", brand: nil, servingSize: 234, servingUnit: "g", calories: 158, protein: 6, carbs: 27, fat: 3, fiber: 4, sugar: 0.6, sodium: 115),
            USDAFoodItem(fdcId: 204, name: "Quinoa, cooked", brand: nil, servingSize: 185, servingUnit: "g", calories: 222, protein: 8, carbs: 39, fat: 3.6, fiber: 5, sugar: 1.6, sodium: 13),

            // Dairy
            USDAFoodItem(fdcId: 300, name: "Milk, 2% fat", brand: nil, servingSize: 244, servingUnit: "g", calories: 122, protein: 8, carbs: 12, fat: 5, fiber: 0, sugar: 12, sodium: 115),
            USDAFoodItem(fdcId: 301, name: "Greek yogurt, plain", brand: nil, servingSize: 170, servingUnit: "g", calories: 100, protein: 17, carbs: 6, fat: 0, fiber: 0, sugar: 5, sodium: 60),
            USDAFoodItem(fdcId: 302, name: "Cheese, cheddar", brand: nil, servingSize: 28, servingUnit: "g", calories: 113, protein: 7, carbs: 0.4, fat: 9, fiber: 0, sugar: 0.1, sodium: 174),

            // Vegetables
            USDAFoodItem(fdcId: 400, name: "Broccoli, cooked", brand: nil, servingSize: 156, servingUnit: "g", calories: 55, protein: 3.7, carbs: 11, fat: 0.6, fiber: 5, sugar: 2.2, sodium: 64),
            USDAFoodItem(fdcId: 401, name: "Carrot, raw", brand: nil, servingSize: 128, servingUnit: "g", calories: 52, protein: 1.2, carbs: 12, fat: 0.3, fiber: 3.6, sugar: 6, sodium: 88),
            USDAFoodItem(fdcId: 402, name: "Spinach, raw", brand: nil, servingSize: 30, servingUnit: "g", calories: 7, protein: 0.9, carbs: 1.1, fat: 0.1, fiber: 0.7, sugar: 0.1, sodium: 24),
            USDAFoodItem(fdcId: 403, name: "Sweet potato, baked", brand: nil, servingSize: 200, servingUnit: "g", calories: 180, protein: 4, carbs: 41, fat: 0.3, fiber: 6.6, sugar: 13, sodium: 71),

            // Common branded foods
            USDAFoodItem(fdcId: 500, name: "Coca-Cola Classic", brand: "Coca-Cola", servingSize: 355, servingUnit: "ml", calories: 140, protein: 0, carbs: 39, fat: 0, fiber: 0, sugar: 39, sodium: 45),
            USDAFoodItem(fdcId: 501, name: "Big Mac", brand: "McDonald's", servingSize: 215, servingUnit: "g", calories: 563, protein: 26, carbs: 45, fat: 33, fiber: 3, sugar: 9, sodium: 1040)
        ]

        // Filter based on query
        return mockDatabase.filter { food in
            food.name.lowercased().contains(lowercaseQuery) ||
            (food.brand?.lowercased().contains(lowercaseQuery) ?? false)
        }
    }
}

// MARK: - Data Models

struct USDAFoodItem: Identifiable {
    let id = UUID()
    let fdcId: Int
    let name: String
    let brand: String?
    let servingSize: Double
    let servingUnit: String
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    let fiber: Double?
    let sugar: Double?
    let sodium: Double?
    var cholesterol: Double? = nil
    var saturatedFat: Double? = nil
    /// Vitamin/mineral data (vitamin_c, calcium, potassium, etc.) when USDA returns it.
    var additionalNutrients: [String: Double]? = nil

    // Convert to FoodItem for existing app compatibility
    func toFoodItem() -> FoodItem {
        return FoodItem(
            name: name,
            brand: brand,
            category: .other,
            servingSize: String(format: "%.0f", servingSize),
            servingUnit: servingUnit,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            fiber: fiber ?? 0,
            sugar: sugar ?? 0,
            sodium: sodium ?? 0,
            cholesterol: cholesterol,
            saturatedFat: saturatedFat,
            barcode: nil,
            isCommon: false,
            additionalNutrients: additionalNutrients
        )
    }
}

// MARK: - API Response Models (for production use)

struct USDAServiceSearchResponse: Codable {
    let foods: [USDAServiceFoodResponse]
    let totalHits: Int
}

struct USDAServiceFoodResponse: Codable {
    let fdcId: Int
    let description: String
    let brandName: String?
    let brandOwner: String?
    let servingSize: Double?
    let servingSizeUnit: String?
    let foodNutrients: [USDAServiceNutrient]

    func toUSDAFood() -> USDAFoodItem {
        // USDA values are always per 100g. Match by nutrient name (USDA API returns
        // names; the bulk USDAFoodImporter matches by nutrient ID instead).
        func value(_ nameMatchers: String...) -> Double? {
            for n in foodNutrients {
                let nm = n.nutrientName
                if nameMatchers.contains(where: { nm == $0 || nm.hasPrefix($0) }) {
                    return n.value
                }
            }
            return nil
        }

        let calsPer100 = value("Energy") ?? 0
        let protPer100 = value("Protein") ?? 0
        let carbsPer100 = value("Carbohydrate, by difference") ?? 0
        let fatPer100 = value("Total lipid (fat)") ?? 0
        let fiberPer100 = value("Fiber, total dietary")
        let sugarPer100 = value("Sugars, total including NLEA", "Sugars, total")
        let sodiumPer100 = value("Sodium, Na")
        let cholPer100 = value("Cholesterol")
        let satFatPer100 = value("Fatty acids, total saturated")

        // Scale from per-100g to the actual serving size
        let serving = servingSize ?? 100
        let scale = serving / 100.0

        // Capture vitamins/minerals into a dict keyed for AddCustomFoodView /
        // NutritionInfo+Foods. Only add keys whose source values are present.
        let vitMineralMap: [(matcher: String, key: String)] = [
            ("Vitamin A, RAE", "vitamin_a"),
            ("Vitamin C, total ascorbic acid", "vitamin_c"),
            ("Vitamin D (D2 + D3)", "vitamin_d"),
            ("Vitamin E (alpha-tocopherol)", "vitamin_e"),
            ("Vitamin K (phylloquinone)", "vitamin_k"),
            ("Thiamin", "thiamin"),
            ("Riboflavin", "riboflavin"),
            ("Niacin", "niacin"),
            ("Vitamin B-6", "vitamin_b6"),
            ("Vitamin B-12", "vitamin_b12"),
            ("Folate, total", "folate"),
            ("Calcium, Ca", "calcium"),
            ("Iron, Fe", "iron"),
            ("Magnesium, Mg", "magnesium"),
            ("Phosphorus, P", "phosphorus"),
            ("Potassium, K", "potassium"),
            ("Zinc, Zn", "zinc"),
            ("Copper, Cu", "copper"),
            ("Manganese, Mn", "manganese"),
            ("Selenium, Se", "selenium")
        ]
        var extras: [String: Double] = [:]
        for (matcher, key) in vitMineralMap {
            if let v = value(matcher), v > 0 {
                extras[key] = v * scale
            }
        }

        return USDAFoodItem(
            fdcId: fdcId,
            name: description,
            brand: brandName ?? brandOwner,
            servingSize: serving,
            servingUnit: servingSizeUnit ?? "g",
            calories: calsPer100 * scale,
            protein: protPer100 * scale,
            carbs: carbsPer100 * scale,
            fat: fatPer100 * scale,
            fiber: fiberPer100.map { $0 * scale },
            sugar: sugarPer100.map { $0 * scale },
            sodium: sodiumPer100.map { $0 * scale },
            cholesterol: cholPer100.map { $0 * scale },
            saturatedFat: satFatPer100.map { $0 * scale },
            additionalNutrients: extras.isEmpty ? nil : extras
        )
    }
}

struct USDAServiceNutrient: Codable {
    let nutrientName: String
    let value: Double?
    let unitName: String
}

// MARK: - Errors

enum USDAError: LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case apiKeyRequired

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid search URL"
        case .noData:
            return "No data received from USDA"
        case .decodingError:
            return "Could not parse USDA response"
        case .apiKeyRequired:
            return "Please add your USDA API key"
        }
    }
}