import Foundation
import CoreData

extension NutritionInfo {
    // Create NutritionInfo from supplement nutrients
    static func fromSupplements(_ supplements: [SupplementEntry]) -> NutritionInfo {
        var totalNutrition = NutritionInfo(calories: 0, protein: 0, carbs: 0, fat: 0)
        
        for supplement in supplements {
            guard let nutrients = supplement.nutrients else { continue }
            
            // Convert supplement nutrients to NutritionInfo values
            for (nutrientId, amount) in nutrients {
                switch nutrientId {
                // Vitamins
                case "vitamin_a":
                    totalNutrition.vitaminA = (totalNutrition.vitaminA ?? 0) + amount
                case "vitamin_c":
                    totalNutrition.vitaminC = (totalNutrition.vitaminC ?? 0) + amount
                case "vitamin_d":
                    totalNutrition.vitaminD = (totalNutrition.vitaminD ?? 0) + amount
                case "vitamin_e":
                    totalNutrition.vitaminE = (totalNutrition.vitaminE ?? 0) + amount
                case "vitamin_k":
                    totalNutrition.vitaminK = (totalNutrition.vitaminK ?? 0) + amount
                case "thiamin", "vitamin_b1":
                    totalNutrition.thiamin = (totalNutrition.thiamin ?? 0) + amount
                case "riboflavin", "vitamin_b2":
                    totalNutrition.riboflavin = (totalNutrition.riboflavin ?? 0) + amount
                case "niacin", "vitamin_b3":
                    totalNutrition.niacin = (totalNutrition.niacin ?? 0) + amount
                case "vitamin_b6":
                    totalNutrition.vitaminB6 = (totalNutrition.vitaminB6 ?? 0) + amount
                case "folate":
                    totalNutrition.folate = (totalNutrition.folate ?? 0) + amount
                case "vitamin_b12":
                    totalNutrition.vitaminB12 = (totalNutrition.vitaminB12 ?? 0) + amount
                case "biotin":
                    totalNutrition.biotin = (totalNutrition.biotin ?? 0) + amount
                case "pantothenic_acid", "vitamin_b5":
                    totalNutrition.pantothenicAcid = (totalNutrition.pantothenicAcid ?? 0) + amount
                    
                // Minerals
                case "calcium":
                    totalNutrition.calcium = (totalNutrition.calcium ?? 0) + amount
                case "iron":
                    totalNutrition.iron = (totalNutrition.iron ?? 0) + amount
                case "magnesium":
                    totalNutrition.magnesium = (totalNutrition.magnesium ?? 0) + amount
                case "phosphorus":
                    totalNutrition.phosphorus = (totalNutrition.phosphorus ?? 0) + amount
                case "potassium":
                    totalNutrition.potassium = (totalNutrition.potassium ?? 0) + amount
                case "sodium":
                    totalNutrition.sodium = (totalNutrition.sodium ?? 0) + amount
                case "zinc":
                    totalNutrition.zinc = (totalNutrition.zinc ?? 0) + amount
                case "copper":
                    totalNutrition.copper = (totalNutrition.copper ?? 0) + amount
                case "manganese":
                    totalNutrition.manganese = (totalNutrition.manganese ?? 0) + amount
                case "selenium":
                    totalNutrition.selenium = (totalNutrition.selenium ?? 0) + amount
                case "chromium":
                    totalNutrition.chromium = (totalNutrition.chromium ?? 0) + amount
                case "molybdenum":
                    totalNutrition.molybdenum = (totalNutrition.molybdenum ?? 0) + amount
                case "iodine":
                    totalNutrition.iodine = (totalNutrition.iodine ?? 0) + amount
                    
                // Special nutrients
                case "omega_3":
                    totalNutrition.omega3 = (totalNutrition.omega3 ?? 0) + amount
                case "omega_6":
                    totalNutrition.omega6 = (totalNutrition.omega6 ?? 0) + amount
                case "choline":
                    totalNutrition.choline = (totalNutrition.choline ?? 0) + amount
                    
                default:
                    // Skip unknown nutrients
                    break
                }
            }
        }
        
        return totalNutrition
    }
    
    // Combine food nutrition with supplement nutrition
    func combined(with supplementNutrition: NutritionInfo) -> NutritionInfo {
        return self + supplementNutrition
    }
}

// Helper function to get today's supplements
extension PersistenceController {
    func fetchTodaysSupplements(context: NSManagedObjectContext) -> [SupplementEntry] {
        let request: NSFetchRequest<SupplementEntry> = SupplementEntry.fetchRequest()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        request.predicate = NSPredicate(format: "timestamp >= %@", startOfDay as NSDate)
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching today's supplements: \(error)")
            return []
        }
    }
}