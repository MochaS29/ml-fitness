import Foundation
import SwiftUI
import CoreData

class GoalsManager: ObservableObject {
    static let shared = GoalsManager()
    
    @Published var goals: [Goal] = []
    @Published var activeGoals: [Goal] = []
    @Published var completedGoals: [Goal] = []
    
    private let goalsKey = "userGoals"
    private let userDefaults = UserDefaults.standard
    
    init() {
        loadGoals()
    }
    
    // MARK: - Goal Management
    
    func addGoal(_ goal: Goal) {
        goals.append(goal)
        
        // Set up reminder if enabled
        if goal.reminderEnabled, let reminderTime = goal.reminderTime {
            scheduleGoalReminder(for: goal, at: reminderTime)
        }
        
        // Add default milestones
        var updatedGoal = goal
        updatedGoal.milestones = [
            GoalMilestone(percentage: 25, reward: "Great start! 🌟"),
            GoalMilestone(percentage: 50, reward: "Halfway there! 💪"),
            GoalMilestone(percentage: 75, reward: "Almost done! 🔥"),
            GoalMilestone(percentage: 100, reward: "Goal achieved! 🎉")
        ]
        
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index] = updatedGoal
        }
        
        saveGoals()
        categorizeGoals()
    }
    
    func updateGoal(_ goal: Goal) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index] = goal
            
            // Check for milestone achievements
            checkMilestones(for: goal)
            
            // Check if goal is completed
            if goal.progress >= 1.0 && !goal.isCompleted {
                completeGoal(goal)
            }
            
            saveGoals()
            categorizeGoals()
        }
    }
    
    func deleteGoal(_ goal: Goal) {
        goals.removeAll { $0.id == goal.id }
        
        // Cancel reminder if exists
        if goal.reminderEnabled {
            NotificationService.shared.cancelNotification(identifier: "goal_\(goal.id.uuidString)")
        }
        
        saveGoals()
        categorizeGoals()
    }
    
    func completeGoal(_ goal: Goal) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index].isCompleted = true
            goals[index].completedDate = Date()
            goals[index].isActive = false
            
            // Add achievement
            let achievement = Achievement(
                type: .goalReached,
                title: "Goal Achieved! 🎯",
                description: goal.title,
                dateEarned: Date(),
                value: Double(goal.progress),
                target: Double(goal.targetValue)
            )
            AchievementManager.shared.celebrate(achievement)
            
            saveGoals()
            categorizeGoals()
        }
    }
    
    func toggleGoalActive(_ goal: Goal) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index].isActive.toggle()
            saveGoals()
            categorizeGoals()
        }
    }
    
    // MARK: - Progress Updates
    
    func updateProgress(for goalId: UUID, newValue: Double) {
        if let index = goals.firstIndex(where: { $0.id == goalId }) {
            goals[index].currentValue = newValue
            
            // Check milestones
            checkMilestones(for: goals[index])
            
            // Check completion
            if goals[index].progress >= 1.0 && !goals[index].isCompleted {
                completeGoal(goals[index])
            }
            
            saveGoals()
        }
    }
    
    func incrementProgress(for goalId: UUID, by amount: Double) {
        if let index = goals.firstIndex(where: { $0.id == goalId }) {
            goals[index].currentValue += amount
            updateGoal(goals[index])
        }
    }
    
    // MARK: - Automated Progress Updates
    
    func updateGoalsFromFoodEntry(_ entry: FoodEntry) {
        let calendar = Calendar.current
        let today = Date()
        
        // Update calorie goals
        let calorieGoals = activeGoals.filter { $0.category == .nutrition && $0.title.lowercased().contains("calorie") }
        for goal in calorieGoals {
            if goal.frequency == .daily && calendar.isDateInToday(entry.timestamp ?? today) {
                incrementProgress(for: goal.id, by: entry.calories)
            }
        }
        
        // Update protein goals
        let proteinGoals = activeGoals.filter { $0.category == .nutrition && $0.title.lowercased().contains("protein") }
        for goal in proteinGoals {
            if goal.frequency == .daily && calendar.isDateInToday(entry.timestamp ?? today) {
                incrementProgress(for: goal.id, by: entry.protein)
            }
        }
        
        // Update sugar goals - commented out as FoodEntry doesn't have sugar property yet
        // let sugarGoals = activeGoals.filter { $0.category == .nutrition && $0.title.lowercased().contains("sugar") }
        // for goal in sugarGoals {
        //     if goal.frequency == .daily && calendar.isDateInToday(entry.date ?? today) {
        //         incrementProgress(for: goal.id, by: entry.sugar)
        //     }
        // }
    }
    
    func updateGoalsFromExerciseEntry(_ entry: ExerciseEntry) {
        let calendar = Calendar.current
        let today = Date()
        
        // Update exercise calorie goals
        let calorieGoals = activeGoals.filter { $0.category == .exercise && $0.title.lowercased().contains("calorie") }
        for goal in calorieGoals {
            if goal.frequency == .daily && calendar.isDateInToday(entry.timestamp ?? today) {
                incrementProgress(for: goal.id, by: entry.caloriesBurned)
            }
        }
        
        // Update workout count goals
        let workoutGoals = activeGoals.filter { $0.category == .exercise && $0.title.lowercased().contains("workout") }
        for goal in workoutGoals {
            if goal.frequency == .weekly {
                incrementProgress(for: goal.id, by: 1)
            }
        }
    }
    
    func updateGoalsFromWeightEntry(_ entry: WeightEntry) {
        // Update weight-related goals
        let weightGoals = activeGoals.filter { $0.category == .weightLoss || $0.category == .weightGain }
        for goal in weightGoals {
            updateProgress(for: goal.id, newValue: entry.weight)
        }
    }
    
    func updateGoalsFromWaterEntry(_ entry: WaterEntry) {
        let calendar = Calendar.current
        let today = Date()
        
        // Update hydration goals
        let waterGoals = activeGoals.filter { $0.category == .hydration }
        for goal in waterGoals {
            if goal.frequency == .daily && calendar.isDateInToday(entry.timestamp ?? today) {
                let amount = entry.unit == "ml" ? entry.amount / 29.5735 : entry.amount // Convert ml to oz if needed
                incrementProgress(for: goal.id, by: amount)
            }
        }
    }
    
    // MARK: - Milestone Checking
    
    private func checkMilestones(for goal: Goal) {
        guard let index = goals.firstIndex(where: { $0.id == goal.id }) else { return }
        
        let progressPercentage = goal.progressPercentage
        
        for (milestoneIndex, milestone) in goal.milestones.enumerated() {
            if !milestone.isReached && progressPercentage >= milestone.percentage {
                // Mark milestone as reached
                goals[index].milestones[milestoneIndex].isReached = true
                goals[index].milestones[milestoneIndex].reachedDate = Date()
                
                // Show achievement
                if let reward = milestone.reward {
                    let achievement = Achievement(
                        type: .milestone,
                        title: "\(milestone.percentage)% Milestone!",
                        description: "\(goal.title): \(reward)",
                        dateEarned: Date(),
                        value: Double(goal.progress),
                        target: Double(goal.targetValue)
                    )
                    AchievementManager.shared.celebrate(achievement)
                }
            }
        }
    }
    
    // MARK: - Daily Reset
    
    func resetDailyGoals() {
        let today = Date()
        let calendar = Calendar.current
        
        for index in goals.indices {
            if goals[index].frequency == .daily && goals[index].isActive {
                // Check if it's a new day
                if let lastUpdate = goals[index].milestones.last?.reachedDate,
                   !calendar.isDate(lastUpdate, inSameDayAs: today) {
                    goals[index].currentValue = 0
                }
            }
        }
        
        saveGoals()
    }
    
    func resetWeeklyGoals() {
        let calendar = Calendar.current
        let today = Date()
        
        for index in goals.indices {
            if goals[index].frequency == .weekly && goals[index].isActive {
                // Check if it's a new week
                if let lastUpdate = goals[index].milestones.last?.reachedDate,
                   !calendar.isDate(lastUpdate, equalTo: today, toGranularity: .weekOfYear) {
                    goals[index].currentValue = 0
                }
            }
        }
        
        saveGoals()
    }
    
    // MARK: - Reminders
    
    private func scheduleGoalReminder(for goal: Goal, at time: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Goal Reminder 🎯"
        content.body = goal.title
        content.sound = .default
        content.userInfo = ["goalId": goal.id.uuidString]
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "goal_\(goal.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Persistence
    
    private func saveGoals() {
        if let encoded = try? JSONEncoder().encode(goals) {
            userDefaults.set(encoded, forKey: goalsKey)
        }
    }
    
    private func loadGoals() {
        if let data = userDefaults.data(forKey: goalsKey),
           let decoded = try? JSONDecoder().decode([Goal].self, from: data) {
            goals = decoded
            categorizeGoals()
        }
    }
    
    private func categorizeGoals() {
        activeGoals = goals.filter { $0.isActive && !$0.isCompleted }
        completedGoals = goals.filter { $0.isCompleted }
    }
    
    // MARK: - Statistics
    
    func getGoalStatistics() -> GoalStatistics {
        let totalGoals = goals.count
        let activeCount = activeGoals.count
        let completedCount = completedGoals.count
        let overdueCount = activeGoals.filter { $0.isOverdue }.count
        
        let completionRate = totalGoals > 0 ? Double(completedCount) / Double(totalGoals) : 0
        
        var categoryBreakdown: [GoalCategory: Int] = [:]
        for goal in goals {
            categoryBreakdown[goal.category, default: 0] += 1
        }
        
        return GoalStatistics(
            totalGoals: totalGoals,
            activeGoals: activeCount,
            completedGoals: completedCount,
            overdueGoals: overdueCount,
            completionRate: completionRate,
            categoryBreakdown: categoryBreakdown
        )
    }
}

// MARK: - Goal Statistics
struct GoalStatistics {
    let totalGoals: Int
    let activeGoals: Int
    let completedGoals: Int
    let overdueGoals: Int
    let completionRate: Double
    let categoryBreakdown: [GoalCategory: Int]
}

// MARK: - Achievement Types Extension
extension AchievementType {
    static let goalReached = AchievementType(rawValue: "goalReached")!
    static let milestone = AchievementType(rawValue: "milestone")!
}