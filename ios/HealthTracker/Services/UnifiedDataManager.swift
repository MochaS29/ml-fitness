import Foundation
import CoreData
import SwiftUI
import Combine

// MARK: - Unified Data Manager
// Single source of truth for all data operations across the app

class UnifiedDataManager: ObservableObject {
    static let shared = UnifiedDataManager()

    private let context: NSManagedObjectContext
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Published Data
    @Published var todaysFoodEntries: [FoodEntry] = []
    @Published var todaysExerciseEntries: [ExerciseEntry] = []
    @Published var todaysWaterEntries: [WaterEntry] = []
    @Published var todaysSupplementEntries: [SupplementEntry] = []
    @Published var latestWeightEntry: WeightEntry?

    // Summary data
    @Published var todayCalories: Double = 0
    @Published var todayProtein: Double = 0
    @Published var todayCarbs: Double = 0
    @Published var todayFat: Double = 0
    @Published var todayWater: Double = 0
    @Published var todayCaloriesBurned: Double = 0
    @Published var todaySteps: Int = 0
    @Published var currentWeight: Double = 0
    @Published var weightChange: Double = 0

    private init() {
        self.context = PersistenceController.shared.container.viewContext
        setupObservers()
        refreshAllData()
    }

    // MARK: - Setup

    private func setupObservers() {
        // Listen for Core Data changes
        NotificationCenter.default.publisher(for: .NSManagedObjectContextObjectsDidChange, object: context)
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.refreshAllData()
            }
            .store(in: &cancellables)
    }

    // MARK: - Food Management

    func addFoodEntry(
        name: String,
        brand: String? = nil,
        calories: Double,
        protein: Double,
        carbs: Double,
        fat: Double,
        fiber: Double = 0,
        sugar: Double = 0,
        sodium: Double = 0,
        servingSize: String = "1",
        servingUnit: String = "serving",
        mealType: MealType = .snack,
        barcode: String? = nil,
        imageData: Data? = nil,
        date: Date? = nil
    ) {
        let entryDate = date ?? Date()
        let entry = FoodEntry(context: context)
        entry.id = UUID()
        entry.name = name
        entry.brand = brand
        entry.calories = calories
        entry.protein = protein
        entry.carbs = carbs
        entry.fat = fat
        entry.fiber = fiber
        entry.sugar = sugar
        entry.sodium = sodium
        entry.servingSize = servingSize
        entry.servingUnit = servingUnit
        entry.mealType = mealType.rawValue
        entry.barcode = barcode
        entry.timestamp = entryDate
        entry.date = entryDate

        // Store image data if the field exists
        // entry.photoData = imageData  // Uncomment when field is added

        saveContext()

        // Check achievements
        AchievementManager.shared.checkDailyCalorieGoal(consumed: todayCalories, goal: Double(AppConstants.Defaults.dailyCalorieGoal))

        // App Store review prompt
        ReviewRequestManager.shared.recordFoodLogged()

        // Update goals
        GoalsManager.shared.updateGoalsFromFoodEntry(entry)
    }

    func addFoodFromDatabase(_ foodItem: FoodItem, mealType: MealType = .snack) {
        addFoodEntry(
            name: foodItem.name,
            brand: foodItem.brand,
            calories: foodItem.calories,
            protein: foodItem.protein,
            carbs: foodItem.carbs,
            fat: foodItem.fat,
            fiber: foodItem.fiber,
            sugar: foodItem.sugar ?? 0,
            sodium: foodItem.sodium ?? 0,
            servingSize: foodItem.servingSize,
            servingUnit: foodItem.servingUnit,
            mealType: mealType,
            barcode: foodItem.barcode
        )
    }

    func updateFoodEntry(_ entry: FoodEntry) {
        saveContext()
    }

    func deleteFoodEntry(_ entry: FoodEntry) {
        context.delete(entry)
        saveContext()
    }

    // MARK: - Exercise Management

    func addExerciseEntry(
        name: String,
        category: String,
        duration: Int,
        caloriesBurned: Double,
        distance: Double? = nil,
        notes: String? = nil
    ) {
        let entry = ExerciseEntry(context: context)
        entry.id = UUID()
        entry.name = name
        entry.category = category
        entry.type = category
        entry.duration = Int32(duration)
        entry.caloriesBurned = caloriesBurned
        // entry.distance = distance ?? 0  // Uncomment when field is added
        entry.notes = notes
        entry.timestamp = Date()
        entry.date = Date()

        saveContext()

        // Check achievements
        AchievementManager.shared.checkExerciseCompletion(calories: caloriesBurned, duration: duration)

        // Update goals
        GoalsManager.shared.updateGoalsFromExerciseEntry(entry)
    }

    func updateExerciseEntry(_ entry: ExerciseEntry) {
        saveContext()
    }

    func deleteExerciseEntry(_ entry: ExerciseEntry) {
        context.delete(entry)
        saveContext()
    }

    // MARK: - Water Management

    func addWaterEntry(amount: Double, unit: String = "oz") {
        let entry = WaterEntry(context: context)
        entry.id = UUID()
        entry.amount = amount
        entry.unit = unit
        entry.timestamp = Date()

        saveContext()

        // Update goals
        GoalsManager.shared.updateGoalsFromWaterEntry(entry)
    }

    func updateWaterEntry(_ entry: WaterEntry) {
        saveContext()
    }

    func deleteWaterEntry(_ entry: WaterEntry) {
        context.delete(entry)
        saveContext()
    }

    // MARK: - Supplement Management

    func addSupplementEntry(
        name: String,
        brand: String? = nil,
        servingSize: String,
        servingUnit: String,
        nutrients: [String: Double],
        barcode: String? = nil,
        date: Date? = nil
    ) {
        let entryDate = date ?? Date()
        let entry = SupplementEntry(context: context)
        entry.id = UUID()
        entry.name = name
        entry.brand = brand
        entry.servingSize = servingSize
        entry.servingUnit = servingUnit
        entry.nutrients = nutrients
        // entry.barcode = barcode  // Uncomment when field is added
        entry.timestamp = entryDate
        entry.date = entryDate

        saveContext()
    }

    func updateSupplementEntry(_ entry: SupplementEntry) {
        saveContext()
    }

    func deleteSupplementEntry(_ entry: SupplementEntry) {
        context.delete(entry)
        saveContext()
    }

    // MARK: - Weight Management

    func addWeightEntry(weight: Double, unit: String = "lbs", notes: String? = nil) {
        let entry = WeightEntry(context: context)
        entry.id = UUID()
        entry.weight = weight
        // entry.unit = unit  // Uncomment when field is added
        entry.notes = notes
        entry.timestamp = Date()

        saveContext()

        // Check achievements
        AchievementManager.shared.checkWeightLoss(newWeight: weight)

        // Update goals
        GoalsManager.shared.updateGoalsFromWeightEntry(entry)
    }

    // MARK: - Data Refresh

    func refreshAllData() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Food entries
        let foodRequest: NSFetchRequest<FoodEntry> = FoodEntry.fetchRequest()
        foodRequest.predicate = .forDay()
        foodRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]

        // Exercise entries
        let exerciseRequest: NSFetchRequest<ExerciseEntry> = ExerciseEntry.fetchRequest()
        exerciseRequest.predicate = .forDay()
        exerciseRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]

        // Water entries
        let waterRequest: NSFetchRequest<WaterEntry> = WaterEntry.fetchRequest()
        waterRequest.predicate = .forDay()
        waterRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]

        // Supplement entries
        let supplementRequest: NSFetchRequest<SupplementEntry> = SupplementEntry.fetchRequest()
        supplementRequest.predicate = .forDay()
        supplementRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]

        // Weight entries (fetch all, not just today)
        let weightRequest: NSFetchRequest<WeightEntry> = WeightEntry.fetchRequest()
        weightRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        weightRequest.fetchLimit = 2  // Get latest 2 for comparison

        do {
            // Fetch all data
            todaysFoodEntries = try context.fetch(foodRequest)
            todaysExerciseEntries = try context.fetch(exerciseRequest)
            todaysWaterEntries = try context.fetch(waterRequest)
            todaysSupplementEntries = try context.fetch(supplementRequest)

            // Fetch weight entries
            let weightEntries = try context.fetch(weightRequest)
            if !weightEntries.isEmpty {
                latestWeightEntry = weightEntries.first
                currentWeight = weightEntries.first?.weight ?? 0

                // Calculate weight change if we have 2 entries
                if weightEntries.count > 1 {
                    weightChange = currentWeight - weightEntries[1].weight
                }
            }

            // Calculate summaries
            calculateDailySummaries()

            // Fetch steps from HealthKit
            HealthKitManager.shared.fetchSteps(from: today, to: Date()) { [weak self] steps in
                DispatchQueue.main.async {
                    self?.todaySteps = Int(steps)
                }
            }
        } catch {
            print("Error refreshing data: \(error)")
        }
    }

    private func calculateDailySummaries() {
        // Food totals
        todayCalories = todaysFoodEntries.reduce(0) { $0 + $1.calories }
        todayProtein = todaysFoodEntries.reduce(0) { $0 + $1.protein }
        todayCarbs = todaysFoodEntries.reduce(0) { $0 + $1.carbs }
        todayFat = todaysFoodEntries.reduce(0) { $0 + $1.fat }

        // Exercise totals
        todayCaloriesBurned = todaysExerciseEntries.reduce(0) { $0 + $1.caloriesBurned }

        // Water total (convert ml to oz if needed)
        todayWater = todaysWaterEntries.reduce(0) { sum, entry in
            let amount = entry.unit == "ml" ? entry.amount / 29.5735 : entry.amount
            return sum + amount
        }
    }

    // MARK: - Search Functions

    /// Search the food database by query. Delegates orchestration and deduplication
    /// to `FoodSearchService`; CoreData-backed data (recent foods, cached USDA foods)
    /// is fetched here and passed in so `FoodSearchService` can remain stateless.
    func searchFoodDatabase(_ query: String) -> [FoodItem] {
        guard !query.isEmpty else { return [] }
        return FoodSearchService.search(
            query,
            recentFoods: getRecentFoods(),
            cachedFoods: searchCachedFoods(query)
        )
    }

    /// Cache a USDA API food result into CoreData for offline access.
    func cacheFoodItem(_ food: FoodItem) {
        // Check if already cached
        let request: NSFetchRequest<CustomFood> = CustomFood.fetchRequest()
        request.predicate = NSPredicate(format: "name ==[cd] %@ AND brand ==[cd] %@",
                                        food.name, food.brand ?? "")
        request.fetchLimit = 1

        if let existing = try? context.fetch(request), !existing.isEmpty {
            return // Already cached
        }

        let cached = CustomFood(context: context)
        cached.id = UUID()
        cached.name = food.name
        cached.brand = food.brand
        cached.category = food.category.rawValue
        cached.servingSize = food.servingSize
        cached.servingUnit = food.servingUnit
        cached.calories = food.calories
        cached.protein = food.protein
        cached.carbs = food.carbs
        cached.fat = food.fat
        cached.fiber = food.fiber
        cached.sugar = food.sugar ?? 0
        cached.sodium = food.sodium ?? 0
        cached.cholesterol = food.cholesterol ?? 0
        cached.saturatedFat = food.saturatedFat ?? 0
        cached.barcode = food.barcode
        cached.source = "usda_api"
        cached.isUserCreated = false
        cached.createdDate = Date()

        do {
            try context.save()
        } catch {
            print("Error caching food item: \(error)")
        }
    }

    /// Search cached USDA API foods in CoreData.
    func searchCachedFoods(_ query: String) -> [FoodItem] {
        let request: NSFetchRequest<CustomFood> = CustomFood.fetchRequest()
        request.predicate = NSPredicate(
            format: "(name CONTAINS[cd] %@ OR brand CONTAINS[cd] %@) AND source == %@",
            query, query, "usda_api"
        )
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        request.fetchLimit = 15

        guard let results = try? context.fetch(request) else { return [] }

        return results.compactMap { cached -> FoodItem? in
            guard let name = cached.name else { return nil }
            let category = FoodCategory(rawValue: cached.category ?? "") ?? .other
            return FoodItem(
                name: name,
                brand: cached.brand,
                category: category,
                servingSize: cached.servingSize ?? "1",
                servingUnit: cached.servingUnit ?? "serving",
                calories: cached.calories,
                protein: cached.protein,
                carbs: cached.carbs,
                fat: cached.fat,
                fiber: cached.fiber,
                sugar: cached.sugar,
                sodium: cached.sodium,
                cholesterol: cached.cholesterol,
                saturatedFat: cached.saturatedFat,
                barcode: cached.barcode,
                isCommon: false
            )
        }
    }

    func getRecentFoods() -> [FoodItem] {
        let request: NSFetchRequest<FoodEntry> = FoodEntry.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        request.fetchLimit = 50

        guard let entries = try? context.fetch(request) else { return [] }

        var uniqueFoods: [FoodItem] = []
        var seenNames = Set<String>()

        for entry in entries {
            let key = "\(entry.name ?? "")-\(entry.brand ?? "")"
            if !seenNames.contains(key) {
                seenNames.insert(key)

                let foodItem = FoodItem(
                    name: entry.name ?? "",
                    brand: entry.brand,
                    category: .other,
                    servingSize: entry.servingSize ?? "1",
                    servingUnit: entry.servingUnit ?? "serving",
                    calories: entry.calories,
                    protein: entry.protein,
                    carbs: entry.carbs,
                    fat: entry.fat,
                    fiber: entry.fiber,
                    sugar: entry.sugar,
                    sodium: entry.sodium,
                    cholesterol: nil,
                    saturatedFat: nil,
                    barcode: entry.barcode,
                    isCommon: true
                )
                uniqueFoods.append(foodItem)

                if uniqueFoods.count >= 15 { break }
            }
        }

        return uniqueFoods
    }

    // MARK: - Meal Type Functions

    func getFoodEntries(for mealType: MealType) -> [FoodEntry] {
        return todaysFoodEntries.filter { $0.mealType == mealType.rawValue }
    }

    func getMealCalories(for mealType: MealType) -> Double {
        return getFoodEntries(for: mealType).reduce(0) { $0 + $1.calories }
    }

    // MARK: - Core Data

    private func saveContext() {
        do {
            try context.save()
            refreshAllData() // Refresh after save
        } catch {
            print("Error saving context: \(error)")
        }
    }

    // MARK: - Quick Add Methods

    func quickAddWater(_ ounces: Double) {
        addWaterEntry(amount: ounces, unit: "oz")
    }

    func quickAddExercise(name: String, minutes: Int, calories: Double) {
        addExerciseEntry(
            name: name,
            category: "Cardio",
            duration: minutes,
            caloriesBurned: calories
        )
    }

    func quickAddFood(name: String, calories: Double, mealType: MealType) {
        addFoodEntry(
            name: name,
            calories: calories,
            protein: 0,
            carbs: 0,
            fat: 0,
            mealType: mealType
        )
    }

    // MARK: - Copy from Previous Day

    func fetchFoodEntries(for date: Date, mealType: MealType? = nil) -> [FoodEntry] {
        let request: NSFetchRequest<FoodEntry> = FoodEntry.fetchRequest()
        var predicates: [NSPredicate] = [.forDay(date)]
        if let mealType = mealType {
            predicates.append(NSPredicate(format: "mealType == %@", mealType.rawValue))
        }
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]

        return (try? context.fetch(request)) ?? []
    }

    func fetchSupplementEntries(for date: Date) -> [SupplementEntry] {
        let request: NSFetchRequest<SupplementEntry> = SupplementEntry.fetchRequest()
        request.predicate = .forDay(date)
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]

        return (try? context.fetch(request)) ?? []
    }

    @discardableResult
    func copyFoodEntries(from sourceDate: Date, to targetDate: Date, mealTypes: [MealType]) -> Int {
        var count = 0
        for mealType in mealTypes {
            let entries = fetchFoodEntries(for: sourceDate, mealType: mealType)
            for entry in entries {
                addFoodEntry(
                    name: entry.name ?? "Unknown",
                    brand: entry.brand,
                    calories: entry.calories,
                    protein: entry.protein,
                    carbs: entry.carbs,
                    fat: entry.fat,
                    fiber: entry.fiber,
                    sugar: entry.sugar,
                    sodium: entry.sodium,
                    servingSize: entry.servingSize ?? "1",
                    servingUnit: entry.servingUnit ?? "serving",
                    mealType: mealType,
                    barcode: entry.barcode,
                    date: targetDate
                )
                count += 1
            }
        }
        return count
    }

    @discardableResult
    func copySupplementEntries(from sourceDate: Date, to targetDate: Date) -> Int {
        let entries = fetchSupplementEntries(for: sourceDate)
        var count = 0
        for entry in entries {
            addSupplementEntry(
                name: entry.name ?? "Unknown",
                brand: entry.brand,
                servingSize: entry.servingSize ?? "1",
                servingUnit: entry.servingUnit ?? "serving",
                nutrients: entry.nutrients ?? [:],
                date: targetDate
            )
            count += 1
        }
        return count
    }
}