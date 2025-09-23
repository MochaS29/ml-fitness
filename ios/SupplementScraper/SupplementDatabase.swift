// Auto-generated Supplement Database
// Generated: 2025-09-23T14:02:27.721243

import Foundation

struct PreloadedSupplement {
    let barcode: String
    let name: String
    let brand: String?
    let servingSize: String?
    let servingUnit: String?
    let ingredients: String?
    let nutrients: [PreloadedNutrient]
}

struct PreloadedNutrient {
    let name: String
    let amount: Double
    let unit: String
    let dailyValue: Double?
}

class SupplementDatabase {
    static let shared = SupplementDatabase()

    private let supplements: [String: PreloadedSupplement] = [

        "GENERIC_MULTIVITAMIN": PreloadedSupplement(
            barcode: "GENERIC_MULTIVITAMIN",
            name: "Multivitamin",
            brand: "Generic",
            servingSize: "1",
            servingUnit: "serving",
            ingredients: nil,
            nutrients: [
            PreloadedNutrient(
                name: "Folate",
                amount: 400.0,
                unit: "µg",
                dailyValue: 100.0
            ),
            PreloadedNutrient(
                name: "Niacin",
                amount: 16.0,
                unit: "mg",
                dailyValue: 100.0
            ),
            PreloadedNutrient(
                name: "Riboflavin",
                amount: 1.3,
                unit: "mg",
                dailyValue: 100.0
            ),
            PreloadedNutrient(
                name: "Thiamine",
                amount: 1.2,
                unit: "mg",
                dailyValue: 100.0
            ),
            PreloadedNutrient(
                name: "Vitamin A",
                amount: 900.0,
                unit: "µg",
                dailyValue: 100.0
            ),
            PreloadedNutrient(
                name: "Vitamin B12",
                amount: 2.4,
                unit: "µg",
                dailyValue: 100.0
            ),
            PreloadedNutrient(
                name: "Vitamin B6",
                amount: 1.7,
                unit: "mg",
                dailyValue: 100.0
            ),
            PreloadedNutrient(
                name: "Vitamin C",
                amount: 90.0,
                unit: "mg",
                dailyValue: 100.0
            ),
            PreloadedNutrient(
                name: "Vitamin D",
                amount: 20.0,
                unit: "µg",
                dailyValue: 100.0
            ),
            PreloadedNutrient(
                name: "Vitamin E",
                amount: 15.0,
                unit: "mg",
                dailyValue: 100.0
            )
        ]
        ),

        "GENERIC_VITAMIN_D3": PreloadedSupplement(
            barcode: "GENERIC_VITAMIN_D3",
            name: "Vitamin D3",
            brand: "Generic",
            servingSize: "1",
            servingUnit: "softgel",
            ingredients: nil,
            nutrients: [
            PreloadedNutrient(
                name: "Vitamin D3",
                amount: 50.0,
                unit: "µg",
                dailyValue: 250.0
            )
        ]
        ),

        "GENERIC_OMEGA-3_FISH_OIL": PreloadedSupplement(
            barcode: "GENERIC_OMEGA-3_FISH_OIL",
            name: "Omega-3 Fish Oil",
            brand: "Generic",
            servingSize: "2",
            servingUnit: "softgels",
            ingredients: nil,
            nutrients: [
            PreloadedNutrient(
                name: "DHA",
                amount: 240.0,
                unit: "mg",
                dailyValue: nil
            ),
            PreloadedNutrient(
                name: "EPA",
                amount: 360.0,
                unit: "mg",
                dailyValue: nil
            ),
            PreloadedNutrient(
                name: "Total Omega-3",
                amount: 600.0,
                unit: "mg",
                dailyValue: nil
            )
        ]
        ),

        "GENERIC_PROBIOTIC": PreloadedSupplement(
            barcode: "GENERIC_PROBIOTIC",
            name: "Probiotic",
            brand: "Generic",
            servingSize: "1",
            servingUnit: "capsule",
            ingredients: nil,
            nutrients: [
            PreloadedNutrient(
                name: "Probiotic Blend",
                amount: 10.0,
                unit: "billion CFU",
                dailyValue: nil
            )
        ]
        ),

        "GENERIC_CALCIUM_+_VITAMIN_D": PreloadedSupplement(
            barcode: "GENERIC_CALCIUM_+_VITAMIN_D",
            name: "Calcium + Vitamin D",
            brand: "Generic",
            servingSize: "1",
            servingUnit: "serving",
            ingredients: nil,
            nutrients: [
            PreloadedNutrient(
                name: "Calcium",
                amount: 600.0,
                unit: "mg",
                dailyValue: 46.0
            ),
            PreloadedNutrient(
                name: "Vitamin D3",
                amount: 10.0,
                unit: "µg",
                dailyValue: 50.0
            )
        ]
        ),

        "GENERIC_MAGNESIUM_GLYCINATE": PreloadedSupplement(
            barcode: "GENERIC_MAGNESIUM_GLYCINATE",
            name: "Magnesium Glycinate",
            brand: "Generic",
            servingSize: "1",
            servingUnit: "serving",
            ingredients: nil,
            nutrients: [
            PreloadedNutrient(
                name: "Magnesium",
                amount: 200.0,
                unit: "mg",
                dailyValue: 48.0
            )
        ]
        ),

        "GENERIC_B-COMPLEX": PreloadedSupplement(
            barcode: "GENERIC_B-COMPLEX",
            name: "B-Complex",
            brand: "Generic",
            servingSize: "1",
            servingUnit: "serving",
            ingredients: nil,
            nutrients: [
            PreloadedNutrient(
                name: "Biotin",
                amount: 300.0,
                unit: "µg",
                dailyValue: 1000.0
            ),
            PreloadedNutrient(
                name: "Folate",
                amount: 400.0,
                unit: "µg",
                dailyValue: 100.0
            ),
            PreloadedNutrient(
                name: "Niacin (B3)",
                amount: 50.0,
                unit: "mg",
                dailyValue: 313.0
            ),
            PreloadedNutrient(
                name: "Pantothenic Acid",
                amount: 50.0,
                unit: "mg",
                dailyValue: 1000.0
            ),
            PreloadedNutrient(
                name: "Riboflavin (B2)",
                amount: 50.0,
                unit: "mg",
                dailyValue: 3846.0
            ),
            PreloadedNutrient(
                name: "Thiamine (B1)",
                amount: 50.0,
                unit: "mg",
                dailyValue: 4167.0
            ),
            PreloadedNutrient(
                name: "Vitamin B12",
                amount: 50.0,
                unit: "µg",
                dailyValue: 2083.0
            ),
            PreloadedNutrient(
                name: "Vitamin B6",
                amount: 50.0,
                unit: "mg",
                dailyValue: 2941.0
            )
        ]
        ),

    ]

    func lookup(barcode: String) -> PreloadedSupplement? {
        return supplements[barcode]
    }

    func search(query: String) -> [PreloadedSupplement] {
        let lowercasedQuery = query.lowercased()
        return supplements.values.filter { supplement in
            supplement.name.lowercased().contains(lowercasedQuery) ||
            (supplement.brand?.lowercased().contains(lowercasedQuery) ?? false)
        }
    }
}
