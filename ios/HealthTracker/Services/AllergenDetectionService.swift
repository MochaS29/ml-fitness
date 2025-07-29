import Foundation
import CoreData

class AllergenDetectionService: ObservableObject {
    static let shared = AllergenDetectionService()
    
    @Published var detectedAllergens: [AllergenInfo] = []
    @Published var isScanning = false
    
    private init() {}
    
    // MARK: - Allergen Detection
    
    func checkFoodForAllergens(_ foodName: String, ingredients: [String]? = nil, userProfile: UserProfile) -> [AllergenInfo] {
        var allergens: [AllergenInfo] = []
        
        // Get user's allergies
        let userAllergies = userProfile.foodPreferences.allergies
        
        // Check food name and ingredients
        let searchTerms = [foodName.lowercased()] + (ingredients?.map { $0.lowercased() } ?? [])
        
        for allergyInfo in userAllergies {
            let allergy = allergyInfo.allergy
            let keywords = allergy.keywords
            
            for term in searchTerms {
                for keyword in keywords {
                    if term.contains(keyword) {
                        allergens.append(AllergenInfo(
                            allergen: allergy,
                            ingredientSource: term,
                            confidence: determineConfidence(term: term, keyword: keyword)
                        ))
                        break
                    }
                }
            }
        }
        
        return allergens
    }
    
    func checkFoodEntry(_ foodEntry: FoodEntry, userProfile: UserProfile) -> [AllergenInfo] {
        var searchTerms = [foodEntry.name?.lowercased() ?? ""]
        
        // Add brand info if available
        if let brand = foodEntry.brand {
            searchTerms.append(brand.lowercased())
        }
        
        // FoodEntry doesn't have notes property, so we skip this
        
        return checkFoodForAllergens(foodEntry.name ?? "", ingredients: nil, userProfile: userProfile)
    }
    
    func checkRecipe(_ recipe: Recipe, userProfile: UserProfile) -> [AllergenInfo] {
        var allergens: [AllergenInfo] = []
        let userAllergies = userProfile.foodPreferences.allergies
        
        for ingredient in recipe.ingredients {
            for allergyInfo in userAllergies {
                let allergy = allergyInfo.allergy
                let keywords = allergy.keywords
                
                let ingredientName = ingredient.name.lowercased()
                for keyword in keywords {
                    if ingredientName.contains(keyword) {
                        allergens.append(AllergenInfo(
                            allergen: allergy,
                            ingredientSource: ingredient.name,
                            confidence: .certain
                        ))
                        break
                    }
                }
            }
        }
        
        return allergens
    }
    
    // MARK: - Dietary Preference Checking
    
    func checkDietaryCompliance(_ foodName: String, ingredients: [String]? = nil, preferences: [DietaryPreference]) -> DietaryComplianceResult {
        var violations: [DietaryViolation] = []
        
        let searchTerms = [foodName.lowercased()] + (ingredients?.map { $0.lowercased() } ?? [])
        
        for preference in preferences {
            let violatingIngredients = getViolatingIngredients(searchTerms: searchTerms, preference: preference)
            if !violatingIngredients.isEmpty {
                violations.append(DietaryViolation(
                    preference: preference,
                    violatingIngredients: violatingIngredients
                ))
            }
        }
        
        return DietaryComplianceResult(
            isCompliant: violations.isEmpty,
            violations: violations
        )
    }
    
    private func getViolatingIngredients(searchTerms: [String], preference: DietaryPreference) -> [String] {
        var violations: [String] = []
        
        let restrictedKeywords: [String]
        
        switch preference {
        case .vegetarian:
            restrictedKeywords = ["meat", "beef", "pork", "chicken", "turkey", "lamb", "bacon", "ham", "sausage", "gelatin", "lard", "tallow"]
        case .vegan:
            restrictedKeywords = ["meat", "beef", "pork", "chicken", "turkey", "lamb", "bacon", "ham", "sausage", "gelatin", "lard", "tallow",
                                  "milk", "cheese", "butter", "cream", "yogurt", "egg", "honey", "whey", "casein"]
        case .pescatarian:
            restrictedKeywords = ["meat", "beef", "pork", "chicken", "turkey", "lamb", "bacon", "ham", "sausage"]
        case .kosher:
            restrictedKeywords = ["pork", "shellfish", "bacon", "ham", "lobster", "crab", "shrimp"]
        case .halal:
            restrictedKeywords = ["pork", "bacon", "ham", "alcohol", "wine", "beer"]
        case .lowCarb:
            restrictedKeywords = ["sugar", "bread", "pasta", "rice", "potato", "corn"]
        case .keto:
            restrictedKeywords = ["sugar", "bread", "pasta", "rice", "potato", "corn", "beans"]
        case .paleo:
            restrictedKeywords = ["grain", "wheat", "corn", "rice", "oats", "beans", "peanut", "dairy", "milk", "cheese"]
        default:
            restrictedKeywords = []
        }
        
        for term in searchTerms {
            for keyword in restrictedKeywords {
                if term.contains(keyword) {
                    violations.append(term)
                    break
                }
            }
        }
        
        return violations
    }
    
    private func determineConfidence(term: String, keyword: String) -> AllergenConfidence {
        if term == keyword || term.hasPrefix(keyword + " ") || term.hasSuffix(" " + keyword) {
            return .certain
        } else if term.contains("may contain") || term.contains("traces") {
            return .possible
        } else {
            return .likely
        }
    }
    
    // MARK: - Warning Generation
    
    func generateAllergenWarning(allergens: [AllergenInfo]) -> AllergenWarning? {
        guard !allergens.isEmpty else { return nil }
        
        let severeAllergens = allergens.filter { allergen in
            let userProfile = UserProfileManager().currentProfile
            let allergyInfo = userProfile?.foodPreferences.allergies.first { $0.allergy == allergen.allergen }
            return allergyInfo?.severity == .severe || allergyInfo?.severity == .lifeThreatening
        }
        
        let severity: WarningSeverity
        if !severeAllergens.isEmpty {
            severity = .severe
        } else if allergens.contains(where: { $0.confidence == .certain }) {
            severity = .moderate
        } else {
            severity = .mild
        }
        
        return AllergenWarning(
            allergens: allergens,
            severity: severity,
            message: generateWarningMessage(allergens: allergens, severity: severity)
        )
    }
    
    private func generateWarningMessage(allergens: [AllergenInfo], severity: WarningSeverity) -> String {
        let allergenNames = allergens.map { $0.allergen.rawValue }.joined(separator: ", ")
        
        switch severity {
        case .severe:
            return "⚠️ SEVERE ALLERGY WARNING: This food contains \(allergenNames). Do not consume!"
        case .moderate:
            return "⚠️ Allergy Warning: This food contains \(allergenNames)."
        case .mild:
            return "ℹ️ Note: This food may contain \(allergenNames)."
        }
    }
}

// MARK: - Supporting Types

struct DietaryComplianceResult {
    let isCompliant: Bool
    let violations: [DietaryViolation]
}

struct DietaryViolation {
    let preference: DietaryPreference
    let violatingIngredients: [String]
}

struct AllergenWarning {
    let allergens: [AllergenInfo]
    let severity: WarningSeverity
    let message: String
}

enum WarningSeverity {
    case mild
    case moderate
    case severe
    
    var color: String {
        switch self {
        case .mild: return "yellow"
        case .moderate: return "orange"
        case .severe: return "red"
        }
    }
}