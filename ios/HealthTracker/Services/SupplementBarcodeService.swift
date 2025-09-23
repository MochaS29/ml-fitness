import Foundation
import AVFoundation
import SwiftUI

// MARK: - Supplement Barcode Service
class SupplementBarcodeService: ObservableObject {
    static let shared = SupplementBarcodeService()

    @Published var isLoading = false
    @Published var lastError: String?

    private let openFoodFactsBaseURL = "https://world.openfoodfacts.org/api/v2"
    private let spoonacularApiKey = "78925a5a97ef4f53a8fc692cad0b1618"
    private let nutritionixAppId = "YOUR_APP_ID" // Add your API credentials if you have them
    private let nutritionixApiKey = "YOUR_API_KEY"

    // MARK: - Models
    struct SupplementInfo {
        let barcode: String
        let name: String
        let brand: String?
        let servingSize: String?
        let servingUnit: String?
        let ingredients: String?
        let imageURL: String?
        let nutrients: [Nutrient]
        let source: DataSource

        enum DataSource {
            case openFoodFacts
            case nutritionix
            case manual
            case cached
        }
    }

    struct Nutrient {
        let name: String
        let amount: Double
        let unit: String
        let dailyValue: Double? // Percentage
    }

    // MARK: - Public Methods

    func lookupSupplement(barcode: String) async throws -> SupplementInfo? {
        isLoading = true
        defer { isLoading = false }

        // Try Open Food Facts first (free)
        if let supplement = try await fetchFromOpenFoodFacts(barcode: barcode) {
            return supplement
        }

        // Try Spoonacular API (free tier: 150 requests/day)
        if let supplement = try await fetchFromSpoonacular(barcode: barcode) {
            return supplement
        }

        // Try Nutritionix if credentials are configured (paid)
        if nutritionixAppId != "YOUR_APP_ID" {
            if let supplement = try await fetchFromNutritionix(barcode: barcode) {
                return supplement
            }
        }

        // Check local cache/database
        if let supplement = fetchFromLocalCache(barcode: barcode) {
            return supplement
        }

        return nil
    }

    // MARK: - Open Food Facts API

    private func fetchFromOpenFoodFacts(barcode: String) async throws -> SupplementInfo? {
        let urlString = "\(openFoodFactsBaseURL)/product/\(barcode).json"
        guard let url = URL(string: urlString) else {
            throw BarcodeError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            return nil
        }

        let decoder = JSONDecoder()
        let result = try decoder.decode(OpenFoodFactsResponse.self, from: data)

        guard result.status == 1, let product = result.product else {
            return nil
        }

        return parseOpenFoodFactsProduct(product, barcode: barcode)
    }

    private func parseOpenFoodFactsProduct(_ product: OpenFoodFactsProduct, barcode: String) -> SupplementInfo {
        var nutrients: [Nutrient] = []

        // Parse common supplement nutrients
        if let vitaminC = product.nutriments?.vitaminC100g {
            nutrients.append(Nutrient(
                name: "Vitamin C",
                amount: vitaminC,
                unit: "mg",
                dailyValue: (vitaminC / 90) * 100 // 90mg is daily value
            ))
        }

        if let vitaminD = product.nutriments?.vitaminD100g {
            nutrients.append(Nutrient(
                name: "Vitamin D",
                amount: vitaminD,
                unit: "µg",
                dailyValue: (vitaminD / 20) * 100 // 20µg is daily value
            ))
        }

        if let calcium = product.nutriments?.calcium100g {
            nutrients.append(Nutrient(
                name: "Calcium",
                amount: calcium,
                unit: "mg",
                dailyValue: (calcium / 1300) * 100
            ))
        }

        if let iron = product.nutriments?.iron100g {
            nutrients.append(Nutrient(
                name: "Iron",
                amount: iron,
                unit: "mg",
                dailyValue: (iron / 18) * 100
            ))
        }

        return SupplementInfo(
            barcode: barcode,
            name: product.productName ?? "Unknown Supplement",
            brand: product.brands,
            servingSize: product.servingSize,
            servingUnit: "serving",
            ingredients: product.ingredientsText,
            imageURL: product.imageFrontURL,
            nutrients: nutrients,
            source: .openFoodFacts
        )
    }

    // MARK: - Spoonacular API

    private func fetchFromSpoonacular(barcode: String) async throws -> SupplementInfo? {
        let urlString = "https://api.spoonacular.com/food/products/upc/\(barcode)?apiKey=\(spoonacularApiKey)"
        guard let url = URL(string: urlString) else {
            throw BarcodeError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            return nil
        }

        let decoder = JSONDecoder()
        let result = try decoder.decode(SpoonacularProduct.self, from: data)

        return parseSpoonacularProduct(result, barcode: barcode)
    }

    private func parseSpoonacularProduct(_ product: SpoonacularProduct, barcode: String) -> SupplementInfo {
        var nutrients: [Nutrient] = []

        // Parse nutrients from Spoonacular format
        if let nutritionData = product.nutrition {
            for nutrient in nutritionData.nutrients {
                let name = nutrient.name
                let amount = nutrient.amount
                let unit = nutrient.unit
                let dailyValue = nutrient.percentOfDailyNeeds

                nutrients.append(Nutrient(
                    name: name,
                    amount: amount,
                    unit: unit,
                    dailyValue: dailyValue
                ))
            }
        }

        return SupplementInfo(
            barcode: barcode,
            name: product.title,
            brand: product.brand,
            servingSize: product.servingSize,
            servingUnit: product.servingUnit ?? "serving",
            ingredients: product.ingredientList,
            imageURL: product.image,
            nutrients: nutrients,
            source: .openFoodFacts // Using same enum case for now
        )
    }

    // MARK: - Nutritionix API (Paid - Better for supplements)

    private func fetchFromNutritionix(barcode: String) async throws -> SupplementInfo? {
        // Implementation for Nutritionix API if you have credentials
        // This API has better supplement coverage but requires paid subscription
        return nil
    }

    // MARK: - Local Cache

    private func fetchFromLocalCache(barcode: String) -> SupplementInfo? {
        // Check UserDefaults or Core Data for previously scanned items
        if let cachedData = UserDefaults.standard.data(forKey: "supplement_\(barcode)"),
           let supplement = try? JSONDecoder().decode(CachedSupplement.self, from: cachedData) {
            return supplement.toSupplementInfo()
        }
        return nil
    }

    func cacheSupplement(_ supplement: SupplementInfo) {
        let cached = CachedSupplement(from: supplement)
        if let data = try? JSONEncoder().encode(cached) {
            UserDefaults.standard.set(data, forKey: "supplement_\(supplement.barcode)")
        }
    }

    // MARK: - Manual Entry Fallback

    func createManualEntry(
        barcode: String,
        name: String,
        brand: String?,
        servingSize: String?,
        nutrients: [(name: String, amount: Double, unit: String)]
    ) -> SupplementInfo {
        let nutrientList = nutrients.map { nutrient in
            Nutrient(
                name: nutrient.name,
                amount: nutrient.amount,
                unit: nutrient.unit,
                dailyValue: nil
            )
        }

        let supplement = SupplementInfo(
            barcode: barcode,
            name: name,
            brand: brand,
            servingSize: servingSize,
            servingUnit: "serving",
            ingredients: nil,
            imageURL: nil,
            nutrients: nutrientList,
            source: .manual
        )

        // Cache for future use
        cacheSupplement(supplement)

        return supplement
    }
}

// MARK: - Error Types

enum BarcodeError: LocalizedError {
    case invalidURL
    case networkError
    case decodingError
    case notFound

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid barcode URL"
        case .networkError:
            return "Network connection error"
        case .decodingError:
            return "Failed to parse product data"
        case .notFound:
            return "Product not found in database"
        }
    }
}

// MARK: - API Response Models

struct OpenFoodFactsResponse: Codable {
    let status: Int
    let statusVerbose: String?
    let product: OpenFoodFactsProduct?

    enum CodingKeys: String, CodingKey {
        case status
        case statusVerbose = "status_verbose"
        case product
    }
}

// Spoonacular API Models
struct SpoonacularProduct: Codable {
    let id: Int?
    let title: String
    let brand: String?
    let image: String?
    let servingSize: String?
    let servingUnit: String?
    let ingredientList: String?
    let nutrition: SpoonacularNutrition?
}

struct SpoonacularNutrition: Codable {
    let nutrients: [SpoonacularNutrient]
}

struct SpoonacularNutrient: Codable {
    let name: String
    let amount: Double
    let unit: String
    let percentOfDailyNeeds: Double?
}

struct OpenFoodFactsProduct: Codable {
    let productName: String?
    let brands: String?
    let servingSize: String?
    let ingredientsText: String?
    let imageFrontURL: String?
    let nutriments: Nutriments?

    enum CodingKeys: String, CodingKey {
        case productName = "product_name"
        case brands
        case servingSize = "serving_size"
        case ingredientsText = "ingredients_text"
        case imageFrontURL = "image_front_url"
        case nutriments
    }
}

struct Nutriments: Codable {
    let vitaminC100g: Double?
    let vitaminD100g: Double?
    let calcium100g: Double?
    let iron100g: Double?
    let vitaminB12100g: Double?
    let omega3100g: Double?
    let proteins100g: Double?

    enum CodingKeys: String, CodingKey {
        case vitaminC100g = "vitamin-c_100g"
        case vitaminD100g = "vitamin-d_100g"
        case calcium100g = "calcium_100g"
        case iron100g = "iron_100g"
        case vitaminB12100g = "vitamin-b12_100g"
        case omega3100g = "omega-3-fatty-acids_100g"
        case proteins100g = "proteins_100g"
    }
}

// MARK: - Cache Model

struct CachedSupplement: Codable {
    let barcode: String
    let name: String
    let brand: String?
    let servingSize: String?
    let servingUnit: String?
    let ingredients: String?
    let imageURL: String?
    let nutrients: [CachedNutrient]
    let dateCached: Date

    struct CachedNutrient: Codable {
        let name: String
        let amount: Double
        let unit: String
        let dailyValue: Double?
    }

    init(from supplement: SupplementBarcodeService.SupplementInfo) {
        self.barcode = supplement.barcode
        self.name = supplement.name
        self.brand = supplement.brand
        self.servingSize = supplement.servingSize
        self.servingUnit = supplement.servingUnit
        self.ingredients = supplement.ingredients
        self.imageURL = supplement.imageURL
        self.nutrients = supplement.nutrients.map { nutrient in
            CachedNutrient(
                name: nutrient.name,
                amount: nutrient.amount,
                unit: nutrient.unit,
                dailyValue: nutrient.dailyValue
            )
        }
        self.dateCached = Date()
    }

    func toSupplementInfo() -> SupplementBarcodeService.SupplementInfo {
        SupplementBarcodeService.SupplementInfo(
            barcode: barcode,
            name: name,
            brand: brand,
            servingSize: servingSize,
            servingUnit: servingUnit,
            ingredients: ingredients,
            imageURL: imageURL,
            nutrients: nutrients.map { nutrient in
                SupplementBarcodeService.Nutrient(
                    name: nutrient.name,
                    amount: nutrient.amount,
                    unit: nutrient.unit,
                    dailyValue: nutrient.dailyValue
                )
            },
            source: .cached
        )
    }
}