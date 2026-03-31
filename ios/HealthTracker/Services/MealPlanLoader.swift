import Foundation

// MARK: - JSON Models for Decoding
struct MealPlanJSON: Codable {
    let dietType: String
    let displayName: String
    let description: String
    let benefits: [String]
    let restrictions: [String]
    let meals: [String: MealJSON]
    let weeks: [WeekJSON]
}

struct MealJSON: Codable {
    let name: String
    let description: String
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    let fiber: Double
    let prepTime: Int
    let cookTime: Int
    let ingredients: [String]
    let instructions: [String]
    let tags: [String]
}

struct WeekJSON: Codable {
    let weekNumber: Int
    let days: [DayScheduleJSON]
}

struct DayScheduleJSON: Codable {
    let day: String
    let breakfast: String
    let lunch: String
    let dinner: String
    let snack: String
}

// MARK: - Meal Plan Loader Service
class MealPlanLoader {
    static let shared = MealPlanLoader()

    private var cache: [String: MealPlanType] = [:]

    private let dietFiles: [(id: String, file: String)] = [
        ("mediterranean", "mediterranean"),
        ("keto", "keto"),
        ("high_protein", "high_protein"),
        ("balanced", "balanced"),
        ("low_carb", "low_carb"),
        ("paleo", "paleo"),
        ("whole30", "whole30"),
        ("vegan", "vegan")
    ]

    private init() {}

    // MARK: - Load All Meal Plans
    func loadAllMealPlans() -> [MealPlanType] {
        return dietFiles.compactMap { loadMealPlan(for: $0.id, file: $0.file) }
    }

    // MARK: - Load Single Meal Plan
    func loadMealPlan(for dietId: String, file: String? = nil) -> MealPlanType? {
        if let cached = cache[dietId] {
            return cached
        }

        let fileName = file ?? dietId
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json", subdirectory: "MealPlans"),
              let data = try? Data(contentsOf: url) else {
            // Fallback: try without subdirectory (flat bundle)
            guard let url = Bundle.main.url(forResource: fileName, withExtension: "json"),
                  let data = try? Data(contentsOf: url) else {
                return nil
            }
            return decodeMealPlan(from: data, dietId: dietId)
        }

        return decodeMealPlan(from: data, dietId: dietId)
    }

    private func decodeMealPlan(from data: Data, dietId: String) -> MealPlanType? {
        guard let json = try? JSONDecoder().decode(MealPlanJSON.self, from: data) else {
            return nil
        }

        let plan = convertToMealPlanType(from: json)
        cache[dietId] = plan
        return plan
    }

    // MARK: - Convert JSON to Model Structs
    func convertToMealPlanType(from json: MealPlanJSON) -> MealPlanType {
        let weeklyPlans = json.weeks.map { weekJSON -> WeeklyMealPlan in
            let days = weekJSON.days.map { dayJSON -> DailyMealPlan in
                let dayId = "\(json.dietType)-w\(weekJSON.weekNumber)-\(dayJSON.day.lowercased())"

                let breakfast = resolveMeal(id: dayJSON.breakfast, from: json.meals, prefix: json.dietType)
                let lunch = resolveMeal(id: dayJSON.lunch, from: json.meals, prefix: json.dietType)
                let dinner = resolveMeal(id: dayJSON.dinner, from: json.meals, prefix: json.dietType)
                let snack = resolveMeal(id: dayJSON.snack, from: json.meals, prefix: json.dietType)

                return DailyMealPlan(
                    id: dayId,
                    dayName: dayJSON.day,
                    breakfast: breakfast,
                    lunch: lunch,
                    dinner: dinner,
                    snacks: [snack]
                )
            }

            return WeeklyMealPlan(
                id: "\(json.dietType)-week-\(weekJSON.weekNumber)",
                weekNumber: weekJSON.weekNumber,
                days: days
            )
        }

        return MealPlanType(
            id: json.dietType,
            name: json.displayName,
            description: json.description,
            benefits: json.benefits,
            restrictions: json.restrictions,
            monthlyPlans: weeklyPlans
        )
    }

    private func resolveMeal(id: String, from catalog: [String: MealJSON], prefix: String) -> Meal {
        guard let mealJSON = catalog[id] else {
            // Fallback for missing meal references
            return Meal(
                id: id,
                name: "Meal",
                description: "",
                calories: 0,
                protein: 0,
                carbs: 0,
                fat: 0,
                fiber: 0,
                prepTime: 0,
                cookTime: 0,
                ingredients: [],
                instructions: [],
                tags: []
            )
        }

        return Meal(
            id: id,
            name: mealJSON.name,
            description: mealJSON.description,
            calories: mealJSON.calories,
            protein: mealJSON.protein,
            carbs: mealJSON.carbs,
            fat: mealJSON.fat,
            fiber: mealJSON.fiber,
            prepTime: mealJSON.prepTime,
            cookTime: mealJSON.cookTime,
            ingredients: mealJSON.ingredients,
            instructions: mealJSON.instructions,
            tags: mealJSON.tags
        )
    }
}
