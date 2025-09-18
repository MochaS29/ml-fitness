import Foundation

// MARK: - Supplement Models
struct Supplement: Identifiable, Codable {
    let id: String
    let brand: String
    let name: String
    let category: SupplementCategory
    let servingSize: String
    let servingsPerContainer: Int
    let barcode: String?
    let dpn: String? // Drug Product Number (Canada)
    let upc: String? // Universal Product Code

    // Nutritional content per serving
    let vitamins: VitaminContent
    let minerals: MineralContent
    let otherIngredients: [OtherIngredient]

    // Metadata
    let targetGender: SupplementGender
    let ageGroup: SupplementAgeGroup
    let price: Double?
    let countryAvailability: [String]
    let warnings: [String]
    let benefits: [String]
    let dosageInstructions: String
    let imageUrl: String?
}

enum SupplementCategory: String, Codable, CaseIterable {
    case multivitamin = "Multivitamin"
    case vitamin = "Single Vitamin"
    case mineral = "Mineral"
    case omega = "Omega Fatty Acids"
    case probiotic = "Probiotic"
    case herbal = "Herbal"
    case protein = "Protein"
    case specialty = "Specialty"
    case prenatal = "Prenatal"
}

enum SupplementGender: String, Codable {
    case male = "Male"
    case female = "Female"
    case unisex = "Unisex"
}

enum SupplementAgeGroup: String, Codable {
    case child = "Child (4-12)"
    case teen = "Teen (13-18)"
    case adult = "Adult (19-50)"
    case senior50Plus = "50+"
    case senior65Plus = "65+"
    case all = "All Ages"
}

struct VitaminContent: Codable {
    // Fat-soluble vitamins
    let vitaminA: NutrientAmount?
    let vitaminD: NutrientAmount?
    let vitaminE: NutrientAmount?
    let vitaminK: NutrientAmount?

    // B-complex vitamins
    let vitaminB1_thiamine: NutrientAmount?
    let vitaminB2_riboflavin: NutrientAmount?
    let vitaminB3_niacin: NutrientAmount?
    let vitaminB5_pantothenicAcid: NutrientAmount?
    let vitaminB6: NutrientAmount?
    let vitaminB7_biotin: NutrientAmount?
    let vitaminB9_folate: NutrientAmount?
    let vitaminB12: NutrientAmount?

    // Other vitamins
    let vitaminC: NutrientAmount?
    let choline: NutrientAmount?
}

struct MineralContent: Codable {
    let calcium: NutrientAmount?
    let iron: NutrientAmount?
    let magnesium: NutrientAmount?
    let phosphorus: NutrientAmount?
    let potassium: NutrientAmount?
    let sodium: NutrientAmount?
    let zinc: NutrientAmount?
    let copper: NutrientAmount?
    let manganese: NutrientAmount?
    let selenium: NutrientAmount?
    let chromium: NutrientAmount?
    let molybdenum: NutrientAmount?
    let iodine: NutrientAmount?
    let chloride: NutrientAmount?
}

struct OtherIngredient: Codable {
    let name: String
    let amount: NutrientAmount?
    let category: String // e.g., "Omega-3", "Probiotic", "Herbal"
}

struct NutrientAmount: Codable {
    let amount: Double
    let unit: String // mg, mcg, IU, etc.
    let percentDV: Double? // Percent Daily Value
}

// MARK: - Supplement Database
class SupplementDatabase {
    static let shared = SupplementDatabase()

    private init() {}

    // MARK: - Top Multivitamins for Men (Canada/North America)

    let mensMultivitamins = [
        Supplement(
            id: "centrum-men",
            brand: "Centrum",
            name: "Centrum Men Multivitamin",
            category: .multivitamin,
            servingSize: "1 tablet",
            servingsPerContainer: 120,
            barcode: "305730112406",
            dpn: "80098265",
            upc: "305730112406",
            vitamins: VitaminContent(
                vitaminA: NutrientAmount(amount: 1050, unit: "mcg", percentDV: 117),
                vitaminD: NutrientAmount(amount: 25, unit: "mcg", percentDV: 125),
                vitaminE: NutrientAmount(amount: 15, unit: "mg", percentDV: 100),
                vitaminK: NutrientAmount(amount: 60, unit: "mcg", percentDV: 50),
                vitaminB1_thiamine: NutrientAmount(amount: 1.2, unit: "mg", percentDV: 100),
                vitaminB2_riboflavin: NutrientAmount(amount: 1.3, unit: "mg", percentDV: 100),
                vitaminB3_niacin: NutrientAmount(amount: 16, unit: "mg", percentDV: 100),
                vitaminB5_pantothenicAcid: NutrientAmount(amount: 5, unit: "mg", percentDV: 100),
                vitaminB6: NutrientAmount(amount: 2, unit: "mg", percentDV: 118),
                vitaminB7_biotin: NutrientAmount(amount: 40, unit: "mcg", percentDV: 133),
                vitaminB9_folate: NutrientAmount(amount: 400, unit: "mcg", percentDV: 100),
                vitaminB12: NutrientAmount(amount: 25, unit: "mcg", percentDV: 1042),
                vitaminC: NutrientAmount(amount: 90, unit: "mg", percentDV: 100),
                choline: nil
            ),
            minerals: MineralContent(
                calcium: NutrientAmount(amount: 210, unit: "mg", percentDV: 16),
                iron: NutrientAmount(amount: 0, unit: "mg", percentDV: 0), // No iron in men's formula
                magnesium: NutrientAmount(amount: 110, unit: "mg", percentDV: 26),
                phosphorus: NutrientAmount(amount: 125, unit: "mg", percentDV: 10),
                potassium: NutrientAmount(amount: 80, unit: "mg", percentDV: 2),
                sodium: nil,
                zinc: NutrientAmount(amount: 11, unit: "mg", percentDV: 100),
                copper: NutrientAmount(amount: 0.9, unit: "mg", percentDV: 100),
                manganese: NutrientAmount(amount: 2.3, unit: "mg", percentDV: 100),
                selenium: NutrientAmount(amount: 55, unit: "mcg", percentDV: 100),
                chromium: NutrientAmount(amount: 35, unit: "mcg", percentDV: 100),
                molybdenum: NutrientAmount(amount: 45, unit: "mcg", percentDV: 100),
                iodine: NutrientAmount(amount: 150, unit: "mcg", percentDV: 100),
                chloride: nil
            ),
            otherIngredients: [
                OtherIngredient(name: "Lycopene", amount: NutrientAmount(amount: 600, unit: "mcg", percentDV: nil), category: "Antioxidant")
            ],
            targetGender: .male,
            ageGroup: .adult,
            price: 19.99,
            countryAvailability: ["Canada", "USA"],
            warnings: ["Keep out of reach of children", "Do not exceed recommended dose"],
            benefits: ["Energy support", "Immune health", "Heart health", "No iron formula"],
            dosageInstructions: "Take 1 tablet daily with food",
            imageUrl: nil
        ),

        Supplement(
            id: "one-a-day-men",
            brand: "One A Day",
            name: "One A Day Men's Complete Multivitamin",
            category: .multivitamin,
            servingSize: "1 tablet",
            servingsPerContainer: 200,
            barcode: "016500556763",
            dpn: nil,
            upc: "016500556763",
            vitamins: VitaminContent(
                vitaminA: NutrientAmount(amount: 940, unit: "mcg", percentDV: 104),
                vitaminD: NutrientAmount(amount: 17.5, unit: "mcg", percentDV: 88),
                vitaminE: NutrientAmount(amount: 10, unit: "mg", percentDV: 67),
                vitaminK: NutrientAmount(amount: 60, unit: "mcg", percentDV: 50),
                vitaminB1_thiamine: NutrientAmount(amount: 4.5, unit: "mg", percentDV: 375),
                vitaminB2_riboflavin: NutrientAmount(amount: 1.7, unit: "mg", percentDV: 131),
                vitaminB3_niacin: NutrientAmount(amount: 18, unit: "mg", percentDV: 113),
                vitaminB5_pantothenicAcid: NutrientAmount(amount: 15, unit: "mg", percentDV: 300),
                vitaminB6: NutrientAmount(amount: 6, unit: "mg", percentDV: 353),
                vitaminB7_biotin: NutrientAmount(amount: 30, unit: "mcg", percentDV: 100),
                vitaminB9_folate: NutrientAmount(amount: 400, unit: "mcg", percentDV: 100),
                vitaminB12: NutrientAmount(amount: 18, unit: "mcg", percentDV: 750),
                vitaminC: NutrientAmount(amount: 60, unit: "mg", percentDV: 67),
                choline: nil
            ),
            minerals: MineralContent(
                calcium: NutrientAmount(amount: 120, unit: "mg", percentDV: 9),
                iron: nil,
                magnesium: NutrientAmount(amount: 140, unit: "mg", percentDV: 33),
                phosphorus: nil,
                potassium: nil,
                sodium: nil,
                zinc: NutrientAmount(amount: 11, unit: "mg", percentDV: 100),
                copper: NutrientAmount(amount: 2, unit: "mg", percentDV: 222),
                manganese: NutrientAmount(amount: 2, unit: "mg", percentDV: 87),
                selenium: NutrientAmount(amount: 55, unit: "mcg", percentDV: 100),
                chromium: NutrientAmount(amount: 120, unit: "mcg", percentDV: 343),
                molybdenum: nil,
                iodine: NutrientAmount(amount: 150, unit: "mcg", percentDV: 100),
                chloride: nil
            ),
            otherIngredients: [],
            targetGender: .male,
            ageGroup: .adult,
            price: 14.99,
            countryAvailability: ["Canada", "USA"],
            warnings: ["Keep out of reach of children"],
            benefits: ["Heart health", "Immune support", "Physical energy", "Muscle function"],
            dosageInstructions: "Take 1 tablet daily with food",
            imageUrl: nil
        )
    ]

    // MARK: - Top Multivitamins for Women (Canada/North America)

    let womensMultivitamins = [
        Supplement(
            id: "centrum-women",
            brand: "Centrum",
            name: "Centrum Women Multivitamin",
            category: .multivitamin,
            servingSize: "1 tablet",
            servingsPerContainer: 120,
            barcode: "305730112307",
            dpn: "80098264",
            upc: "305730112307",
            vitamins: VitaminContent(
                vitaminA: NutrientAmount(amount: 800, unit: "mcg", percentDV: 89),
                vitaminD: NutrientAmount(amount: 25, unit: "mcg", percentDV: 125),
                vitaminE: NutrientAmount(amount: 15, unit: "mg", percentDV: 100),
                vitaminK: NutrientAmount(amount: 60, unit: "mcg", percentDV: 50),
                vitaminB1_thiamine: NutrientAmount(amount: 1.1, unit: "mg", percentDV: 92),
                vitaminB2_riboflavin: NutrientAmount(amount: 1.1, unit: "mg", percentDV: 85),
                vitaminB3_niacin: NutrientAmount(amount: 14, unit: "mg", percentDV: 88),
                vitaminB5_pantothenicAcid: NutrientAmount(amount: 5, unit: "mg", percentDV: 100),
                vitaminB6: NutrientAmount(amount: 2, unit: "mg", percentDV: 118),
                vitaminB7_biotin: NutrientAmount(amount: 40, unit: "mcg", percentDV: 133),
                vitaminB9_folate: NutrientAmount(amount: 400, unit: "mcg", percentDV: 100),
                vitaminB12: NutrientAmount(amount: 25, unit: "mcg", percentDV: 1042),
                vitaminC: NutrientAmount(amount: 75, unit: "mg", percentDV: 83),
                choline: nil
            ),
            minerals: MineralContent(
                calcium: NutrientAmount(amount: 500, unit: "mg", percentDV: 38),
                iron: NutrientAmount(amount: 18, unit: "mg", percentDV: 100),
                magnesium: NutrientAmount(amount: 100, unit: "mg", percentDV: 24),
                phosphorus: NutrientAmount(amount: 125, unit: "mg", percentDV: 10),
                potassium: NutrientAmount(amount: 80, unit: "mg", percentDV: 2),
                sodium: nil,
                zinc: NutrientAmount(amount: 8, unit: "mg", percentDV: 73),
                copper: NutrientAmount(amount: 0.9, unit: "mg", percentDV: 100),
                manganese: NutrientAmount(amount: 1.8, unit: "mg", percentDV: 78),
                selenium: NutrientAmount(amount: 55, unit: "mcg", percentDV: 100),
                chromium: NutrientAmount(amount: 35, unit: "mcg", percentDV: 100),
                molybdenum: NutrientAmount(amount: 45, unit: "mcg", percentDV: 100),
                iodine: NutrientAmount(amount: 150, unit: "mcg", percentDV: 100),
                chloride: nil
            ),
            otherIngredients: [],
            targetGender: .female,
            ageGroup: .adult,
            price: 19.99,
            countryAvailability: ["Canada", "USA"],
            warnings: ["Keep out of reach of children", "Do not exceed recommended dose"],
            benefits: ["Energy support", "Immune health", "Bone health", "Skin health"],
            dosageInstructions: "Take 1 tablet daily with food",
            imageUrl: nil
        ),

        Supplement(
            id: "prenatal-materna",
            brand: "Materna",
            name: "Materna Prenatal Multivitamin",
            category: .prenatal,
            servingSize: "1 tablet",
            servingsPerContainer: 100,
            barcode: "064541300054",
            dpn: "02245788",
            upc: "064541300054",
            vitamins: VitaminContent(
                vitaminA: NutrientAmount(amount: 1000, unit: "mcg", percentDV: 111),
                vitaminD: NutrientAmount(amount: 15, unit: "mcg", percentDV: 75),
                vitaminE: NutrientAmount(amount: 16.7, unit: "mg", percentDV: 111),
                vitaminK: NutrientAmount(amount: 90, unit: "mcg", percentDV: 75),
                vitaminB1_thiamine: NutrientAmount(amount: 3, unit: "mg", percentDV: 250),
                vitaminB2_riboflavin: NutrientAmount(amount: 3.4, unit: "mg", percentDV: 262),
                vitaminB3_niacin: NutrientAmount(amount: 20, unit: "mg", percentDV: 125),
                vitaminB5_pantothenicAcid: NutrientAmount(amount: 10, unit: "mg", percentDV: 200),
                vitaminB6: NutrientAmount(amount: 10, unit: "mg", percentDV: 588),
                vitaminB7_biotin: NutrientAmount(amount: 30, unit: "mcg", percentDV: 100),
                vitaminB9_folate: NutrientAmount(amount: 1000, unit: "mcg", percentDV: 250),
                vitaminB12: NutrientAmount(amount: 2.6, unit: "mcg", percentDV: 108),
                vitaminC: NutrientAmount(amount: 85, unit: "mg", percentDV: 94),
                choline: nil
            ),
            minerals: MineralContent(
                calcium: NutrientAmount(amount: 250, unit: "mg", percentDV: 19),
                iron: NutrientAmount(amount: 27, unit: "mg", percentDV: 150),
                magnesium: NutrientAmount(amount: 50, unit: "mg", percentDV: 12),
                phosphorus: nil,
                potassium: nil,
                sodium: nil,
                zinc: NutrientAmount(amount: 11, unit: "mg", percentDV: 100),
                copper: NutrientAmount(amount: 1, unit: "mg", percentDV: 111),
                manganese: NutrientAmount(amount: 2, unit: "mg", percentDV: 87),
                selenium: NutrientAmount(amount: 60, unit: "mcg", percentDV: 109),
                chromium: NutrientAmount(amount: 30, unit: "mcg", percentDV: 86),
                molybdenum: NutrientAmount(amount: 50, unit: "mcg", percentDV: 111),
                iodine: NutrientAmount(amount: 220, unit: "mcg", percentDV: 147),
                chloride: nil
            ),
            otherIngredients: [
                OtherIngredient(name: "DHA", amount: NutrientAmount(amount: 200, unit: "mg", percentDV: nil), category: "Omega-3")
            ],
            targetGender: .female,
            ageGroup: .adult,
            price: 29.99,
            countryAvailability: ["Canada"],
            warnings: ["Keep out of reach of children", "Consult healthcare provider if pregnant"],
            benefits: ["Fetal development", "Maternal health", "Neural tube defect prevention"],
            dosageInstructions: "Take 1 tablet daily with food",
            imageUrl: nil
        )
    ]

    // MARK: - Popular Individual Supplements

    let popularSupplements = [
        Supplement(
            id: "vitamin-d3-jamison",
            brand: "Jamieson",
            name: "Vitamin D3 1000 IU",
            category: .vitamin,
            servingSize: "1 tablet",
            servingsPerContainer: 375,
            barcode: "064642078315",
            dpn: "80003243",
            upc: "064642078315",
            vitamins: VitaminContent(
                vitaminA: nil,
                vitaminD: NutrientAmount(amount: 25, unit: "mcg", percentDV: 125),
                vitaminE: nil,
                vitaminK: nil,
                vitaminB1_thiamine: nil,
                vitaminB2_riboflavin: nil,
                vitaminB3_niacin: nil,
                vitaminB5_pantothenicAcid: nil,
                vitaminB6: nil,
                vitaminB7_biotin: nil,
                vitaminB9_folate: nil,
                vitaminB12: nil,
                vitaminC: nil,
                choline: nil
            ),
            minerals: MineralContent(
                calcium: nil,
                iron: nil,
                magnesium: nil,
                phosphorus: nil,
                potassium: nil,
                sodium: nil,
                zinc: nil,
                copper: nil,
                manganese: nil,
                selenium: nil,
                chromium: nil,
                molybdenum: nil,
                iodine: nil,
                chloride: nil
            ),
            otherIngredients: [],
            targetGender: .unisex,
            ageGroup: .all,
            price: 11.99,
            countryAvailability: ["Canada"],
            warnings: ["Keep out of reach of children"],
            benefits: ["Bone health", "Immune support", "Mood support", "Calcium absorption"],
            dosageInstructions: "Take 1 tablet daily",
            imageUrl: nil
        ),

        Supplement(
            id: "omega3-nordic-naturals",
            brand: "Nordic Naturals",
            name: "Ultimate Omega",
            category: .omega,
            servingSize: "2 soft gels",
            servingsPerContainer: 60,
            barcode: "768990017803",
            dpn: nil,
            upc: "768990017803",
            vitamins: VitaminContent(
                vitaminA: nil,
                vitaminD: nil,
                vitaminE: nil,
                vitaminK: nil,
                vitaminB1_thiamine: nil,
                vitaminB2_riboflavin: nil,
                vitaminB3_niacin: nil,
                vitaminB5_pantothenicAcid: nil,
                vitaminB6: nil,
                vitaminB7_biotin: nil,
                vitaminB9_folate: nil,
                vitaminB12: nil,
                vitaminC: nil,
                choline: nil
            ),
            minerals: MineralContent(
                calcium: nil,
                iron: nil,
                magnesium: nil,
                phosphorus: nil,
                potassium: nil,
                sodium: nil,
                zinc: nil,
                copper: nil,
                manganese: nil,
                selenium: nil,
                chromium: nil,
                molybdenum: nil,
                iodine: nil,
                chloride: nil
            ),
            otherIngredients: [
                OtherIngredient(name: "EPA", amount: NutrientAmount(amount: 650, unit: "mg", percentDV: nil), category: "Omega-3"),
                OtherIngredient(name: "DHA", amount: NutrientAmount(amount: 450, unit: "mg", percentDV: nil), category: "Omega-3"),
                OtherIngredient(name: "Other Omega-3s", amount: NutrientAmount(amount: 180, unit: "mg", percentDV: nil), category: "Omega-3")
            ],
            targetGender: .unisex,
            ageGroup: .all,
            price: 39.99,
            countryAvailability: ["Canada", "USA"],
            warnings: ["Consult healthcare provider if on blood thinners"],
            benefits: ["Heart health", "Brain function", "Joint health", "Eye health"],
            dosageInstructions: "Take 2 soft gels daily with food",
            imageUrl: nil
        ),

        Supplement(
            id: "magnesium-bisglycinate",
            brand: "Lorna Vanderhaeghe",
            name: "MAGsmart Magnesium Bisglycinate",
            category: .mineral,
            servingSize: "1 scoop (3.3g)",
            servingsPerContainer: 60,
            barcode: "871776000842",
            dpn: nil,
            upc: "871776000842",
            vitamins: VitaminContent(
                vitaminA: nil,
                vitaminD: nil,
                vitaminE: nil,
                vitaminK: nil,
                vitaminB1_thiamine: nil,
                vitaminB2_riboflavin: nil,
                vitaminB3_niacin: nil,
                vitaminB5_pantothenicAcid: nil,
                vitaminB6: nil,
                vitaminB7_biotin: nil,
                vitaminB9_folate: nil,
                vitaminB12: nil,
                vitaminC: nil,
                choline: nil
            ),
            minerals: MineralContent(
                calcium: nil,
                iron: nil,
                magnesium: NutrientAmount(amount: 200, unit: "mg", percentDV: 48),
                phosphorus: nil,
                potassium: nil,
                sodium: nil,
                zinc: nil,
                copper: nil,
                manganese: nil,
                selenium: nil,
                chromium: nil,
                molybdenum: nil,
                iodine: nil,
                chloride: nil
            ),
            otherIngredients: [
                OtherIngredient(name: "Taurine", amount: NutrientAmount(amount: 177, unit: "mg", percentDV: nil), category: "Amino Acid"),
                OtherIngredient(name: "L-Glutamine", amount: NutrientAmount(amount: 33, unit: "mg", percentDV: nil), category: "Amino Acid"),
                OtherIngredient(name: "Inulin", amount: NutrientAmount(amount: 270, unit: "mg", percentDV: nil), category: "Prebiotic")
            ],
            targetGender: .unisex,
            ageGroup: .adult,
            price: 34.99,
            countryAvailability: ["Canada"],
            warnings: ["May cause loose stools if taken in excess"],
            benefits: ["Muscle relaxation", "Better sleep", "Stress reduction", "Heart health"],
            dosageInstructions: "Mix 1 scoop in water or juice once daily",
            imageUrl: nil
        ),

        // USER'S PERSONAL SUPPLEMENTS

        Supplement(
            id: "one-a-day-womens-personal",
            brand: "One A Day",
            name: "Women's Multivitamin",
            category: .multivitamin,
            servingSize: "1 tablet",
            servingsPerContainer: 100,
            barcode: "016500535669",
            dpn: nil,
            upc: "016500535669",
            vitamins: VitaminContent(
                vitaminA: NutrientAmount(amount: 700, unit: "mcg", percentDV: 78),
                vitaminD: NutrientAmount(amount: 25, unit: "mcg", percentDV: 125),
                vitaminE: NutrientAmount(amount: 15, unit: "mg", percentDV: 100),
                vitaminK: nil,
                vitaminB1_thiamine: NutrientAmount(amount: 2.4, unit: "mg", percentDV: 200),
                vitaminB2_riboflavin: NutrientAmount(amount: 1.95, unit: "mg", percentDV: 150),
                vitaminB3_niacin: NutrientAmount(amount: 24, unit: "mg", percentDV: 150),
                vitaminB5_pantothenicAcid: NutrientAmount(amount: 7.5, unit: "mg", percentDV: 150),
                vitaminB6: NutrientAmount(amount: 3.4, unit: "mg", percentDV: 200),
                vitaminB7_biotin: NutrientAmount(amount: 45, unit: "mcg", percentDV: 150),
                vitaminB9_folate: NutrientAmount(amount: 665, unit: "mcg", percentDV: 166),
                vitaminB12: NutrientAmount(amount: 9.6, unit: "mcg", percentDV: 400),
                vitaminC: NutrientAmount(amount: 90, unit: "mg", percentDV: 100),
                choline: nil
            ),
            minerals: MineralContent(
                calcium: NutrientAmount(amount: 130, unit: "mg", percentDV: 10),
                iron: NutrientAmount(amount: 18, unit: "mg", percentDV: 100),
                magnesium: NutrientAmount(amount: 42, unit: "mg", percentDV: 10),
                phosphorus: nil,
                potassium: nil,
                sodium: nil,
                zinc: NutrientAmount(amount: 8, unit: "mg", percentDV: 73),
                copper: NutrientAmount(amount: 1.35, unit: "mg", percentDV: 150),
                manganese: nil,
                selenium: NutrientAmount(amount: 41, unit: "mcg", percentDV: 75),
                chromium: nil,
                molybdenum: nil,
                iodine: NutrientAmount(amount: 150, unit: "mcg", percentDV: 100),
                chloride: nil
            ),
            otherIngredients: [],
            targetGender: .female,
            ageGroup: .adult,
            price: nil,
            countryAvailability: ["Canada", "USA"],
            warnings: ["Keep out of reach of children"],
            benefits: ["Complete nutritional support", "Energy metabolism", "Immune health"],
            dosageInstructions: "Take 1 tablet daily with food",
            imageUrl: nil
        ),

        Supplement(
            id: "wild-fish-oil-personal",
            brand: "Generic",
            name: "Wild Fish Oil Blend",
            category: .omega,
            servingSize: "2 tablets",
            servingsPerContainer: 60,
            barcode: nil,
            dpn: nil,
            upc: nil,
            vitamins: VitaminContent(
                vitaminA: nil,
                vitaminD: nil,
                vitaminE: nil,
                vitaminK: nil,
                vitaminB1_thiamine: nil,
                vitaminB2_riboflavin: nil,
                vitaminB3_niacin: nil,
                vitaminB5_pantothenicAcid: nil,
                vitaminB6: nil,
                vitaminB7_biotin: nil,
                vitaminB9_folate: nil,
                vitaminB12: nil,
                vitaminC: nil,
                choline: nil
            ),
            minerals: MineralContent(
                calcium: nil,
                iron: nil,
                magnesium: nil,
                phosphorus: nil,
                potassium: nil,
                sodium: nil,
                zinc: nil,
                copper: nil,
                manganese: nil,
                selenium: nil,
                chromium: nil,
                molybdenum: nil,
                iodine: nil,
                chloride: nil
            ),
            otherIngredients: [
                OtherIngredient(name: "Total Omega-3", amount: NutrientAmount(amount: 2600, unit: "mg", percentDV: nil), category: "Omega-3"),
                OtherIngredient(name: "EPA", amount: NutrientAmount(amount: 900, unit: "mg", percentDV: nil), category: "Omega-3"),
                OtherIngredient(name: "DHA", amount: NutrientAmount(amount: 600, unit: "mg", percentDV: nil), category: "Omega-3")
            ],
            targetGender: .unisex,
            ageGroup: .adult,
            price: nil,
            countryAvailability: ["Canada", "USA"],
            warnings: [],
            benefits: ["Heart health", "Brain health", "Joint support"],
            dosageInstructions: "Take 2 tablets daily (part of 4 tablet regimen)",
            imageUrl: nil
        ),

        Supplement(
            id: "enhanced-fish-oil-personal",
            brand: "Generic",
            name: "Enhanced Fish Oil with Plant Sterols",
            category: .omega,
            servingSize: "3 softgels",
            servingsPerContainer: 30,
            barcode: nil,
            dpn: nil,
            upc: nil,
            vitamins: VitaminContent(
                vitaminA: nil,
                vitaminD: nil,
                vitaminE: nil,
                vitaminK: nil,
                vitaminB1_thiamine: nil,
                vitaminB2_riboflavin: nil,
                vitaminB3_niacin: nil,
                vitaminB5_pantothenicAcid: nil,
                vitaminB6: nil,
                vitaminB7_biotin: nil,
                vitaminB9_folate: nil,
                vitaminB12: nil,
                vitaminC: nil,
                choline: nil
            ),
            minerals: MineralContent(
                calcium: nil,
                iron: nil,
                magnesium: nil,
                phosphorus: nil,
                potassium: nil,
                sodium: nil,
                zinc: nil,
                copper: nil,
                manganese: nil,
                selenium: nil,
                chromium: nil,
                molybdenum: nil,
                iodine: nil,
                chloride: nil
            ),
            otherIngredients: [
                OtherIngredient(name: "Fish Oil Concentrate", amount: NutrientAmount(amount: 1251, unit: "mg", percentDV: nil), category: "Omega-3"),
                OtherIngredient(name: "Total Omega-3", amount: NutrientAmount(amount: 675, unit: "mg", percentDV: nil), category: "Omega-3"),
                OtherIngredient(name: "EPA", amount: NutrientAmount(amount: 450, unit: "mg", percentDV: nil), category: "Omega-3"),
                OtherIngredient(name: "DHA", amount: NutrientAmount(amount: 225, unit: "mg", percentDV: nil), category: "Omega-3"),
                OtherIngredient(name: "Plant Sterols", amount: NutrientAmount(amount: 1110, unit: "mg", percentDV: nil), category: "Phytosterol"),
                OtherIngredient(name: "Coenzyme Q10", amount: NutrientAmount(amount: 150, unit: "mg", percentDV: nil), category: "Antioxidant")
            ],
            targetGender: .unisex,
            ageGroup: .adult,
            price: nil,
            countryAvailability: ["Canada", "USA"],
            warnings: [],
            benefits: ["Cholesterol support", "Heart health", "Antioxidant support"],
            dosageInstructions: "Take 3 softgels daily with food",
            imageUrl: nil
        ),

        Supplement(
            id: "collagen-peptides-personal",
            brand: "Generic",
            name: "Collagen Peptides",
            category: .protein,
            servingSize: "2 scoops (10g)",
            servingsPerContainer: 30,
            barcode: nil,
            dpn: nil,
            upc: nil,
            vitamins: VitaminContent(
                vitaminA: nil,
                vitaminD: nil,
                vitaminE: nil,
                vitaminK: nil,
                vitaminB1_thiamine: nil,
                vitaminB2_riboflavin: nil,
                vitaminB3_niacin: nil,
                vitaminB5_pantothenicAcid: nil,
                vitaminB6: nil,
                vitaminB7_biotin: nil,
                vitaminB9_folate: nil,
                vitaminB12: nil,
                vitaminC: nil,
                choline: nil
            ),
            minerals: MineralContent(
                calcium: nil,
                iron: nil,
                magnesium: nil,
                phosphorus: nil,
                potassium: nil,
                sodium: NutrientAmount(amount: 35, unit: "mg", percentDV: 2),
                zinc: nil,
                copper: nil,
                manganese: nil,
                selenium: nil,
                chromium: nil,
                molybdenum: nil,
                iodine: nil,
                chloride: nil
            ),
            otherIngredients: [
                OtherIngredient(name: "Protein", amount: NutrientAmount(amount: 9, unit: "g", percentDV: nil), category: "Macronutrient"),
                OtherIngredient(name: "Calories", amount: NutrientAmount(amount: 35, unit: "kcal", percentDV: nil), category: "Energy")
            ],
            targetGender: .unisex,
            ageGroup: .adult,
            price: nil,
            countryAvailability: ["Canada", "USA"],
            warnings: [],
            benefits: ["Joint health", "Skin health", "Hair and nail support"],
            dosageInstructions: "Mix 2 scoops (10g) in water or beverage of choice",
            imageUrl: nil
        ),

        Supplement(
            id: "enhanced-collagen-personal",
            brand: "Generic",
            name: "Enhanced Collagen Protein",
            category: .protein,
            servingSize: "26g",
            servingsPerContainer: 30,
            barcode: nil,
            dpn: nil,
            upc: nil,
            vitamins: VitaminContent(
                vitaminA: nil,
                vitaminD: nil,
                vitaminE: nil,
                vitaminK: nil,
                vitaminB1_thiamine: nil,
                vitaminB2_riboflavin: nil,
                vitaminB3_niacin: nil,
                vitaminB5_pantothenicAcid: nil,
                vitaminB6: nil,
                vitaminB7_biotin: nil,
                vitaminB9_folate: nil,
                vitaminB12: nil,
                vitaminC: NutrientAmount(amount: 110, unit: "mg", percentDV: 122),
                choline: nil
            ),
            minerals: MineralContent(
                calcium: NutrientAmount(amount: 75, unit: "mg", percentDV: 6),
                iron: NutrientAmount(amount: 0.1, unit: "mg", percentDV: 1),
                magnesium: NutrientAmount(amount: 60, unit: "mg", percentDV: 14),
                phosphorus: NutrientAmount(amount: 350, unit: "mg", percentDV: 28),
                potassium: NutrientAmount(amount: 150, unit: "mg", percentDV: 4),
                sodium: NutrientAmount(amount: 110, unit: "mg", percentDV: 5),
                zinc: nil,
                copper: nil,
                manganese: nil,
                selenium: nil,
                chromium: nil,
                molybdenum: nil,
                iodine: nil,
                chloride: nil
            ),
            otherIngredients: [
                OtherIngredient(name: "Protein", amount: NutrientAmount(amount: 20, unit: "g", percentDV: nil), category: "Macronutrient"),
                OtherIngredient(name: "Calories", amount: NutrientAmount(amount: 80, unit: "kcal", percentDV: nil), category: "Energy"),
                OtherIngredient(name: "Probiotic Blend", amount: nil, category: "Probiotic")
            ],
            targetGender: .unisex,
            ageGroup: .adult,
            price: nil,
            countryAvailability: ["Canada", "USA"],
            warnings: [],
            benefits: ["Muscle recovery", "Gut health", "Immune support"],
            dosageInstructions: "Mix 26g in water or smoothie",
            imageUrl: nil
        ),

        Supplement(
            id: "magnesium-citrate-personal",
            brand: "Generic",
            name: "Magnesium Citrate",
            category: .mineral,
            servingSize: "2 teaspoons (5g)",
            servingsPerContainer: 30,
            barcode: nil,
            dpn: nil,
            upc: nil,
            vitamins: VitaminContent(
                vitaminA: nil,
                vitaminD: nil,
                vitaminE: nil,
                vitaminK: nil,
                vitaminB1_thiamine: nil,
                vitaminB2_riboflavin: nil,
                vitaminB3_niacin: nil,
                vitaminB5_pantothenicAcid: nil,
                vitaminB6: nil,
                vitaminB7_biotin: nil,
                vitaminB9_folate: nil,
                vitaminB12: nil,
                vitaminC: nil,
                choline: nil
            ),
            minerals: MineralContent(
                calcium: nil,
                iron: nil,
                magnesium: NutrientAmount(amount: 410, unit: "mg", percentDV: 98),
                phosphorus: nil,
                potassium: nil,
                sodium: nil,
                zinc: nil,
                copper: nil,
                manganese: nil,
                selenium: nil,
                chromium: nil,
                molybdenum: nil,
                iodine: nil,
                chloride: nil
            ),
            otherIngredients: [],
            targetGender: .unisex,
            ageGroup: .adult,
            price: nil,
            countryAvailability: ["Canada", "USA"],
            warnings: [],
            benefits: ["Muscle relaxation", "Sleep support", "Nervous system health"],
            dosageInstructions: "Mix 2 teaspoons (5g) in water once daily",
            imageUrl: nil
        ),

        Supplement(
            id: "superbelly-probiotic",
            brand: "SuperBelly",
            name: "Strawberry Hibiscus Probiotic",
            category: .probiotic,
            servingSize: "1 packet (4g)",
            servingsPerContainer: 30,
            barcode: nil,
            dpn: nil,
            upc: nil,
            vitamins: VitaminContent(
                vitaminA: nil,
                vitaminD: nil,
                vitaminE: nil,
                vitaminK: nil,
                vitaminB1_thiamine: nil,
                vitaminB2_riboflavin: nil,
                vitaminB3_niacin: nil,
                vitaminB5_pantothenicAcid: nil,
                vitaminB6: nil,
                vitaminB7_biotin: nil,
                vitaminB9_folate: nil,
                vitaminB12: nil,
                vitaminC: NutrientAmount(amount: 9, unit: "mg", percentDV: 10),
                choline: nil
            ),
            minerals: MineralContent(
                calcium: nil,
                iron: nil,
                magnesium: nil,
                phosphorus: nil,
                potassium: nil,
                sodium: NutrientAmount(amount: 65, unit: "mg", percentDV: 3),
                zinc: nil,
                copper: nil,
                manganese: nil,
                selenium: nil,
                chromium: nil,
                molybdenum: nil,
                iodine: nil,
                chloride: nil
            ),
            otherIngredients: [
                OtherIngredient(name: "Calories", amount: NutrientAmount(amount: 10, unit: "kcal", percentDV: nil), category: "Energy"),
                OtherIngredient(name: "Bacillus coagulans GBI-30 6086", amount: NutrientAmount(amount: 1, unit: "billion CFU", percentDV: nil), category: "Probiotic"),
                OtherIngredient(name: "Inulin (prebiotic)", amount: NutrientAmount(amount: 1, unit: "g", percentDV: nil), category: "Prebiotic"),
                OtherIngredient(name: "Apple Cider Vinegar Powder", amount: nil, category: "Digestive")
            ],
            targetGender: .unisex,
            ageGroup: .adult,
            price: nil,
            countryAvailability: ["Canada", "USA"],
            warnings: [],
            benefits: ["Digestive health", "Gut microbiome support", "Immune function"],
            dosageInstructions: "Mix 1 packet in water once daily",
            imageUrl: nil
        ),

        Supplement(
            id: "estrosmart",
            brand: "Smart Solutions",
            name: "EstroSmart",
            category: .herbal,
            servingSize: "2 capsules",
            servingsPerContainer: 30,
            barcode: nil,
            dpn: nil,
            upc: nil,
            vitamins: VitaminContent(
                vitaminA: nil,
                vitaminD: nil,
                vitaminE: nil,
                vitaminK: nil,
                vitaminB1_thiamine: nil,
                vitaminB2_riboflavin: nil,
                vitaminB3_niacin: nil,
                vitaminB5_pantothenicAcid: nil,
                vitaminB6: nil,
                vitaminB7_biotin: nil,
                vitaminB9_folate: nil,
                vitaminB12: nil,
                vitaminC: nil,
                choline: nil
            ),
            minerals: MineralContent(
                calcium: nil,
                iron: nil,
                magnesium: nil,
                phosphorus: nil,
                potassium: nil,
                sodium: nil,
                zinc: nil,
                copper: nil,
                manganese: nil,
                selenium: nil,
                chromium: nil,
                molybdenum: nil,
                iodine: nil,
                chloride: nil
            ),
            otherIngredients: [
                OtherIngredient(name: "Calcium D-glucarate", amount: NutrientAmount(amount: 150, unit: "mg", percentDV: nil), category: "Herbal"),
                OtherIngredient(name: "Indole-3-carbinol", amount: NutrientAmount(amount: 150, unit: "mg", percentDV: nil), category: "Herbal"),
                OtherIngredient(name: "Green Tea Extract", amount: NutrientAmount(amount: 100, unit: "mg", percentDV: nil), category: "Herbal"),
                OtherIngredient(name: "Turmeric Extract", amount: NutrientAmount(amount: 50, unit: "mg", percentDV: nil), category: "Herbal"),
                OtherIngredient(name: "DIM (Diindolylmethane)", amount: NutrientAmount(amount: 50, unit: "mg", percentDV: nil), category: "Herbal"),
                OtherIngredient(name: "Rosemary Extract", amount: NutrientAmount(amount: 25, unit: "mg", percentDV: nil), category: "Herbal"),
                OtherIngredient(name: "Broccoli Extract", amount: NutrientAmount(amount: 50, unit: "mg", percentDV: nil), category: "Herbal")
            ],
            targetGender: .female,
            ageGroup: .adult,
            price: nil,
            countryAvailability: ["Canada"],
            warnings: ["Consult healthcare provider if pregnant or nursing"],
            benefits: ["Estrogen balance", "Hormone detoxification", "Breast health support"],
            dosageInstructions: "Take 2 capsules twice daily with food",
            imageUrl: nil
        )
    ]

    // MARK: - Search Functions

    func searchByBarcode(_ barcode: String) -> Supplement? {
        let allSupplements = mensMultivitamins + womensMultivitamins + popularSupplements
        return allSupplements.first { $0.barcode == barcode || $0.upc == barcode }
    }

    func searchByDPN(_ dpn: String) -> Supplement? {
        let allSupplements = mensMultivitamins + womensMultivitamins + popularSupplements
        return allSupplements.first { $0.dpn == dpn }
    }

    func searchByName(_ query: String) -> [Supplement] {
        let allSupplements = mensMultivitamins + womensMultivitamins + popularSupplements
        return allSupplements.filter { supplement in
            supplement.name.localizedCaseInsensitiveContains(query) ||
            supplement.brand.localizedCaseInsensitiveContains(query)
        }
    }

    func getSupplementsByCategory(_ category: SupplementCategory) -> [Supplement] {
        let allSupplements = mensMultivitamins + womensMultivitamins + popularSupplements
        return allSupplements.filter { $0.category == category }
    }

    func getSupplementsForGender(_ gender: SupplementGender, ageGroup: SupplementAgeGroup? = nil) -> [Supplement] {
        let allSupplements = mensMultivitamins + womensMultivitamins + popularSupplements
        return allSupplements.filter { supplement in
            (supplement.targetGender == gender || supplement.targetGender == .unisex) &&
            (ageGroup == nil || supplement.ageGroup == ageGroup || supplement.ageGroup == .all)
        }
    }
}