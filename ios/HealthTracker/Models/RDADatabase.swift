import Foundation

struct RDAValue: Codable {
    let amount: Double
    let unit: NutrientUnit
    let upperLimit: Double?
    let aiValue: Double? // Adequate Intake when RDA not established
    
    var displayValue: String {
        "\(Int(amount))\(unit.symbol)"
    }
}

enum NutrientUnit: String, Codable {
    case mg = "mg"
    case mcg = "mcg"
    case g = "g"
    case iu = "IU"
    
    var symbol: String {
        return self.rawValue
    }
}

struct NutrientRDA: Codable {
    let nutrientId: String
    let name: String
    let maleValues: [AgeGroup: RDAValue]
    let femaleValues: [AgeGroup: RDAValue]
    let pregnancyValues: [PregnancyTrimester: RDAValue]
    let breastfeedingValue: RDAValue?
}

class RDADatabase {
    static let shared = RDADatabase()
    
    private var nutrients: [String: NutrientRDA] = [:]
    
    init() {
        loadCompleteRDAData()
    }
    
    private func loadRDAData() {
        // Vitamin C
        nutrients["vitamin_c"] = NutrientRDA(
            nutrientId: "vitamin_c",
            name: "Vitamin C",
            maleValues: [
                .adult19to30: RDAValue(amount: 90, unit: .mg, upperLimit: 2000, aiValue: nil),
                .adult31to50: RDAValue(amount: 90, unit: .mg, upperLimit: 2000, aiValue: nil),
                .adult51to70: RDAValue(amount: 90, unit: .mg, upperLimit: 2000, aiValue: nil),
                .adult71plus: RDAValue(amount: 90, unit: .mg, upperLimit: 2000, aiValue: nil)
            ],
            femaleValues: [
                .adult19to30: RDAValue(amount: 75, unit: .mg, upperLimit: 2000, aiValue: nil),
                .adult31to50: RDAValue(amount: 75, unit: .mg, upperLimit: 2000, aiValue: nil),
                .adult51to70: RDAValue(amount: 75, unit: .mg, upperLimit: 2000, aiValue: nil),
                .adult71plus: RDAValue(amount: 75, unit: .mg, upperLimit: 2000, aiValue: nil)
            ],
            pregnancyValues: [
                .first: RDAValue(amount: 85, unit: .mg, upperLimit: 2000, aiValue: nil),
                .second: RDAValue(amount: 85, unit: .mg, upperLimit: 2000, aiValue: nil),
                .third: RDAValue(amount: 85, unit: .mg, upperLimit: 2000, aiValue: nil)
            ],
            breastfeedingValue: RDAValue(amount: 120, unit: .mg, upperLimit: 2000, aiValue: nil)
        )
        
        // Iron
        nutrients["iron"] = NutrientRDA(
            nutrientId: "iron",
            name: "Iron",
            maleValues: [
                .adult19to30: RDAValue(amount: 8, unit: .mg, upperLimit: 45, aiValue: nil),
                .adult31to50: RDAValue(amount: 8, unit: .mg, upperLimit: 45, aiValue: nil),
                .adult51to70: RDAValue(amount: 8, unit: .mg, upperLimit: 45, aiValue: nil),
                .adult71plus: RDAValue(amount: 8, unit: .mg, upperLimit: 45, aiValue: nil)
            ],
            femaleValues: [
                .adult19to30: RDAValue(amount: 18, unit: .mg, upperLimit: 45, aiValue: nil),
                .adult31to50: RDAValue(amount: 18, unit: .mg, upperLimit: 45, aiValue: nil),
                .adult51to70: RDAValue(amount: 8, unit: .mg, upperLimit: 45, aiValue: nil),
                .adult71plus: RDAValue(amount: 8, unit: .mg, upperLimit: 45, aiValue: nil)
            ],
            pregnancyValues: [
                .first: RDAValue(amount: 27, unit: .mg, upperLimit: 45, aiValue: nil),
                .second: RDAValue(amount: 27, unit: .mg, upperLimit: 45, aiValue: nil),
                .third: RDAValue(amount: 27, unit: .mg, upperLimit: 45, aiValue: nil)
            ],
            breastfeedingValue: RDAValue(amount: 9, unit: .mg, upperLimit: 45, aiValue: nil)
        )
        
        // Calcium
        nutrients["calcium"] = NutrientRDA(
            nutrientId: "calcium",
            name: "Calcium",
            maleValues: [
                .adult19to30: RDAValue(amount: 1000, unit: .mg, upperLimit: 2500, aiValue: nil),
                .adult31to50: RDAValue(amount: 1000, unit: .mg, upperLimit: 2500, aiValue: nil),
                .adult51to70: RDAValue(amount: 1000, unit: .mg, upperLimit: 2000, aiValue: nil),
                .adult71plus: RDAValue(amount: 1200, unit: .mg, upperLimit: 2000, aiValue: nil)
            ],
            femaleValues: [
                .adult19to30: RDAValue(amount: 1000, unit: .mg, upperLimit: 2500, aiValue: nil),
                .adult31to50: RDAValue(amount: 1000, unit: .mg, upperLimit: 2500, aiValue: nil),
                .adult51to70: RDAValue(amount: 1200, unit: .mg, upperLimit: 2000, aiValue: nil),
                .adult71plus: RDAValue(amount: 1200, unit: .mg, upperLimit: 2000, aiValue: nil)
            ],
            pregnancyValues: [
                .first: RDAValue(amount: 1000, unit: .mg, upperLimit: 2500, aiValue: nil),
                .second: RDAValue(amount: 1000, unit: .mg, upperLimit: 2500, aiValue: nil),
                .third: RDAValue(amount: 1000, unit: .mg, upperLimit: 2500, aiValue: nil)
            ],
            breastfeedingValue: RDAValue(amount: 1000, unit: .mg, upperLimit: 2500, aiValue: nil)
        )
        
        // Vitamin D
        nutrients["vitamin_d"] = NutrientRDA(
            nutrientId: "vitamin_d",
            name: "Vitamin D",
            maleValues: [
                .adult19to30: RDAValue(amount: 600, unit: .iu, upperLimit: 4000, aiValue: nil),
                .adult31to50: RDAValue(amount: 600, unit: .iu, upperLimit: 4000, aiValue: nil),
                .adult51to70: RDAValue(amount: 600, unit: .iu, upperLimit: 4000, aiValue: nil),
                .adult71plus: RDAValue(amount: 800, unit: .iu, upperLimit: 4000, aiValue: nil)
            ],
            femaleValues: [
                .adult19to30: RDAValue(amount: 600, unit: .iu, upperLimit: 4000, aiValue: nil),
                .adult31to50: RDAValue(amount: 600, unit: .iu, upperLimit: 4000, aiValue: nil),
                .adult51to70: RDAValue(amount: 600, unit: .iu, upperLimit: 4000, aiValue: nil),
                .adult71plus: RDAValue(amount: 800, unit: .iu, upperLimit: 4000, aiValue: nil)
            ],
            pregnancyValues: [
                .first: RDAValue(amount: 600, unit: .iu, upperLimit: 4000, aiValue: nil),
                .second: RDAValue(amount: 600, unit: .iu, upperLimit: 4000, aiValue: nil),
                .third: RDAValue(amount: 600, unit: .iu, upperLimit: 4000, aiValue: nil)
            ],
            breastfeedingValue: RDAValue(amount: 600, unit: .iu, upperLimit: 4000, aiValue: nil)
        )
        
        // Folate
        nutrients["folate"] = NutrientRDA(
            nutrientId: "folate",
            name: "Folate",
            maleValues: [
                .adult19to30: RDAValue(amount: 400, unit: .mcg, upperLimit: 1000, aiValue: nil),
                .adult31to50: RDAValue(amount: 400, unit: .mcg, upperLimit: 1000, aiValue: nil),
                .adult51to70: RDAValue(amount: 400, unit: .mcg, upperLimit: 1000, aiValue: nil),
                .adult71plus: RDAValue(amount: 400, unit: .mcg, upperLimit: 1000, aiValue: nil)
            ],
            femaleValues: [
                .adult19to30: RDAValue(amount: 400, unit: .mcg, upperLimit: 1000, aiValue: nil),
                .adult31to50: RDAValue(amount: 400, unit: .mcg, upperLimit: 1000, aiValue: nil),
                .adult51to70: RDAValue(amount: 400, unit: .mcg, upperLimit: 1000, aiValue: nil),
                .adult71plus: RDAValue(amount: 400, unit: .mcg, upperLimit: 1000, aiValue: nil)
            ],
            pregnancyValues: [
                .first: RDAValue(amount: 600, unit: .mcg, upperLimit: 1000, aiValue: nil),
                .second: RDAValue(amount: 600, unit: .mcg, upperLimit: 1000, aiValue: nil),
                .third: RDAValue(amount: 600, unit: .mcg, upperLimit: 1000, aiValue: nil)
            ],
            breastfeedingValue: RDAValue(amount: 500, unit: .mcg, upperLimit: 1000, aiValue: nil)
        )
        
        // Add more nutrients as needed...
    }
    
    func getRDA(for nutrientId: String, profile: UserProfile) -> RDAValue? {
        guard let nutrientRDA = nutrients[nutrientId] else { return nil }
        
        switch profile.lifeStage {
        case .pregnant(let trimester):
            return nutrientRDA.pregnancyValues[trimester]
        case .breastfeeding:
            return nutrientRDA.breastfeedingValue
        case .standard(let ageGroup):
            switch profile.gender {
            case .male:
                return nutrientRDA.maleValues[ageGroup]
            case .female:
                return nutrientRDA.femaleValues[ageGroup]
            case .other:
                // Use average of male/female or female values as default
                return nutrientRDA.femaleValues[ageGroup]
            }
        }
    }
    
    func getAllNutrients() -> [NutrientRDA] {
        return Array(nutrients.values)
    }
}