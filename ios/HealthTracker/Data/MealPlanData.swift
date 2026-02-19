import Foundation

// MARK: - Meal Plan Models
struct MealPlanType: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let benefits: [String]
    let restrictions: [String]
    let monthlyPlans: [WeeklyMealPlan]
}

struct WeeklyMealPlan: Identifiable, Codable {
    let id: String
    let weekNumber: Int
    let days: [DailyMealPlan]
}

struct DailyMealPlan: Identifiable, Codable {
    let id: String
    let dayName: String
    let breakfast: Meal
    let lunch: Meal
    let dinner: Meal
    let snacks: [Meal]
}

struct Meal: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    let fiber: Double
    let prepTime: Int // minutes
    let cookTime: Int // minutes
    let ingredients: [String]
    let instructions: [String]
    let tags: [String]
}

// MARK: - Meal Plan Data
class MealPlanData {
    static let shared = MealPlanData()

    private init() {}

    lazy var allMealPlans: [MealPlanType] = MealPlanLoader.shared.loadAllMealPlans()
}

// MARK: - Meal Plan Manager
class MealPlanManager: ObservableObject {
    @Published var selectedPlanType: MealPlanType?
    @Published var currentWeek: Int = 1
    @Published var favoriteMeals: Set<String> = []
    @Published var shoppingList: [String] = []

    private let mealData = MealPlanData.shared

    func selectPlan(_ planId: String) {
        selectedPlanType = mealData.allMealPlans.first { $0.id == planId }
    }

    func getCurrentWeekPlan() -> WeeklyMealPlan? {
        guard let plan = selectedPlanType,
              currentWeek > 0 && currentWeek <= plan.monthlyPlans.count else {
            return nil
        }
        return plan.monthlyPlans[currentWeek - 1]
    }

    func generateShoppingList(for week: WeeklyMealPlan) {
        shoppingList.removeAll()
        var ingredients: [String: Int] = [:]

        for day in week.days {
            addIngredientsToList(from: day.breakfast, to: &ingredients)
            addIngredientsToList(from: day.lunch, to: &ingredients)
            addIngredientsToList(from: day.dinner, to: &ingredients)
            for snack in day.snacks {
                addIngredientsToList(from: snack, to: &ingredients)
            }
        }

        shoppingList = ingredients.keys.sorted()
    }

    private func addIngredientsToList(from meal: Meal, to list: inout [String: Int]) {
        for ingredient in meal.ingredients {
            list[ingredient, default: 0] += 1
        }
    }

    func toggleFavorite(_ mealId: String) {
        if favoriteMeals.contains(mealId) {
            favoriteMeals.remove(mealId)
        } else {
            favoriteMeals.insert(mealId)
        }
    }
}
