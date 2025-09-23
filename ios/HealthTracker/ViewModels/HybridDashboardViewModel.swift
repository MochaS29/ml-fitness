import SwiftUI
import Combine
import CoreMotion
import CoreData

class DashboardViewModel: ObservableObject {
    // User Info
    @Published var userName = "User"
    @Published var healthScore: Double = 0

    // Services
    private let stepCounter = StepCounterService.shared
    private let userProfileManager = UserProfileManager()
    private let viewContext = PersistenceController.shared.container.viewContext
    private var cancellables = Set<AnyCancellable>()

    // Simple goals storage (until proper goals system is implemented)
    @Published var dailyStepGoal: Int = UserDefaults.standard.integer(forKey: "dailyStepGoal") > 0 ? UserDefaults.standard.integer(forKey: "dailyStepGoal") : 8000
    @Published var dailyCalorieGoal: Int = UserDefaults.standard.integer(forKey: "dailyCalorieGoal") > 0 ? UserDefaults.standard.integer(forKey: "dailyCalorieGoal") : 2000
    @Published var dailyWaterGoal: Int = UserDefaults.standard.integer(forKey: "dailyWaterGoal") > 0 ? UserDefaults.standard.integer(forKey: "dailyWaterGoal") : 8
    @Published var weightGoal: Double = UserDefaults.standard.double(forKey: "weightGoal")

    init() {
        // Load user profile
        loadUserProfile()

        // Setup bindings and load goals
        setupStepCounterBindings()
        loadSimpleGoals()
        loadTodayWaterIntake()
        loadTodayExerciseData()
        loadTodayCalories()
        calculateHealthScore()

        // Listen for UserDefaults changes to refresh goals
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userDefaultsDidChange),
            name: UserDefaults.didChangeNotification,
            object: nil
        )

        // Listen for Core Data changes to refresh water intake and exercise
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(managedObjectContextDidSave),
            name: .NSManagedObjectContextDidSave,
            object: nil
        )

        // Start step counting immediately with a short delay for UI to stabilize
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.stepCounter.startStepCounting()
        }
    }

    @objc private func userDefaultsDidChange() {
        // Reload goals when UserDefaults changes
        loadSimpleGoals()
    }

    @objc private func managedObjectContextDidSave(_ notification: Notification) {
        // Reload all data when Core Data changes
        loadTodayWaterIntake()
        loadTodayExerciseData()
        loadTodayCalories()
        calculateHealthScore()
    }

    private func calculateHealthScore() {
        var score: Double = 0
        var componentsCount = 0

        print("Calculating health score - Steps: \(todaySteps)/\(stepGoal), Exercise: \(todayExercise), Water: \(todayWater)/\(waterGoal), Calories: \(todayCalories)/\(calorieGoal)")

        // Step score (0-100 based on goal)
        if stepGoal > 0 {
            let stepScore = min(Double(todaySteps) / Double(stepGoal) * 100, 100)
            score += stepScore
            componentsCount += 1
            print("Step score: \(stepScore)")
        }

        // Exercise score (0-100, 30 min = 100%)
        if todayExercise > 0 {
            let exerciseScore = min(Double(todayExercise) / 30.0 * 100, 100)
            score += exerciseScore
            componentsCount += 1
        }

        // Water score (0-100 based on goal)
        if waterGoal > 0 {
            let waterScore = min(Double(todayWater) / Double(waterGoal) * 100, 100)
            score += waterScore
            componentsCount += 1
        }

        // Calorie score (0-100, perfect = staying under goal)
        if calorieGoal > 0 && todayCalories > 0 {
            // Score is 100 if at or under goal, decreases if over
            let calorieScore: Double
            if todayCalories <= calorieGoal {
                // Under or at goal: score based on how close to goal (eating too little is also not ideal)
                let percentOfGoal = Double(todayCalories) / Double(calorieGoal)
                if percentOfGoal >= 0.8 {
                    calorieScore = 100 // 80-100% of goal is perfect
                } else {
                    calorieScore = percentOfGoal * 125 // Scale up for lower intake
                }
            } else {
                // Over goal: decrease score
                let percentOver = Double(todayCalories - calorieGoal) / Double(calorieGoal)
                calorieScore = max(0, 100 - (percentOver * 200)) // Lose points for going over
            }
            score += calorieScore
            componentsCount += 1
        }

        // Weight loss progress score (0-100 based on progress to goal)
        if let profile = userProfileManager.currentProfile,
           let startingWeight = profile.startingWeight,
           targetWeight > 0 && startingWeight != targetWeight {

            let totalToLose = abs(startingWeight - targetWeight)
            let currentProgress = abs(startingWeight - currentWeight)

            // Calculate progress percentage (capped at 100)
            let weightScore = min((currentProgress / totalToLose) * 100, 100)

            // Bonus points for consistent weight tracking
            if currentWeight > 0 && currentWeight != startingWeight {
                score += weightScore
                componentsCount += 1
            }
        }

        // Calculate average score
        if componentsCount > 0 {
            healthScore = score / Double(componentsCount)
            print("Final health score: \(healthScore) from \(componentsCount) components")
        } else {
            // If no components, but we have goals, give partial credit for having goals set
            if stepGoal > 0 || waterGoal > 0 || calorieGoal > 0 {
                healthScore = 25 // Base score for having goals
                print("Base health score: 25 for having goals set")
            } else {
                healthScore = 0
                print("No health score - no goals or data")
            }
        }
    }

    private func loadTodayWaterIntake() {
        let request = NSFetchRequest<WaterEntry>(entityName: "WaterEntry")
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        request.predicate = NSPredicate(format: "timestamp >= %@ AND timestamp < %@", startOfDay as NSDate, endOfDay as NSDate)

        do {
            let entries = try viewContext.fetch(request)
            let totalOunces = entries.reduce(0) { $0 + $1.amount }

            // Convert ounces to glasses (8 oz per glass)
            DispatchQueue.main.async { [weak self] in
                self?.todayWater = Int(totalOunces / 8.0)
            }
        } catch {
            print("Error fetching water entries: \(error)")
        }
    }

    private func loadTodayExerciseData() {
        let request = NSFetchRequest<ExerciseEntry>(entityName: "ExerciseEntry")
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        request.predicate = NSPredicate(format: "timestamp >= %@ AND timestamp < %@", startOfDay as NSDate, endOfDay as NSDate)

        do {
            let entries = try viewContext.fetch(request)

            // Calculate total minutes and number of sessions
            let totalMinutes = entries.reduce(0) { $0 + Int($1.duration) }
            let sessionCount = entries.count

            DispatchQueue.main.async { [weak self] in
                self?.todayExercise = totalMinutes
                self?.exerciseSessions = sessionCount
            }
        } catch {
            print("Error fetching exercise entries: \(error)")
        }
    }

    private func loadTodayCalories() {
        let request = NSFetchRequest<FoodEntry>(entityName: "FoodEntry")
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        request.predicate = NSPredicate(format: "timestamp >= %@ AND timestamp < %@", startOfDay as NSDate, endOfDay as NSDate)

        do {
            let entries = try viewContext.fetch(request)

            // Calculate total calories from food entries
            let totalCalories = entries.reduce(0) { $0 + Int($1.calories) }

            DispatchQueue.main.async { [weak self] in
                self?.todayCalories = totalCalories
            }
        } catch {
            print("Error fetching food entries: \(error)")
        }
    }

    private func loadUserProfile() {
        if let profile = userProfileManager.currentProfile {
            userName = profile.name
            if let startingWeight = profile.startingWeight {
                currentWeight = startingWeight
            } else {
                currentWeight = 0.0
            }
        } else {
            userName = "User"
            currentWeight = 0.0
        }
    }

    private func loadSimpleGoals() {
        // Reload from UserDefaults to get latest values
        let newStepGoal = UserDefaults.standard.integer(forKey: "dailyStepGoal")
        if newStepGoal > 0 {
            dailyStepGoal = newStepGoal
            stepGoal = newStepGoal
        } else {
            stepGoal = dailyStepGoal
        }

        let newCalorieGoal = UserDefaults.standard.integer(forKey: "dailyCalorieGoal")
        if newCalorieGoal > 0 {
            dailyCalorieGoal = newCalorieGoal
            calorieGoal = newCalorieGoal
        } else {
            calorieGoal = dailyCalorieGoal
        }

        let newWaterGoal = UserDefaults.standard.integer(forKey: "dailyWaterGoal")
        if newWaterGoal > 0 {
            dailyWaterGoal = newWaterGoal
            waterGoal = newWaterGoal
        } else {
            waterGoal = dailyWaterGoal
        }

        let newWeightGoal = UserDefaults.standard.double(forKey: "weightGoal")
        if newWeightGoal > 0 {
            weightGoal = newWeightGoal
            targetWeight = newWeightGoal
        } else {
            targetWeight = currentWeight
        }
    }

    func saveStepGoal(_ goal: Int) {
        dailyStepGoal = goal
        stepGoal = goal
        UserDefaults.standard.set(goal, forKey: "dailyStepGoal")
    }

    func saveCalorieGoal(_ goal: Int) {
        dailyCalorieGoal = goal
        calorieGoal = goal
        UserDefaults.standard.set(goal, forKey: "dailyCalorieGoal")
    }

    func saveWaterGoal(_ goal: Int) {
        dailyWaterGoal = goal
        waterGoal = goal
        UserDefaults.standard.set(goal, forKey: "dailyWaterGoal")
    }

    func saveWeightGoal(_ goal: Double) {
        weightGoal = goal
        targetWeight = goal
        UserDefaults.standard.set(goal, forKey: "weightGoal")
    }

    func addWaterGlass() {
        // Add 8 oz of water (1 glass)
        let entry = WaterEntry(context: viewContext)
        entry.id = UUID()
        entry.amount = 8.0 // 8 oz per glass
        entry.timestamp = Date()
        entry.unit = "oz"

        do {
            try viewContext.save()
            // Water intake will be updated via Core Data notification
        } catch {
            print("Error saving water entry: \(error)")
        }
    }

    func removeWaterGlass() {
        // Remove the last water entry for today
        let request = NSFetchRequest<WaterEntry>(entityName: "WaterEntry")
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        request.predicate = NSPredicate(format: "timestamp >= %@ AND timestamp < %@", startOfDay as NSDate, endOfDay as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        request.fetchLimit = 1

        do {
            let entries = try viewContext.fetch(request)
            if let lastEntry = entries.first {
                viewContext.delete(lastEntry)
                try viewContext.save()
            }
        } catch {
            print("Error removing water entry: \(error)")
        }
    }

    private func setupStepCounterBindings() {
        // Bind step counter data to dashboard
        stepCounter.$todaySteps
            .sink { [weak self] steps in
                self?.todaySteps = steps
                self?.calculateHealthScore() // Recalculate when steps update
            }
            .store(in: &cancellables)

        // Update sparkline with hourly data
        stepCounter.$hourlySteps
            .sink { [weak self] hourlyData in
                // Convert to sparkline format (last 7 hours shown)
                let recentHours = Array(hourlyData.suffix(7))
                self?.stepsSparkline = recentHours.map { Double($0) }
            }
            .store(in: &cancellables)
    }

    // AI Greetings and Analysis
    var aiGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            return "Great morning! You're 15% more active than usual this week 🌟"
        case 12..<17:
            return "Keep it up! You're on track to meet 4 of 5 goals today 💪"
        case 17..<22:
            return "Strong finish! Just 200 calories to reach your protein goal 🎯"
        default:
            return "Rest well! Your body burns 1,800 calories even at rest 😴"
        }
    }
    
    var healthTrend: String {
        return healthScore > 80 ? "Excellent Progress" : "Room for Improvement"
    }
    
    var healthTrendIcon: String {
        return healthScore > 80 ? "arrow.up.right.circle.fill" : "arrow.right.circle.fill"
    }
    
    var healthTrendColor: Color {
        return healthScore > 80 ? .green : .orange
    }
    
    var healthSummary: String {
        // Generate real summary based on actual data
        var summaryParts: [String] = []

        // Steps summary
        if todaySteps > 0 {
            summaryParts.append("\(todaySteps.formatted()) steps today")
        }

        // Exercise summary
        if todayExercise > 0 {
            summaryParts.append("\(todayExercise) min of exercise")
        }

        // Water summary
        if todayWater > 0 {
            let percent = waterPercentage
            summaryParts.append("\(percent)% hydrated")
        }

        if summaryParts.isEmpty {
            return "Start tracking your activities to see your progress"
        } else {
            return summaryParts.joined(separator: " • ")
        }
    }
    
    // Today's Metrics
    // These will be updated from real data sources
    @Published var todayCalories = 0
    @Published var calorieGoal = 2000
    @Published var todaySteps = 0
    @Published var stepGoal = 8000
    @Published var currentWeight = 0.0
    @Published var targetWeight = 0.0
    @Published var todayExercise = 0
    @Published var exerciseSessions = 0
    @Published var todayWater = 0
    @Published var waterGoal = 8
    
    // Calculated Properties
    var weightProgress: Double {
        guard let profile = userProfileManager.currentProfile,
              let startingWeight = profile.startingWeight,
              targetWeight > 0 else { return 0 }

        let totalChange = abs(startingWeight - targetWeight)
        guard totalChange > 0 else { return 0 }

        let currentChange = abs(startingWeight - currentWeight)
        return min((currentChange / totalChange) * 100, 100)
    }
    
    var waterPercentage: Int {
        Int((Double(todayWater) / Double(waterGoal)) * 100)
    }
    
    // Trends
    var calorieTrend: MetricCardWithTrend.Trend = .up
    var calorieTrendPercent = 8
    var stepsTrend: MetricCardWithTrend.Trend = .up
    var stepsTrendPercent = 15
    var weightTrend: MetricCardWithTrend.Trend = .down
    var weightTrendPercent = -2  // Lost 2% this week
    var waterTrend: MetricCardWithTrend.Trend = .neutral
    var waterTrendPercent = 0

    // Sparkline Data (last 7 days)
    // TODO: Replace with real historical data
    var calorieSparkline: [Double] = [] // Mock: [1850, 2100, 1950, 2200, 1900, 2050, 1650]
    var stepsSparkline: [Double] = [] // Mock: [7500, 8200, 9100, 8800, 10200, 9500, 8547]
    var weightSparkline: [Double] = [] // Mock: [167.2, 167.0, 166.8, 166.5, 166.2, 165.8, 165.5]
    var exerciseSparkline: [Double] = [] // Mock: [30, 0, 45, 60, 0, 30, 45]
    var waterSparkline: [Double] = [] // Mock: [7, 8, 6, 8, 7, 5, 6]
    
    // Nutrition Distribution - Calculate from actual food entries
    var nutritionData: [HybridNutritionItem] {
        // Fetch today's food entries and calculate macro distribution
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let request = NSFetchRequest<FoodEntry>(entityName: "FoodEntry")
        request.predicate = NSPredicate(format: "timestamp >= %@ AND timestamp < %@",
                                       startOfDay as NSDate, endOfDay as NSDate)

        do {
            let entries = try viewContext.fetch(request)

            // Calculate total macros in grams
            var totalProtein: Double = 0
            var totalCarbs: Double = 0
            var totalFat: Double = 0

            for entry in entries {
                totalProtein += entry.protein
                totalCarbs += entry.carbs
                totalFat += entry.fat
            }

            // Convert to calories (protein: 4 cal/g, carbs: 4 cal/g, fat: 9 cal/g)
            let proteinCalories = totalProtein * 4
            let carbCalories = totalCarbs * 4
            let fatCalories = totalFat * 9
            let totalCalories = proteinCalories + carbCalories + fatCalories

            // If no macros logged, return empty
            if totalCalories == 0 {
                return []
            }

            // Calculate percentages based on calories and create distribution items
            return [
                HybridNutritionItem(
                    name: "Protein",
                    value: proteinCalories,
                    percentage: (proteinCalories / totalCalories) * 100,
                    color: .blue
                ),
                HybridNutritionItem(
                    name: "Carbs",
                    value: carbCalories,
                    percentage: (carbCalories / totalCalories) * 100,
                    color: .orange
                ),
                HybridNutritionItem(
                    name: "Fat",
                    value: fatCalories,
                    percentage: (fatCalories / totalCalories) * 100,
                    color: .purple
                )
            ]
        } catch {
            print("Error fetching food entries for nutrition distribution: \(error)")
            return []
        }
    }
    
    // Weekly Data for Chart - No mock data
    var weeklyData: [WeeklyDataPoint] {
        // Return empty data until user has logged actual data
        return []
    }
    
    // AI Insights - Generated from real data
    var aiInsights: [AIInsight] {
        var insights: [AIInsight] = []

        // Step insight
        if stepGoal > 0 {
            let stepPercentage = Double(todaySteps) / Double(stepGoal) * 100
            if stepPercentage < 50 {
                insights.append(AIInsight(
                    title: "Step Goal Progress",
                    description: "You're at \(Int(stepPercentage))% of your daily step goal. Try a 10-minute walk to boost your progress.",
                    icon: "figure.walk",
                    color: .green,
                    impact: "Medium Impact",
                    isNew: false
                ))
            } else if stepPercentage >= 100 {
                insights.append(AIInsight(
                    title: "Step Goal Achieved!",
                    description: "Great job! You've reached \(todaySteps.formatted()) steps today, exceeding your goal of \(stepGoal).",
                    icon: "star.fill",
                    color: .yellow,
                    impact: "Positive",
                    isNew: true
                ))
            }
        }

        // Hydration insight
        if waterGoal > 0 {
            let waterPercentage = self.waterPercentage
            if waterPercentage < 50 && Calendar.current.component(.hour, from: Date()) > 14 {
                insights.append(AIInsight(
                    title: "Hydration Alert",
                    description: "You're only \(waterPercentage)% hydrated. Aim to drink \(waterGoal - todayWater) more glasses today.",
                    icon: "drop.fill",
                    color: .cyan,
                    impact: "High Impact",
                    isNew: true
                ))
            }
        }

        // Exercise insight
        if todayExercise == 0 && Calendar.current.component(.hour, from: Date()) > 12 {
            insights.append(AIInsight(
                title: "Movement Reminder",
                description: "No exercise logged today. Even 15 minutes of activity can boost your energy and health score.",
                icon: "figure.run",
                color: .orange,
                impact: "Medium Impact",
                isNew: false
            ))
        } else if todayExercise >= 30 {
            insights.append(AIInsight(
                title: "Exercise Goal Met!",
                description: "You've completed \(todayExercise) minutes of exercise. Great for heart health and weight management!",
                icon: "heart.fill",
                color: .red,
                impact: "Positive",
                isNew: false
            ))
        }

        // Calorie insight
        if calorieGoal > 0 && todayCalories > 0 {
            let caloriePercentage = Double(todayCalories) / Double(calorieGoal) * 100
            if caloriePercentage > 110 {
                insights.append(AIInsight(
                    title: "Calorie Overage",
                    description: "You're \(todayCalories - calorieGoal) calories over your goal. Consider a lighter dinner or evening walk.",
                    icon: "exclamationmark.triangle",
                    color: .orange,
                    impact: "High Impact",
                    isNew: true
                ))
            }
        }

        // Return insights or a default if none
        if insights.isEmpty {
            insights.append(AIInsight(
                title: "Start Tracking",
                description: "Log your activities to get personalized health insights and recommendations.",
                icon: "lightbulb.fill",
                color: .blue,
                impact: "Get Started",
                isNew: true
            ))
        }

        return insights
    }
    
    // AI Recommendations - Based on real data
    var recommendations: [AIRecommendation] {
        var recs: [AIRecommendation] = []

        // Step recommendation
        if stepGoal > 0 && todaySteps < stepGoal {
            let stepsNeeded = stepGoal - todaySteps
            recs.append(AIRecommendation(
                title: "Take \(stepsNeeded.formatted()) more steps",
                description: "A \(stepsNeeded / 100)-minute walk would help you reach your daily goal",
                icon: "figure.walk.motion",
                color: .green,
                actionText: "Start walking timer"
            ))
        }

        // Hydration recommendation
        if waterPercentage < 75 && Calendar.current.component(.hour, from: Date()) < 18 {
            recs.append(AIRecommendation(
                title: "Increase water intake",
                description: "Drink \(waterGoal - todayWater) more glasses to reach your hydration goal",
                icon: "drop.circle.fill",
                color: .cyan,
                actionText: "Set water reminder"
            ))
        }

        // Exercise recommendation
        if todayExercise < 30 {
            let minutesNeeded = 30 - todayExercise
            recs.append(AIRecommendation(
                title: "Add \(minutesNeeded) minutes of exercise",
                description: "Regular exercise improves health score and supports weight goals",
                icon: "figure.run.circle",
                color: .orange,
                actionText: "View quick workouts"
            ))
        }

        // Weight loss recommendation
        if targetWeight > 0 && currentWeight > targetWeight {
            let toGo = currentWeight - targetWeight
            recs.append(AIRecommendation(
                title: "Stay focused on your goal",
                description: "You're \(String(format: "%.1f", toGo)) lbs from your target weight. Keep tracking!",
                icon: "target",
                color: .purple,
                actionText: "View weight trend"
            ))
        }

        // Default recommendation if none
        if recs.isEmpty {
            recs.append(AIRecommendation(
                title: "Set your health goals",
                description: "Establish daily targets for steps, water, and exercise",
                icon: "flag.circle",
                color: .blue,
                actionText: "Set goals"
            ))
        }

        return Array(recs.prefix(3)) // Return max 3 recommendations
    }
    
    // Nutrient Breakdown - Including supplements
    var nutrientBreakdown: [NutrientBreakdown] {
        var nutrients: [NutrientBreakdown] = []

        // Only show calories if we have actual food logged
        if todayCalories > 0 {
            nutrients.append(NutrientBreakdown(
                name: "Calories",
                current: "\(todayCalories)",
                goal: "\(calorieGoal)",
                percentage: (Double(todayCalories) / Double(calorieGoal)) * 100,
                color: .orange
            ))
        }

        // Add vitamins and minerals from supplements
        let supplementNutrients = getTodaySupplementNutrients()

        // Common vitamins with their RDAs
        let vitaminRDAs: [(id: String, name: String, rda: Double, unit: String, color: Color)] = [
            ("vitamin_a", "Vitamin A", 900, "mcg", .orange),
            ("vitamin_c", "Vitamin C", 90, "mg", .yellow),
            ("vitamin_d", "Vitamin D", 600, "IU", .blue),
            ("vitamin_e", "Vitamin E", 15, "mg", .green),
            ("vitamin_k", "Vitamin K", 120, "mcg", .green),
            ("thiamine", "Vitamin B1", 1.2, "mg", .purple),
            ("riboflavin", "Vitamin B2", 1.3, "mg", .purple),
            ("niacin", "Vitamin B3", 16, "mg", .purple),
            ("vitamin_b6", "Vitamin B6", 1.3, "mg", .purple),
            ("folate", "Folate", 400, "mcg", .purple),
            ("vitamin_b12", "Vitamin B12", 2.4, "mcg", .purple),
            ("biotin", "Biotin", 30, "mcg", .purple)
        ]

        // Common minerals with their RDAs
        let mineralRDAs: [(id: String, name: String, rda: Double, unit: String, color: Color)] = [
            ("calcium", "Calcium", 1000, "mg", .gray),
            ("iron", "Iron", 18, "mg", .red),
            ("magnesium", "Magnesium", 400, "mg", .blue),
            ("zinc", "Zinc", 11, "mg", Color(red: 139/255, green: 69/255, blue: 19/255)),
            ("selenium", "Selenium", 55, "mcg", .mindfulTeal),
            ("potassium", "Potassium", 2600, "mg", .orange),
            ("phosphorus", "Phosphorus", 700, "mg", .mindfulTeal)
        ]

        // Add vitamins to breakdown
        for vitamin in vitaminRDAs {
            if let amount = supplementNutrients[vitamin.id], amount > 0 {
                let percentage = (amount / vitamin.rda) * 100
                nutrients.append(NutrientBreakdown(
                    name: vitamin.name,
                    current: String(format: "%.1f", amount),
                    goal: "\(Int(vitamin.rda)) \(vitamin.unit)",
                    percentage: percentage,
                    color: vitamin.color
                ))
            }
        }

        // Add minerals to breakdown
        for mineral in mineralRDAs {
            if let amount = supplementNutrients[mineral.id], amount > 0 {
                let percentage = (amount / mineral.rda) * 100
                nutrients.append(NutrientBreakdown(
                    name: mineral.name,
                    current: String(format: "%.1f", amount),
                    goal: "\(Int(mineral.rda)) \(mineral.unit)",
                    percentage: percentage,
                    color: mineral.color
                ))
            }
        }

        return nutrients
    }

    private func getTodaySupplementNutrients() -> [String: Double] {
        var totalNutrients: [String: Double] = [:]

        // Fetch today's supplement entries
        let request = NSFetchRequest<SupplementEntry>(entityName: "SupplementEntry")
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        request.predicate = NSPredicate(format: "timestamp >= %@ AND timestamp < %@", startOfDay as NSDate, endOfDay as NSDate)

        do {
            let entries = try viewContext.fetch(request)

            // Aggregate nutrients from all supplements
            for entry in entries {
                if let nutrients = entry.nutrients {
                    for (nutrientId, amount) in nutrients {
                        totalNutrients[nutrientId, default: 0] += amount
                    }
                }
            }
        } catch {
            print("Error fetching supplement entries: \(error)")
        }

        return totalNutrients
    }

    func updateTimeRange(_ range: HybridDashboardView.TimeRange) {
        // Update data based on selected time range
        switch range {
        case .day:
            // Load today's data
            print("Loading day data")
        case .week:
            // Load week's data
            print("Loading week data")
        case .month:
            // Load month's data
            print("Loading month data")
        }
        // Trigger UI update
        objectWillChange.send()
    }

    // MARK: - Chart Data Methods

    func getCaloriesData(for range: HybridDashboardView.TimeRange) -> [ChartDataPoint] {
        // Return empty data until user logs food
        return []
    }

    func getWeightData(for range: HybridDashboardView.TimeRange) -> [ChartDataPoint] {
        // Get weight data for the past 7 days
        var dataPoints: [ChartDataPoint] = []
        let calendar = Calendar.current
        let today = Date()

        // Fetch weight entries for each day
        for dayOffset in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) {
                let startOfDay = calendar.startOfDay(for: date)
                let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

                let request = NSFetchRequest<WeightEntry>(entityName: "WeightEntry")
                request.predicate = NSPredicate(format: "timestamp >= %@ AND timestamp < %@", startOfDay as NSDate, endOfDay as NSDate)
                request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
                request.fetchLimit = 1

                do {
                    let entries = try viewContext.fetch(request)
                    if let entry = entries.first {
                        dataPoints.append(ChartDataPoint(date: date, value: entry.weight))
                    } else if dayOffset == 0 && currentWeight > 0 {
                        // Use current weight for today if no entry
                        dataPoints.append(ChartDataPoint(date: date, value: currentWeight))
                    }
                } catch {
                    if dayOffset == 0 && currentWeight > 0 {
                        dataPoints.append(ChartDataPoint(date: date, value: currentWeight))
                    }
                }
            }
        }

        return dataPoints.reversed()
    }

    func getExerciseData(for range: HybridDashboardView.TimeRange) -> [ChartDataPoint] {
        // Get exercise data for the past 7 days
        var dataPoints: [ChartDataPoint] = []
        let calendar = Calendar.current
        let today = Date()

        // Fetch exercise data for each day
        for dayOffset in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) {
                let startOfDay = calendar.startOfDay(for: date)
                let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

                let request = NSFetchRequest<ExerciseEntry>(entityName: "ExerciseEntry")
                request.predicate = NSPredicate(format: "timestamp >= %@ AND timestamp < %@", startOfDay as NSDate, endOfDay as NSDate)

                do {
                    let entries = try viewContext.fetch(request)
                    let totalMinutes = entries.reduce(0) { $0 + Int($1.duration) }
                    dataPoints.append(ChartDataPoint(date: date, value: Double(totalMinutes)))
                } catch {
                    dataPoints.append(ChartDataPoint(date: date, value: 0))
                }
            }
        }

        return dataPoints.reversed()
    }

    func getWeeklyStepsData() -> [ChartDataPoint] {
        // Get step data for the past 7 days
        var dataPoints: [ChartDataPoint] = []
        let calendar = Calendar.current
        let today = Date()

        for dayOffset in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) {
                // For now, use today's step count for current day, 0 for others
                // This will be expanded to fetch historical data from HealthKit
                let steps = dayOffset == 0 ? Double(todaySteps) : 0
                dataPoints.append(ChartDataPoint(date: date, value: steps))
            }
        }

        return dataPoints.reversed()
    }

    func getStepsData(for range: HybridDashboardView.TimeRange) -> [ChartDataPoint] {
        // Deprecated - use getWeeklyStepsData instead
        return []

        /* Original mock data - commented out
        switch range {
        case .day:
            // Hourly steps for today (24 hours)
            let calendar = Calendar.current
            let now = Date()
            let startOfDay = calendar.startOfDay(for: now)

            return (0..<24).map { hour in
                let date = calendar.date(byAdding: .hour, value: hour, to: startOfDay)!
                let currentHour = calendar.component(.hour, from: now)

                // Generate realistic step data
                let steps: Double = {
                    if hour > currentHour {
                        return 0 // Future hours have no steps
                    } else if hour < 6 {
                        return Double.random(in: 0...50) // Early morning
                    } else if hour < 9 {
                        return Double.random(in: 200...500) // Morning activity
                    } else if hour < 12 {
                        return Double.random(in: 300...800) // Mid-morning
                    } else if hour < 14 {
                        return Double.random(in: 400...900) // Lunch time
                    } else if hour < 18 {
                        return Double.random(in: 300...700) // Afternoon
                    } else if hour < 21 {
                        return Double.random(in: 200...600) // Evening
                    } else {
                        return Double.random(in: 50...200) // Night
                    }
                }()

                return ChartDataPoint(date: date, value: steps)
            }
        case .week:
            // Daily steps for past 7 days
            return (0..<7).map { dayOffset in
                ChartDataPoint(
                    date: Calendar.current.date(byAdding: .day, value: -dayOffset, to: Date())!,
                    value: Double([7500, 8200, 9100, 8800, 10200, 9500, 8547][dayOffset % 7])
                )
            }.reversed()
        case .month:
            // Weekly averages for past month
            return (0..<4).map { weekOffset in
                ChartDataPoint(
                    date: Calendar.current.date(byAdding: .weekOfYear, value: -weekOffset, to: Date())!,
                    value: Double.random(in: 8000...10000)
                )
            }.reversed()
        }
        */
    }

    func getWeightRange(for range: HybridDashboardView.TimeRange) -> ClosedRange<Double> {
        switch range {
        case .day:
            return (currentWeight - 2)...(currentWeight + 2)
        case .week:
            return (currentWeight - 3)...(currentWeight + 3)
        case .month:
            return (currentWeight - 5)...(currentWeight + 5)
        }
    }
}

// MARK: - Data Models

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

struct HybridNutritionItem: Identifiable {
    let id = UUID()
    let name: String
    let value: Double
    let percentage: Double
    let color: Color
}

struct WeeklyDataPoint: Identifiable {
    let id = UUID()
    let day: String
    let value: Double
}

// MARK: - AI Insight Detail View

struct AIInsightDetailView: View {
    let insight: AIInsight
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .center, spacing: 16) {
                        Image(systemName: insight.icon)
                            .font(.system(size: 60))
                            .foregroundColor(insight.color)
                        
                        Text(insight.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Label(insight.impact, systemImage: "sparkles")
                            .font(.subheadline)
                            .foregroundColor(insight.color)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(insight.color.opacity(0.1))
                            .cornerRadius(20)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    
                    // Description
                    VStack(alignment: .leading, spacing: 16) {
                        Text("What we discovered")
                            .font(.headline)
                            .foregroundColor(.deepCharcoal)
                        
                        Text(insight.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal)
                    
                    // Evidence
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Supporting Data")
                            .font(.headline)
                            .foregroundColor(.deepCharcoal)
                        
                        VStack(spacing: 12) {
                            DataPointRow(label: "Confidence Level", value: "0%", icon: "checkmark.shield.fill")
                            DataPointRow(label: "Data Points Analyzed", value: "0", icon: "chart.line.uptrend.xyaxis")
                            DataPointRow(label: "Pattern Detected", value: "None", icon: "calendar")
                            DataPointRow(label: "Similar Users", value: "0", icon: "person.3.fill")
                        }
                    }
                    .padding(.horizontal)
                    
                    // Action Steps
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recommended Actions")
                            .font(.headline)
                            .foregroundColor(.deepCharcoal)
                        
                        VStack(spacing: 12) {
                            ActionStepRow(number: 1, text: "Track this metric for the next 7 days")
                            ActionStepRow(number: 2, text: "Adjust your routine based on the insight")
                            ActionStepRow(number: 3, text: "Monitor changes in your energy levels")
                        }
                    }
                    .padding(.horizontal)
                    
                    // CTA Button
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Apply This Insight")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(insight.color)
                            .cornerRadius(12)
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct DataPointRow: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(.mindfulTeal)
                .frame(width: 30)
            
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.deepCharcoal)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
}

struct ActionStepRow: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Color.mindfulTeal)
                .clipShape(Circle())
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.deepCharcoal)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}