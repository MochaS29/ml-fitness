import SwiftUI
import CoreData

class DiaryViewModel: ObservableObject {
    @Published var dailySummary = DailySummary()

    private let viewContext = PersistenceController.shared.container.viewContext

    // MARK: - Daily Summary

    /// Recalculates `dailySummary` from the current fetch results and UserDefaults goals.
    func updateDailySummary(
        foodEntries: FetchedResults<FoodEntry>,
        exerciseEntries: FetchedResults<ExerciseEntry>,
        selectedDate: Date
    ) {
        dailySummary.calories = foodEntries.reduce(0) { $0 + $1.calories }
        dailySummary.protein = foodEntries.reduce(0) { $0 + $1.protein }
        dailySummary.caloriesBurned = exerciseEntries.reduce(0) { $0 + $1.caloriesBurned }
        dailySummary.exerciseMinutes = Double(exerciseEntries.reduce(0) { $0 + Int($1.duration) })
        dailySummary.waterOunces = calculateWaterOunces(for: selectedDate)

        let defaults = UserDefaults.standard
        dailySummary.calorieGoal = Double(defaults.integer(forKey: "dailyCalorieGoal")) > 0
            ? Double(defaults.integer(forKey: "dailyCalorieGoal"))
            : Double(AppConstants.Defaults.dailyCalorieGoal)
        dailySummary.proteinGoal = Double(defaults.integer(forKey: "proteinGoal")) > 0
            ? Double(defaults.integer(forKey: "proteinGoal"))
            : 50
    }

    // MARK: - Water

    /// Fetches water entries for `date` and returns the total in ounces.
    func calculateWaterOunces(for date: Date) -> Double {
        let request: NSFetchRequest<WaterEntry> = WaterEntry.fetchRequest()
        request.predicate = .forDay(date)
        guard let entries = try? viewContext.fetch(request) else { return 0 }
        return entries.reduce(0) { sum, entry in
            let amount = entry.unit == "ml" ? entry.amount / 29.5735 : entry.amount
            return sum + amount
        }
    }

    // MARK: - Meal helpers

    func mealCalories(for mealType: MealType, in foodEntries: FetchedResults<FoodEntry>) -> Int {
        Int(foodEntries
            .filter { $0.mealType == mealType.rawValue }
            .reduce(0) { $0 + $1.calories })
    }

    func mealTypeDisplayName(_ mealType: MealType) -> String {
        switch mealType {
        case .breakfast: return "Breakfast"
        case .lunch:     return "Lunch"
        case .dinner:    return "Dinner"
        case .snack:     return "Snack"
        }
    }

    // MARK: - Exercise helpers

    func totalExerciseMinutes(from exerciseEntries: FetchedResults<ExerciseEntry>) -> Int {
        exerciseEntries.reduce(0) { $0 + Int($1.duration) }
    }

    // MARK: - Nutrition aggregates

    func totalCalories(from foodEntries: FetchedResults<FoodEntry>) -> Double {
        foodEntries.reduce(0) { $0 + $1.calories }
    }

    func totalProtein(from foodEntries: FetchedResults<FoodEntry>) -> Double {
        foodEntries.reduce(0) { $0 + $1.protein }
    }

    func totalCarbs(from foodEntries: FetchedResults<FoodEntry>) -> Double {
        foodEntries.reduce(0) { $0 + $1.carbs }
    }

    func totalFat(from foodEntries: FetchedResults<FoodEntry>) -> Double {
        foodEntries.reduce(0) { $0 + $1.fat }
    }

    func totalFiber(from foodEntries: FetchedResults<FoodEntry>) -> Double {
        foodEntries.reduce(0) { $0 + $1.fiber }
    }

    func totalSugar(from foodEntries: FetchedResults<FoodEntry>) -> Double {
        foodEntries.reduce(0) { $0 + $1.sugar }
    }

    func totalSodium(from foodEntries: FetchedResults<FoodEntry>) -> Double {
        foodEntries.reduce(0) { $0 + $1.sodium }
    }

    func supplementNutrients(from supplementEntries: FetchedResults<SupplementEntry>) -> [String: Double] {
        var totals: [String: Double] = [:]
        for entry in supplementEntries {
            if let nutrients = entry.nutrients {
                for (key, value) in nutrients {
                    totals[key, default: 0] += value
                }
            }
        }
        return totals
    }

    // MARK: - Share text

    func generateDiaryShareText(
        selectedDate: Date,
        foodEntries: FetchedResults<FoodEntry>,
        exerciseEntries: FetchedResults<ExerciseEntry>
    ) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        var lines: [String] = []
        lines.append("📊 MindLab Fitness — \(dateFormatter.string(from: selectedDate))")
        lines.append("")

        let goal = UserDefaults.standard.integer(forKey: "dailyCalorieGoal") > 0
            ? UserDefaults.standard.integer(forKey: "dailyCalorieGoal") : AppConstants.Defaults.dailyCalorieGoal
        let eaten = Int(totalCalories(from: foodEntries))
        let burned = Int(exerciseEntries.reduce(0) { $0 + $1.caloriesBurned })
        lines.append("🔥 Calories: \(eaten) eaten · \(burned) burned · \(max(0, goal + burned - eaten)) remaining")

        for mealType in MealType.allCases {
            let entries = foodEntries.filter { $0.mealType == mealType.rawValue }
            if !entries.isEmpty {
                lines.append("")
                lines.append("\(mealTypeDisplayName(mealType)):")
                for e in entries {
                    lines.append("  • \(e.name ?? "Unknown") — \(Int(e.calories)) cal")
                }
            }
        }

        if !exerciseEntries.isEmpty {
            lines.append("")
            lines.append("🏃 Exercise:")
            for e in exerciseEntries {
                lines.append("  • \(e.name ?? "Unknown") — \(e.duration) min · \(Int(e.caloriesBurned)) cal")
            }
        }

        lines.append("")
        lines.append("Macros: P \(String(format: "%.0f", totalProtein(from: foodEntries)))g · C \(String(format: "%.0f", totalCarbs(from: foodEntries)))g · F \(String(format: "%.0f", totalFat(from: foodEntries)))g")
        lines.append("")
        lines.append("Logged with MindLab Fitness")
        return lines.joined(separator: "\n")
    }
}
