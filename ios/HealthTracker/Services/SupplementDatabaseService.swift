import Foundation
import CoreData

// MARK: - Enhanced Supplement Database Service
class SupplementDatabaseService {
    static let shared = SupplementDatabaseService()

    // Combine multiple data sources
    private let openFoodFactsService = SupplementBarcodeService.shared
    private var localDatabase: [String: LocalSupplement] = [:]

    init() {
        loadLocalDatabase()
    }

    // MARK: - Local Database Model
    struct LocalSupplement: Codable {
        let barcode: String
        let name: String
        let brand: String?
        let servingSize: String?
        let servingUnit: String?
        let ingredients: String?
        let imageURL: String?
        let nutrients: [LocalNutrient]
        let source: String
        let lastUpdated: Date
    }

    struct LocalNutrient: Codable {
        let name: String
        let amount: Double
        let unit: String
        let dailyValue: Double?
    }

    // MARK: - Comprehensive Lookup
    func lookupSupplement(barcode: String) async throws -> SupplementBarcodeService.SupplementInfo? {
        // 1. Check local scraped database first (fastest)
        if let localSupplement = localDatabase[barcode] {
            return convertToSupplementInfo(localSupplement)
        }

        // 2. Try Open Food Facts API
        if let supplement = try await openFoodFactsService.lookupSupplement(barcode: barcode) {
            // Cache it locally
            cacheSupplementLocally(supplement)
            return supplement
        }

        // 3. Check preloaded common supplements
        if let commonSupplement = getCommonSupplement(barcode: barcode) {
            return commonSupplement
        }

        return nil
    }

    // MARK: - Load Scraped Database
    private func loadLocalDatabase() {
        // Load from bundled JSON file if available
        if let url = Bundle.main.url(forResource: "supplements_database", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let supplements = try? JSONDecoder().decode([LocalSupplement].self, from: data) {
            for supplement in supplements {
                localDatabase[supplement.barcode] = supplement
            }
        }

        // Also load from Documents directory (for updates)
        loadFromDocuments()
    }

    private func loadFromDocuments() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let databasePath = documentsPath.appendingPathComponent("supplements_database.json")

        if let data = try? Data(contentsOf: databasePath),
           let supplements = try? JSONDecoder().decode([LocalSupplement].self, from: data) {
            for supplement in supplements {
                localDatabase[supplement.barcode] = supplement
            }
        }
    }

    // MARK: - Convert Between Formats
    private func convertToSupplementInfo(_ local: LocalSupplement) -> SupplementBarcodeService.SupplementInfo {
        let nutrients = local.nutrients.map { nutrient in
            SupplementBarcodeService.Nutrient(
                name: nutrient.name,
                amount: nutrient.amount,
                unit: nutrient.unit,
                dailyValue: nutrient.dailyValue
            )
        }

        return SupplementBarcodeService.SupplementInfo(
            barcode: local.barcode,
            name: local.name,
            brand: local.brand,
            servingSize: local.servingSize,
            servingUnit: local.servingUnit,
            ingredients: local.ingredients,
            imageURL: local.imageURL,
            nutrients: nutrients,
            source: .cached
        )
    }

    // MARK: - Cache Management
    private func cacheSupplementLocally(_ supplement: SupplementBarcodeService.SupplementInfo) {
        let localSupplement = LocalSupplement(
            barcode: supplement.barcode,
            name: supplement.name,
            brand: supplement.brand,
            servingSize: supplement.servingSize,
            servingUnit: supplement.servingUnit,
            ingredients: supplement.ingredients,
            imageURL: supplement.imageURL,
            nutrients: supplement.nutrients.map { nutrient in
                LocalNutrient(
                    name: nutrient.name,
                    amount: nutrient.amount,
                    unit: nutrient.unit,
                    dailyValue: nutrient.dailyValue
                )
            },
            source: "api",
            lastUpdated: Date()
        )

        localDatabase[supplement.barcode] = localSupplement
        saveToDocuments()
    }

    private func saveToDocuments() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let databasePath = documentsPath.appendingPathComponent("supplements_database.json")

        let supplements = Array(localDatabase.values)
        if let data = try? JSONEncoder().encode(supplements) {
            try? data.write(to: databasePath)
        }
    }

    // MARK: - Common Supplements Database
    private func getCommonSupplement(barcode: String) -> SupplementBarcodeService.SupplementInfo? {
        // Hardcoded common supplements as fallback
        let commonSupplements: [String: (name: String, brand: String, nutrients: [(String, Double, String, Double?)])] = [
            "GENERIC_MULTIVITAMIN": (
                name: "Multivitamin",
                brand: "Generic",
                nutrients: [
                    ("Vitamin A", 900, "µg", 100),
                    ("Vitamin C", 90, "mg", 100),
                    ("Vitamin D", 20, "µg", 100),
                    ("Vitamin E", 15, "mg", 100),
                    ("Thiamine", 1.2, "mg", 100),
                    ("Riboflavin", 1.3, "mg", 100),
                    ("Niacin", 16, "mg", 100),
                    ("Vitamin B6", 1.7, "mg", 100),
                    ("Folate", 400, "µg", 100),
                    ("Vitamin B12", 2.4, "µg", 100)
                ]
            ),
            "GENERIC_VITAMIN_D3": (
                name: "Vitamin D3",
                brand: "Generic",
                nutrients: [
                    ("Vitamin D3", 50, "µg", 250)
                ]
            ),
            "GENERIC_OMEGA3": (
                name: "Omega-3 Fish Oil",
                brand: "Generic",
                nutrients: [
                    ("EPA", 360, "mg", nil),
                    ("DHA", 240, "mg", nil),
                    ("Total Omega-3", 600, "mg", nil)
                ]
            ),
            "GENERIC_PROBIOTIC": (
                name: "Probiotic",
                brand: "Generic",
                nutrients: [
                    ("Probiotic Blend", 10, "billion CFU", nil)
                ]
            ),
            "GENERIC_CALCIUM": (
                name: "Calcium + Vitamin D",
                brand: "Generic",
                nutrients: [
                    ("Calcium", 600, "mg", 46),
                    ("Vitamin D3", 10, "µg", 50)
                ]
            ),
            "030768011154": (
                name: "Vitamin D3 5000 IU",
                brand: "Nature Made",
                nutrients: [
                    ("Vitamin D3", 125, "µg", 625)
                ]
            ),
            "031604026165": (
                name: "Centrum Silver Adults 50+",
                brand: "Centrum",
                nutrients: [
                    ("Vitamin A", 900, "µg", 100),
                    ("Vitamin C", 90, "mg", 100),
                    ("Vitamin D3", 25, "µg", 125),
                    ("Vitamin E", 15, "mg", 100),
                    ("Vitamin B12", 25, "µg", 1042),
                    ("Calcium", 220, "mg", 17),
                    ("Zinc", 11, "mg", 100)
                ]
            )
        ]

        guard let supplement = commonSupplements[barcode] else { return nil }

        let nutrients = supplement.nutrients.map { nutrient in
            SupplementBarcodeService.Nutrient(
                name: nutrient.0,
                amount: nutrient.1,
                unit: nutrient.2,
                dailyValue: nutrient.3
            )
        }

        return SupplementBarcodeService.SupplementInfo(
            barcode: barcode,
            name: supplement.name,
            brand: supplement.brand,
            servingSize: "1",
            servingUnit: "serving",
            ingredients: nil,
            imageURL: nil,
            nutrients: nutrients,
            source: .cached
        )
    }

    // MARK: - Search Functions
    func searchSupplements(query: String) -> [LocalSupplement] {
        let lowercasedQuery = query.lowercased()
        return localDatabase.values.filter { supplement in
            supplement.name.lowercased().contains(lowercasedQuery) ||
            (supplement.brand?.lowercased().contains(lowercasedQuery) ?? false)
        }
    }

    // MARK: - Update Database from Server
    func updateDatabaseFromServer() async {
        // This could download updated database from your server
        guard let url = URL(string: "https://yourserver.com/supplements_database.json") else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let supplements = try JSONDecoder().decode([LocalSupplement].self, from: data)

            for supplement in supplements {
                localDatabase[supplement.barcode] = supplement
            }

            saveToDocuments()
        } catch {
            print("Failed to update database: \(error)")
        }
    }
}