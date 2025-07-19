import Foundation
import CoreData

class DemoDataGenerator {
    static func generateDemoData(context: NSManagedObjectContext) {
        // Create demo user profile if needed
        createDemoUserProfile()
        
        // Clear existing demo data first
        clearExistingDemoData(context: context)
        
        // Generate data for the past 30 days
        let calendar = Calendar.current
        let today = Date()
        
        // Generate food entries
        generateFoodEntries(context: context, startDate: today)
        
        // Generate exercise entries
        generateExerciseEntries(context: context, startDate: today)
        
        // Generate weight entries
        generateWeightEntries(context: context, startDate: today)
        
        // Generate supplement entries
        generateSupplementEntries(context: context, startDate: today)
        
        // Generate achievements
        generateAchievements()
        
        // Generate meal plans
        generateMealPlans()
        
        // Save all changes
        do {
            try context.save()
            print("Demo data generated successfully!")
        } catch {
            print("Error saving demo data: \(error)")
        }
    }
    
    private static func clearExistingDemoData(context: NSManagedObjectContext) {
        // Clear food entries
        let foodRequest: NSFetchRequest<NSFetchRequestResult> = FoodEntry.fetchRequest()
        let foodDelete = NSBatchDeleteRequest(fetchRequest: foodRequest)
        
        // Clear exercise entries
        let exerciseRequest: NSFetchRequest<NSFetchRequestResult> = ExerciseEntry.fetchRequest()
        let exerciseDelete = NSBatchDeleteRequest(fetchRequest: exerciseRequest)
        
        // Clear weight entries
        let weightRequest: NSFetchRequest<NSFetchRequestResult> = WeightEntry.fetchRequest()
        let weightDelete = NSBatchDeleteRequest(fetchRequest: weightRequest)
        
        // Clear supplement entries
        let supplementRequest: NSFetchRequest<NSFetchRequestResult> = SupplementEntry.fetchRequest()
        let supplementDelete = NSBatchDeleteRequest(fetchRequest: supplementRequest)
        
        do {
            try context.execute(foodDelete)
            try context.execute(exerciseDelete)
            try context.execute(weightDelete)
            try context.execute(supplementDelete)
        } catch {
            print("Error clearing existing data: \(error)")
        }
    }
    
    private static func generateFoodEntries(context: NSManagedObjectContext, startDate: Date) {
        let calendar = Calendar.current
        
        // Sample meals for variety
        let breakfastOptions = [
            ("Oatmeal with Berries", "Quaker", 250.0, 8.0, 45.0, 5.0, 8.0),
            ("Greek Yogurt Parfait", "Chobani", 320.0, 20.0, 35.0, 12.0, 4.0),
            ("Scrambled Eggs with Toast", nil, 380.0, 22.0, 28.0, 18.0, 2.0),
            ("Protein Smoothie", "Homemade", 295.0, 25.0, 40.0, 6.0, 5.0),
            ("Avocado Toast", nil, 340.0, 10.0, 36.0, 18.0, 8.0)
        ]
        
        let lunchOptions = [
            ("Grilled Chicken Salad", "Sweetgreen", 420.0, 35.0, 25.0, 22.0, 6.0),
            ("Turkey Sandwich", "Subway", 380.0, 24.0, 46.0, 12.0, 3.0),
            ("Quinoa Buddha Bowl", nil, 485.0, 18.0, 65.0, 18.0, 12.0),
            ("Salmon with Vegetables", nil, 450.0, 40.0, 20.0, 25.0, 5.0),
            ("Chicken Burrito Bowl", "Chipotle", 680.0, 32.0, 65.0, 32.0, 8.0)
        ]
        
        let dinnerOptions = [
            ("Grilled Salmon with Rice", nil, 520.0, 42.0, 48.0, 18.0, 2.0),
            ("Pasta with Chicken", "Homemade", 580.0, 38.0, 62.0, 20.0, 4.0),
            ("Steak with Sweet Potato", nil, 650.0, 45.0, 42.0, 32.0, 6.0),
            ("Vegetarian Curry", "Thai Kitchen", 420.0, 12.0, 58.0, 16.0, 8.0),
            ("Shrimp Stir-fry", nil, 380.0, 28.0, 45.0, 10.0, 6.0)
        ]
        
        let snackOptions = [
            ("Apple with Almond Butter", nil, 200.0, 4.0, 25.0, 10.0, 4.0),
            ("Protein Bar", "RXBAR", 210.0, 12.0, 23.0, 9.0, 3.0),
            ("Mixed Nuts", "Planters", 180.0, 6.0, 8.0, 16.0, 2.0),
            ("Banana", nil, 105.0, 1.3, 27.0, 0.4, 3.1),
            ("Greek Yogurt", "Fage", 130.0, 16.0, 9.0, 4.0, 0.0)
        ]
        
        // Generate entries for past 30 days
        for dayOffset in 0..<30 {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: startDate) else { continue }
            
            // Breakfast
            let breakfast = breakfastOptions.randomElement()!
            createFoodEntry(context: context, date: date, mealType: .breakfast,
                          name: breakfast.0, brand: breakfast.1, calories: breakfast.2,
                          protein: breakfast.3, carbs: breakfast.4, fat: breakfast.5, fiber: breakfast.6)
            
            // Lunch
            let lunch = lunchOptions.randomElement()!
            createFoodEntry(context: context, date: date, mealType: .lunch,
                          name: lunch.0, brand: lunch.1, calories: lunch.2,
                          protein: lunch.3, carbs: lunch.4, fat: lunch.5, fiber: lunch.6)
            
            // Dinner
            let dinner = dinnerOptions.randomElement()!
            createFoodEntry(context: context, date: date, mealType: .dinner,
                          name: dinner.0, brand: dinner.1, calories: dinner.2,
                          protein: dinner.3, carbs: dinner.4, fat: dinner.5, fiber: dinner.6)
            
            // Snacks (1-2 per day)
            let snackCount = Int.random(in: 1...2)
            for _ in 0..<snackCount {
                let snack = snackOptions.randomElement()!
                createFoodEntry(context: context, date: date, mealType: .snack,
                              name: snack.0, brand: snack.1, calories: snack.2,
                              protein: snack.3, carbs: snack.4, fat: snack.5, fiber: snack.6)
            }
        }
    }
    
    private static func createFoodEntry(context: NSManagedObjectContext, date: Date, mealType: MealType,
                                      name: String, brand: String?, calories: Double,
                                      protein: Double, carbs: Double, fat: Double, fiber: Double) {
        let entry = FoodEntry(context: context)
        entry.id = UUID()
        entry.name = name
        entry.brand = brand
        entry.calories = calories
        entry.protein = protein
        entry.carbs = carbs
        entry.fat = fat
        entry.fiber = fiber
        entry.mealType = mealType.rawValue
        entry.timestamp = date
        entry.date = date
        entry.servingSize = "1"
        entry.servingUnit = "serving"
    }
    
    private static func generateExerciseEntries(context: NSManagedObjectContext, startDate: Date) {
        let calendar = Calendar.current
        
        let exercises = [
            ("Morning Run", "Cardio", 30, 280.0),
            ("Weight Training", "Strength", 45, 220.0),
            ("Yoga", "Flexibility", 60, 180.0),
            ("Cycling", "Cardio", 45, 400.0),
            ("Swimming", "Cardio", 30, 350.0),
            ("HIIT Workout", "Cardio", 20, 250.0),
            ("Pilates", "Strength", 40, 200.0),
            ("Walking", "Cardio", 60, 240.0)
        ]
        
        // Generate exercises for past 30 days (4-5 times per week)
        for dayOffset in 0..<30 {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: startDate) else { continue }
            
            // 70% chance of exercise on any given day
            if Double.random(in: 0...1) < 0.7 {
                let exercise = exercises.randomElement()!
                
                let entry = ExerciseEntry(context: context)
                entry.id = UUID()
                entry.name = exercise.0
                entry.category = exercise.1
                entry.type = exercise.1
                entry.duration = Int32(exercise.2)
                entry.caloriesBurned = exercise.3
                entry.timestamp = date
                entry.date = date
                entry.notes = "Felt great!"
            }
        }
    }
    
    private static func generateWeightEntries(context: NSManagedObjectContext, startDate: Date) {
        let calendar = Calendar.current
        let startingWeight = 180.0 // Starting weight in pounds
        let targetWeightLoss = 10.0 // Target loss over 30 days
        
        // Generate weight entries every 2-3 days
        for dayOffset in stride(from: 0, to: 30, by: Int.random(in: 2...3)) {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: startDate) else { continue }
            
            // Simulate gradual weight loss with some fluctuation
            let progress = Double(30 - dayOffset) / 30.0
            let weightLoss = targetWeightLoss * progress
            let fluctuation = Double.random(in: -1.5...1.5)
            let weight = startingWeight - weightLoss + fluctuation
            
            let entry = WeightEntry(context: context)
            entry.id = UUID()
            entry.weight = weight
            entry.timestamp = date
            entry.date = date
            entry.notes = dayOffset == 0 ? "Goal weight reached!" : nil
        }
    }
    
    private static func generateSupplementEntries(context: NSManagedObjectContext, startDate: Date) {
        let calendar = Calendar.current
        
        let supplements = [
            ("Multivitamin", "Centrum", ["Vitamin A": 900.0, "Vitamin C": 90.0, "Vitamin D": 20.0, "Iron": 18.0]),
            ("Omega-3", "Nordic Naturals", ["EPA": 180.0, "DHA": 120.0]),
            ("Vitamin D3", "Nature Made", ["Vitamin D": 50.0]),
            ("Probiotics", "Garden of Life", ["CFU": 50.0]),
            ("Magnesium", "NOW Foods", ["Magnesium": 400.0])
        ]
        
        // Generate daily supplement entries
        for dayOffset in 0..<30 {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: startDate) else { continue }
            
            // Take 2-3 supplements per day
            let supplementCount = Int.random(in: 2...3)
            let selectedSupplements = supplements.shuffled().prefix(supplementCount)
            
            for supplement in selectedSupplements {
                let entry = SupplementEntry(context: context)
                entry.id = UUID()
                entry.name = supplement.0
                entry.brand = supplement.1
                entry.nutrients = supplement.2 as NSObject
                entry.timestamp = date
                entry.date = date
                entry.servingSize = "1"
                entry.servingUnit = "tablet"
            }
        }
    }
    
    private static func generateAchievements() {
        let achievementManager = AchievementManager.shared
        
        // Add some demo achievements
        let achievements = [
            Achievement(
                id: UUID(),
                type: .weightLoss,
                title: "5 lbs Down!",
                description: "You've lost 5 pounds!",
                dateEarned: Date().addingTimeInterval(-7 * 24 * 60 * 60), // 7 days ago
                value: "5 lbs"
            ),
            Achievement(
                id: UUID(),
                type: .exerciseStreak,
                title: "7 Day Streak",
                description: "Exercised for 7 days in a row!",
                dateEarned: Date().addingTimeInterval(-2 * 24 * 60 * 60), // 2 days ago
                value: "7 days"
            ),
            Achievement(
                id: UUID(),
                type: .calorieGoal,
                title: "Calorie Champion",
                description: "Met your calorie goal for 14 days!",
                dateEarned: Date().addingTimeInterval(-1 * 24 * 60 * 60), // Yesterday
                value: "14 days"
            ),
            Achievement(
                id: UUID(),
                type: .waterIntake,
                title: "Hydration Hero",
                description: "Drank 8 glasses of water daily for a week!",
                dateEarned: Date().addingTimeInterval(-3 * 24 * 60 * 60), // 3 days ago
                value: "7 days"
            )
        ]
        
        // Add achievements to the manager
        for achievement in achievements {
            if !achievementManager.recentAchievements.contains(where: { $0.id == achievement.id }) {
                achievementManager.recentAchievements.append(achievement)
            }
        }
        
        // Save to UserDefaults
        achievementManager.saveAchievements()
    }
    
    private static func createDemoUserProfile() {
        let userProfileManager = UserProfileManager()
        
        // Only create if no profile exists
        if userProfileManager.currentProfile == nil {
            let demoProfile = UserProfile(
                name: "Alex Johnson",
                gender: .male,
                birthDate: Calendar.current.date(byAdding: .year, value: -30, to: Date()) ?? Date(),
                activityLevel: .moderate,
                dietaryRestrictions: [.vegetarian],
                healthConditions: [],
                isPregnant: false,
                pregnancyTrimester: nil,
                isBreastfeeding: false
            )
            
            userProfileManager.currentProfile = demoProfile
            userProfileManager.hasCompletedOnboarding = true
        }
    }
    
    private static func generateMealPlans() {
        let userDefaults = UserDefaults.standard
        let calendar = Calendar.current
        let today = Date()
        
        // Create a week of meal plans
        var mealPlans: [[MealPlan]] = []
        
        for dayOffset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: today) else { continue }
            
            var dayPlans: [MealPlan] = []
            
            // Breakfast
            let breakfastRecipes = RecipeDatabase.shared.recipes.filter { $0.category == .breakfast }
            if let breakfast = breakfastRecipes.randomElement() {
                dayPlans.append(MealPlan(
                    id: UUID(),
                    date: date,
                    mealType: .breakfast,
                    recipeId: breakfast.id,
                    recipeName: breakfast.name,
                    servings: 1
                ))
            }
            
            // Lunch
            let lunchRecipes = RecipeDatabase.shared.recipes.filter { $0.category == .lunch }
            if let lunch = lunchRecipes.randomElement() {
                dayPlans.append(MealPlan(
                    id: UUID(),
                    date: date,
                    mealType: .lunch,
                    recipeId: lunch.id,
                    recipeName: lunch.name,
                    servings: 1
                ))
            }
            
            // Dinner
            let dinnerRecipes = RecipeDatabase.shared.recipes.filter { $0.category == .dinner }
            if let dinner = dinnerRecipes.randomElement() {
                dayPlans.append(MealPlan(
                    id: UUID(),
                    date: date,
                    mealType: .dinner,
                    recipeId: dinner.id,
                    recipeName: dinner.name,
                    servings: 2
                ))
            }
            
            mealPlans.append(dayPlans)
        }
        
        // Save meal plans
        if let encoded = try? JSONEncoder().encode(mealPlans.flatMap { $0 }) {
            userDefaults.set(encoded, forKey: "savedMealPlans")
        }
    }
}