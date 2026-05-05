import SwiftUI
import CoreData

class DiaryViewModel: ObservableObject {
    @Published var dailySummary = DailySummary()

    private let viewContext = PersistenceController.shared.container.viewContext

    // MARK: - Daily Summary

    /// Recalculates `dailySummary` from the current fetch results and UserDefaults goals.
    /// Supplements that record macros (e.g. collagen, whey) contribute to calorie/protein totals.
    func updateDailySummary(
        foodEntries: FetchedResults<FoodEntry>,
        exerciseEntries: FetchedResults<ExerciseEntry>,
        supplementEntries: FetchedResults<SupplementEntry>,
        selectedDate: Date
    ) {
        let suppCalories = supplementEntries.reduce(0.0) { $0 + ($1.nutrients?["calories"] ?? 0) }
        let suppProtein  = supplementEntries.reduce(0.0) { $0 + ($1.nutrients?["protein"]  ?? 0) }

        dailySummary.calories = foodEntries.reduce(0) { $0 + $1.calories } + suppCalories
        dailySummary.protein = foodEntries.reduce(0) { $0 + $1.protein } + suppProtein
        dailySummary.caloriesBurned = exerciseEntries.reduce(0) { $0 + $1.caloriesBurned }
        dailySummary.exerciseMinutes = Double(exerciseEntries.reduce(0) { $0 + Int($1.duration) })
        dailySummary.waterOunces = calculateWaterOunces(for: selectedDate)

        let defaults = UserDefaults.standard
        dailySummary.calorieGoal = Double(defaults.integer(forKey: "dailyCalorieGoal")) > 0
            ? Double(defaults.integer(forKey: "dailyCalorieGoal"))
            : Double(AppConstants.Defaults.dailyCalorieGoal)
        dailySummary.proteinGoal = Double(defaults.integer(forKey: "proteinGoal")) > 0
            ? Double(defaults.integer(forKey: "proteinGoal"))
            : Double(AppConstants.Defaults.dailyProteinGrams)
    }

    /// Asks HealthKit for the day's active energy burned and uses it if it exceeds
    /// the manually-logged exercise total. Apple Watch/iPhone-tracked activity (steps,
    /// workouts) writes to `activeEnergyBurned`, so this surfaces real-world burn even
    /// when the user hasn't manually logged exercise.
    func refreshActiveEnergy(for date: Date) {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: date)
        guard let end = calendar.date(byAdding: .day, value: 1, to: start) else { return }
        HealthKitManager.shared.fetchActiveEnergy(from: start, to: end) { [weak self] kcal in
            guard let self = self else { return }
            if kcal > self.dailySummary.caloriesBurned {
                self.dailySummary.caloriesBurned = kcal
            }
        }
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
    // Each totalX(from:supplements:) sums the food column plus any matching key
    // from supplement.nutrients, so protein-style supplements (collagen, whey)
    // contribute to daily macros and fibre supplements contribute to fibre, etc.

    private func suppSum(_ supplements: FetchedResults<SupplementEntry>, key: String) -> Double {
        supplements.reduce(0.0) { $0 + ($1.nutrients?[key] ?? 0) }
    }

    func totalCalories(from foodEntries: FetchedResults<FoodEntry>, supplements: FetchedResults<SupplementEntry>) -> Double {
        foodEntries.reduce(0) { $0 + $1.calories } + suppSum(supplements, key: "calories")
    }

    func totalProtein(from foodEntries: FetchedResults<FoodEntry>, supplements: FetchedResults<SupplementEntry>) -> Double {
        foodEntries.reduce(0) { $0 + $1.protein } + suppSum(supplements, key: "protein")
    }

    func totalCarbs(from foodEntries: FetchedResults<FoodEntry>, supplements: FetchedResults<SupplementEntry>) -> Double {
        foodEntries.reduce(0) { $0 + $1.carbs } + suppSum(supplements, key: "carbs")
    }

    func totalFat(from foodEntries: FetchedResults<FoodEntry>, supplements: FetchedResults<SupplementEntry>) -> Double {
        foodEntries.reduce(0) { $0 + $1.fat } + suppSum(supplements, key: "fat")
    }

    func totalFiber(from foodEntries: FetchedResults<FoodEntry>, supplements: FetchedResults<SupplementEntry>) -> Double {
        foodEntries.reduce(0) { $0 + $1.fiber } + suppSum(supplements, key: "fiber")
    }

    func totalSugar(from foodEntries: FetchedResults<FoodEntry>, supplements: FetchedResults<SupplementEntry>) -> Double {
        foodEntries.reduce(0) { $0 + $1.sugar } + suppSum(supplements, key: "sugar")
    }

    func totalSodium(from foodEntries: FetchedResults<FoodEntry>, supplements: FetchedResults<SupplementEntry>) -> Double {
        foodEntries.reduce(0) { $0 + $1.sodium } + suppSum(supplements, key: "sodium")
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

    func foodAdditionalNutrients(from foodEntries: FetchedResults<FoodEntry>) -> [String: Double] {
        var totals: [String: Double] = [:]
        for entry in foodEntries {
            guard let extras = entry.additionalNutrients else { continue }
            for (key, value) in extras {
                totals[key, default: 0] += value
            }
        }
        return totals
    }

    // MARK: - Share text

    func generateDiaryShareText(
        selectedDate: Date,
        foodEntries: FetchedResults<FoodEntry>,
        exerciseEntries: FetchedResults<ExerciseEntry>,
        supplementEntries: FetchedResults<SupplementEntry>
    ) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        var lines: [String] = []
        lines.append("📊 MindLab Fitness — \(dateFormatter.string(from: selectedDate))")
        lines.append("")

        let goal = UserDefaults.standard.integer(forKey: "dailyCalorieGoal") > 0
            ? UserDefaults.standard.integer(forKey: "dailyCalorieGoal") : AppConstants.Defaults.dailyCalorieGoal
        let eaten = Int(totalCalories(from: foodEntries, supplements: supplementEntries))
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
        lines.append("Macros: P \(String(format: "%.0f", totalProtein(from: foodEntries, supplements: supplementEntries)))g · C \(String(format: "%.0f", totalCarbs(from: foodEntries, supplements: supplementEntries)))g · F \(String(format: "%.0f", totalFat(from: foodEntries, supplements: supplementEntries)))g")
        lines.append("")
        lines.append("Logged with MindLab Fitness")
        return lines.joined(separator: "\n")
    }
}
