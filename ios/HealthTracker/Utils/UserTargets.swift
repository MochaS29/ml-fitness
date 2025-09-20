import Foundation

class UserTargets {
    static let shared = UserTargets()

    private let defaults = UserDefaults.standard

    // Keys for UserDefaults
    private let calorieTargetKey = "dailyCalorieTarget"
    private let exerciseTargetKey = "dailyExerciseTarget"
    private let waterTargetKey = "dailyWaterTarget"
    private let weightGoalKey = "weightGoal"
    private let proteinTargetKey = "dailyProteinTarget"
    private let carbTargetKey = "dailyCarbTarget"
    private let fatTargetKey = "dailyFatTarget"

    // Default values
    private let defaultCalorieTarget: Double = 2000
    private let defaultExerciseTarget: Int = 30  // minutes
    private let defaultWaterTarget: Double = 64  // ounces
    private let defaultProteinTarget: Double = 50  // grams
    private let defaultCarbTarget: Double = 250  // grams
    private let defaultFatTarget: Double = 65  // grams

    private init() {
        setupDefaultsIfNeeded()
    }

    private func setupDefaultsIfNeeded() {
        // Set defaults if not already set
        if defaults.object(forKey: calorieTargetKey) == nil {
            defaults.set(defaultCalorieTarget, forKey: calorieTargetKey)
        }

        if defaults.object(forKey: exerciseTargetKey) == nil {
            defaults.set(defaultExerciseTarget, forKey: exerciseTargetKey)
        }

        if defaults.object(forKey: waterTargetKey) == nil {
            defaults.set(defaultWaterTarget, forKey: waterTargetKey)
        }

        if defaults.object(forKey: proteinTargetKey) == nil {
            defaults.set(defaultProteinTarget, forKey: proteinTargetKey)
        }

        if defaults.object(forKey: carbTargetKey) == nil {
            defaults.set(defaultCarbTarget, forKey: carbTargetKey)
        }

        if defaults.object(forKey: fatTargetKey) == nil {
            defaults.set(defaultFatTarget, forKey: fatTargetKey)
        }
    }

    // MARK: - Calorie Target

    var calorieTarget: Double {
        get { defaults.double(forKey: calorieTargetKey) }
        set { defaults.set(newValue, forKey: calorieTargetKey) }
    }

    // MARK: - Exercise Target

    var exerciseTarget: Int {
        get { defaults.integer(forKey: exerciseTargetKey) }
        set { defaults.set(newValue, forKey: exerciseTargetKey) }
    }

    // MARK: - Water Target

    var waterTarget: Double {
        get { defaults.double(forKey: waterTargetKey) }
        set { defaults.set(newValue, forKey: waterTargetKey) }
    }

    // MARK: - Weight Goal

    var weightGoal: Double? {
        get {
            let value = defaults.double(forKey: weightGoalKey)
            return value > 0 ? value : nil
        }
        set { defaults.set(newValue ?? 0, forKey: weightGoalKey) }
    }

    // MARK: - Macro Targets

    var proteinTarget: Double {
        get { defaults.double(forKey: proteinTargetKey) }
        set { defaults.set(newValue, forKey: proteinTargetKey) }
    }

    var carbTarget: Double {
        get { defaults.double(forKey: carbTargetKey) }
        set { defaults.set(newValue, forKey: carbTargetKey) }
    }

    var fatTarget: Double {
        get { defaults.double(forKey: fatTargetKey) }
        set { defaults.set(newValue, forKey: fatTargetKey) }
    }

    // MARK: - Helper Methods

    func isWithinCalorieTarget(_ calories: Double, tolerance: Double = 0.05) -> Bool {
        let target = calorieTarget
        let difference = abs(calories - target)
        let percentageOff = difference / target
        return percentageOff <= tolerance
    }

    func calculateCalorieDeficit(consumed: Double) -> Double {
        return calorieTarget - consumed
    }

    func calculateMacroTargets(for calories: Double) {
        // Standard macro split: 40% carbs, 30% protein, 30% fat
        let carbCalories = calories * 0.4
        let proteinCalories = calories * 0.3
        let fatCalories = calories * 0.3

        // Convert to grams (carbs: 4 cal/g, protein: 4 cal/g, fat: 9 cal/g)
        carbTarget = carbCalories / 4
        proteinTarget = proteinCalories / 4
        fatTarget = fatCalories / 9
    }

    func resetToDefaults() {
        calorieTarget = defaultCalorieTarget
        exerciseTarget = defaultExerciseTarget
        waterTarget = defaultWaterTarget
        proteinTarget = defaultProteinTarget
        carbTarget = defaultCarbTarget
        fatTarget = defaultFatTarget
        weightGoal = nil
    }
}