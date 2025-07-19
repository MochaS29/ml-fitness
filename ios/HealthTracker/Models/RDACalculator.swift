import Foundation

enum NutrientStatus {
    case deficient(severity: DeficiencyLevel)
    case adequate
    case excessive(concern: ExcessConcern)
    case potentiallyHarmful
    
    var color: String {
        switch self {
        case .deficient(let severity):
            switch severity {
            case .mild: return "orange"
            case .moderate: return "red"
            case .severe: return "darkred"
            }
        case .adequate:
            return "green"
        case .excessive(let concern):
            switch concern {
            case .slightlyHigh: return "yellow"
            case .concerningLevel: return "orange"
            case .dangerous: return "red"
            }
        case .potentiallyHarmful:
            return "darkred"
        }
    }
    
    var symbol: String {
        switch self {
        case .deficient: return "⚠️"
        case .adequate: return "✅"
        case .excessive(let concern):
            switch concern {
            case .slightlyHigh: return "⬆️"
            case .concerningLevel, .dangerous: return "⚠️"
            }
        case .potentiallyHarmful: return "❌"
        }
    }
}

enum DeficiencyLevel {
    case mild    // 50-75% of RDA
    case moderate // 25-50% of RDA
    case severe  // <25% of RDA
}

enum ExcessConcern {
    case slightlyHigh    // 100-150% of RDA
    case concerningLevel // 150-200% of RDA or approaching UL
    case dangerous       // >200% of RDA or exceeds UL
}

struct NutrientIntake {
    let nutrientId: String
    let amount: Double
    let unit: NutrientUnit
}

struct NutrientAnalysis {
    let nutrientId: String
    let nutrientName: String
    let intake: Double
    let rda: RDAValue
    let percentageOfRDA: Double
    let status: NutrientStatus
    let recommendation: String?
}

class RDACalculator {
    private let database = RDADatabase.shared
    
    func analyzeIntake(_ intakes: [NutrientIntake], for profile: UserProfile) -> [NutrientAnalysis] {
        var analyses: [NutrientAnalysis] = []
        
        for intake in intakes {
            if let rda = database.getRDA(for: intake.nutrientId, profile: profile) {
                let analysis = analyzeNutrient(intake: intake, rda: rda, profile: profile)
                analyses.append(analysis)
            }
        }
        
        return analyses
    }
    
    private func analyzeNutrient(intake: NutrientIntake, rda: RDAValue, profile: UserProfile) -> NutrientAnalysis {
        let percentage = (intake.amount / rda.amount) * 100
        let status = determineStatus(percentage: percentage, intake: intake.amount, rda: rda)
        let recommendation = generateRecommendation(
            nutrientId: intake.nutrientId,
            status: status,
            profile: profile,
            percentage: percentage
        )
        
        return NutrientAnalysis(
            nutrientId: intake.nutrientId,
            nutrientName: getNutrientName(intake.nutrientId),
            intake: intake.amount,
            rda: rda,
            percentageOfRDA: percentage,
            status: status,
            recommendation: recommendation
        )
    }
    
    private func determineStatus(percentage: Double, intake: Double, rda: RDAValue) -> NutrientStatus {
        // Check upper limit first
        if let upperLimit = rda.upperLimit, intake >= upperLimit {
            return .potentiallyHarmful
        }
        
        switch percentage {
        case 0..<25:
            return .deficient(severity: .severe)
        case 25..<50:
            return .deficient(severity: .moderate)
        case 50..<75:
            return .deficient(severity: .mild)
        case 75..<125:
            return .adequate
        case 125..<150:
            return .excessive(concern: .slightlyHigh)
        case 150..<200:
            if let upperLimit = rda.upperLimit, intake > upperLimit * 0.8 {
                return .excessive(concern: .dangerous)
            }
            return .excessive(concern: .concerningLevel)
        default:
            return .excessive(concern: .dangerous)
        }
    }
    
    private func generateRecommendation(nutrientId: String, status: NutrientStatus, profile: UserProfile, percentage: Double) -> String? {
        switch (nutrientId, status, profile.gender) {
        // Iron-specific recommendations
        case ("iron", .excessive(let concern), .male) where concern != .slightlyHigh:
            return "High iron intake may be unnecessary for males and could cause oxidative stress. Consider reducing iron-rich supplements."
            
        case ("iron", .deficient, .female) where profile.age < 51:
            return "Pre-menopausal women have higher iron needs. Consider iron-rich foods like red meat, spinach, or fortified cereals."
            
        // Calcium-specific recommendations
        case ("calcium", .deficient, .female) where profile.age >= 51:
            return "Post-menopausal women need extra calcium (1200mg) for bone health. Consider dairy products or calcium supplements."
            
        // Folate-specific recommendations
        case ("folate", .deficient, .female) where profile.age >= 19 && profile.age <= 45:
            return "Women of childbearing age need adequate folate. Consider leafy greens or a folic acid supplement."
            
        // Vitamin D recommendations
        case ("vitamin_d", .deficient, _) where profile.age >= 71:
            return "Older adults need more vitamin D (800 IU). Consider supplements as skin synthesis decreases with age."
            
        // General recommendations
        case (_, .deficient(let severity), _):
            switch severity {
            case .severe:
                return "Severely low intake. Consult with a healthcare provider about supplementation."
            case .moderate:
                return "Moderately low intake. Increase food sources or consider a supplement."
            case .mild:
                return "Slightly below recommended levels. Try to include more food sources."
            }
            
        case (_, .excessive(let concern), _):
            switch concern {
            case .dangerous:
                return "Dangerously high intake. Reduce supplementation immediately and consult a healthcare provider."
            case .concerningLevel:
                return "Intake is quite high. Consider reducing supplements to avoid potential adverse effects."
            case .slightlyHigh:
                return nil // No recommendation for slightly high
            }
            
        case (_, .potentiallyHarmful, _):
            return "Exceeds safe upper limit. Stop supplementation and consult a healthcare provider immediately."
            
        default:
            return nil
        }
    }
    
    private func getNutrientName(_ nutrientId: String) -> String {
        // This would be expanded with all nutrients
        let names: [String: String] = [
            "vitamin_c": "Vitamin C",
            "iron": "Iron",
            "calcium": "Calcium",
            "vitamin_d": "Vitamin D",
            "folate": "Folate"
        ]
        return names[nutrientId] ?? nutrientId
    }
}