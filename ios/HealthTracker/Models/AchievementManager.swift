import SwiftUI
import Combine

enum AchievementType: String, CaseIterable {
    case weightLoss = "Weight Loss"
    case calorieGoal = "Calorie Goal"
    case exerciseStreak = "Exercise Streak"
    case nutritionBalance = "Nutrition Balance"
    case waterIntake = "Water Intake"
    case stepGoal = "Step Goal"
    case supplementConsistency = "Supplement Consistency"
    case streak = "Streak"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .weightLoss: return "scalemass.fill"
        case .calorieGoal: return "flame.fill"
        case .exerciseStreak: return "figure.run"
        case .nutritionBalance: return "leaf.fill"
        case .waterIntake: return "drop.fill"
        case .stepGoal: return "figure.walk"
        case .supplementConsistency: return "pills.fill"
        case .streak: return "flame"
        case .other: return "star.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .weightLoss: return .mindfulTeal
        case .calorieGoal: return .orange
        case .exerciseStreak: return .wellnessGreen
        case .nutritionBalance: return .mochaBrown
        case .waterIntake: return .blue
        case .stepGoal: return .purple
        case .supplementConsistency: return .pink
        case .streak: return .red
        case .other: return .gray
        }
    }
}

struct Achievement: Identifiable {
    let id = UUID()
    let type: AchievementType
    let title: String
    let description: String
    let dateEarned: Date
    let value: String?
}

class AchievementManager: ObservableObject {
    static let shared = AchievementManager()
    
    @Published var recentAchievements: [Achievement] = []
    @Published var showingCelebration = false
    @Published var currentCelebration: Achievement?
    
    private let userDefaults = UserDefaults.standard
    private let healthKitManager = HealthKitManager.shared
    
    // Keys for tracking
    private let lastWeightKey = "lastRecordedWeight"
    private let exerciseStreakKey = "exerciseStreak"
    private let lastExerciseDateKey = "lastExerciseDate"
    private let dailyCalorieGoalKey = "dailyCalorieGoal"
    private let dailyStepGoalKey = "dailyStepGoal"
    
    init() {
        loadAchievements()
    }
    
    // MARK: - Weight Loss Achievements
    
    func checkWeightLoss(newWeight: Double) {
        let lastWeight = userDefaults.double(forKey: lastWeightKey)
        
        if lastWeight > 0 && newWeight < lastWeight {
            let weightLost = lastWeight - newWeight
            
            // Celebrate every pound lost
            if weightLost >= 1 {
                let achievement = Achievement(
                    type: .weightLoss,
                    title: "Weight Loss Milestone! 🎉",
                    description: "You've lost \(String(format: "%.1f", weightLost)) lbs! Keep up the great work!",
                    dateEarned: Date(),
                    value: "\(String(format: "%.1f", weightLost)) lbs"
                )
                celebrate(achievement)
            }
            
            // Special milestones
            if weightLost >= 5 {
                let achievement = Achievement(
                    type: .weightLoss,
                    title: "5 Pounds Down! 🌟",
                    description: "Amazing progress! You've lost 5 pounds!",
                    dateEarned: Date(),
                    value: "5 lbs"
                )
                celebrate(achievement)
            }
        }
        
        userDefaults.set(newWeight, forKey: lastWeightKey)
    }
    
    // MARK: - Exercise Achievements
    
    func checkExerciseCompletion(calories: Double, duration: Int) {
        let today = Calendar.current.startOfDay(for: Date())
        let lastExerciseDate = userDefaults.object(forKey: lastExerciseDateKey) as? Date
        let currentStreak = userDefaults.integer(forKey: exerciseStreakKey)
        
        // Check if this is a new day
        if lastExerciseDate == nil || !Calendar.current.isDate(lastExerciseDate!, inSameDayAs: today) {
            // Update streak
            if let lastDate = lastExerciseDate,
               Calendar.current.dateComponents([.day], from: lastDate, to: today).day == 1 {
                // Consecutive day
                let newStreak = currentStreak + 1
                userDefaults.set(newStreak, forKey: exerciseStreakKey)
                
                // Celebrate streaks
                if newStreak == 3 {
                    let achievement = Achievement(
                        type: .exerciseStreak,
                        title: "3-Day Streak! 🔥",
                        description: "You've exercised for 3 days in a row!",
                        dateEarned: Date(),
                        value: "3 days"
                    )
                    celebrate(achievement)
                } else if newStreak == 7 {
                    let achievement = Achievement(
                        type: .exerciseStreak,
                        title: "Week Warrior! 💪",
                        description: "Incredible! 7 days of consistent exercise!",
                        dateEarned: Date(),
                        value: "7 days"
                    )
                    celebrate(achievement)
                } else if newStreak % 7 == 0 && newStreak > 7 {
                    let weeks = newStreak / 7
                    let achievement = Achievement(
                        type: .exerciseStreak,
                        title: "\(weeks)-Week Streak! 🏆",
                        description: "You've maintained your exercise routine for \(weeks) weeks!",
                        dateEarned: Date(),
                        value: "\(weeks) weeks"
                    )
                    celebrate(achievement)
                }
            } else {
                // Streak broken, start new
                userDefaults.set(1, forKey: exerciseStreakKey)
            }
            
            userDefaults.set(today, forKey: lastExerciseDateKey)
        }
        
        // Celebrate high calorie burns
        if calories >= 500 {
            let achievement = Achievement(
                type: .calorieGoal,
                title: "Calorie Crusher! 🔥",
                description: "You burned \(Int(calories)) calories in one session!",
                dateEarned: Date(),
                value: "\(Int(calories)) cal"
            )
            celebrate(achievement)
        }
    }
    
    // MARK: - Daily Goal Achievements
    
    func checkDailyCalorieGoal(consumed: Double, goal: Double = 2000) {
        let percentage = (consumed / goal) * 100
        
        if percentage >= 90 && percentage <= 110 {
            let achievement = Achievement(
                type: .calorieGoal,
                title: "Perfect Balance! ⚖️",
                description: "You hit your daily calorie target!",
                dateEarned: Date(),
                value: "\(Int(consumed)) cal"
            )
            celebrate(achievement)
        }
    }
    
    func checkNutritionBalance(protein: Double, carbs: Double, fat: Double) {
        let total = protein + carbs + fat
        guard total > 0 else { return }
        
        let proteinPercent = (protein * 4) / (total * 4 + fat * 5) * 100 // Calories from protein
        let carbPercent = (carbs * 4) / (total * 4 + fat * 5) * 100
        let fatPercent = (fat * 9) / (total * 4 + fat * 5) * 100
        
        // Check if macros are balanced (within healthy ranges)
        if proteinPercent >= 20 && proteinPercent <= 35 &&
           carbPercent >= 45 && carbPercent <= 65 &&
           fatPercent >= 20 && fatPercent <= 35 {
            let achievement = Achievement(
                type: .nutritionBalance,
                title: "Perfectly Balanced! 🥗",
                description: "Your macronutrients are in ideal proportions!",
                dateEarned: Date(),
                value: "P:\(Int(proteinPercent))% C:\(Int(carbPercent))% F:\(Int(fatPercent))%"
            )
            celebrate(achievement)
        }
    }
    
    // MARK: - Celebration System
    
    func celebrate(_ achievement: Achievement) {
        DispatchQueue.main.async {
            self.recentAchievements.insert(achievement, at: 0)
            self.currentCelebration = achievement
            self.showingCelebration = true
            
            // Save achievement
            self.saveAchievement(achievement)
            
            // Play haptic feedback
            self.playHapticFeedback()
        }
    }
    
    private func playHapticFeedback() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    // MARK: - Persistence
    
    private func saveAchievement(_ achievement: Achievement) {
        var savedAchievements = getSavedAchievements()
        savedAchievements.append(achievement)
        
        if let encoded = try? JSONEncoder().encode(savedAchievements) {
            userDefaults.set(encoded, forKey: "savedAchievements")
        }
    }
    
    private func getSavedAchievements() -> [Achievement] {
        guard let data = userDefaults.data(forKey: "savedAchievements"),
              let achievements = try? JSONDecoder().decode([Achievement].self, from: data) else {
            return []
        }
        return achievements
    }
    
    private func loadAchievements() {
        recentAchievements = getSavedAchievements().sorted { $0.dateEarned > $1.dateEarned }
    }
}

// Make Achievement Codable for persistence
extension Achievement: Codable {
    enum CodingKeys: String, CodingKey {
        case type, title, description, dateEarned, value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let typeString = try container.decode(String.self, forKey: .type)
        self.type = AchievementType(rawValue: typeString) ?? .calorieGoal
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decode(String.self, forKey: .description)
        self.dateEarned = try container.decode(Date.self, forKey: .dateEarned)
        self.value = try container.decodeIfPresent(String.self, forKey: .value)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type.rawValue, forKey: .type)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(dateEarned, forKey: .dateEarned)
        try container.encodeIfPresent(value, forKey: .value)
    }
}