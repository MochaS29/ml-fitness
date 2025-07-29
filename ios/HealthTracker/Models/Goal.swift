import Foundation
import SwiftUI

// MARK: - Goal Model
struct Goal: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var category: GoalCategory
    var targetType: GoalTargetType
    var targetValue: Double
    var targetUnit: String
    var currentValue: Double
    var startDate: Date
    var targetDate: Date
    var frequency: GoalFrequency
    var isActive: Bool
    var isCompleted: Bool
    var completedDate: Date?
    var milestones: [GoalMilestone]
    var reminderEnabled: Bool
    var reminderTime: Date?
    var notes: String?
    
    init(title: String, description: String, category: GoalCategory, targetType: GoalTargetType, targetValue: Double, targetUnit: String, targetDate: Date, frequency: GoalFrequency = .daily) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.category = category
        self.targetType = targetType
        self.targetValue = targetValue
        self.targetUnit = targetUnit
        self.currentValue = 0
        self.startDate = Date()
        self.targetDate = targetDate
        self.frequency = frequency
        self.isActive = true
        self.isCompleted = false
        self.completedDate = nil
        self.milestones = []
        self.reminderEnabled = false
        self.reminderTime = nil
        self.notes = nil
    }
    
    // Progress calculation
    var progress: Double {
        guard targetValue > 0 else { return 0 }
        
        switch targetType {
        case .reachTarget:
            return min(currentValue / targetValue, 1.0)
        case .stayBelow:
            return max(0, min((targetValue - currentValue) / targetValue, 1.0))
        case .stayAbove:
            return currentValue >= targetValue ? 1.0 : (currentValue / targetValue)
        case .maintainRange:
            // For range goals, we need both min and max values
            // This is simplified for now
            return abs(currentValue - targetValue) <= (targetValue * 0.05) ? 1.0 : 0.5
        }
    }
    
    var progressPercentage: Int {
        Int(progress * 100)
    }
    
    var daysRemaining: Int {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: Date(), to: targetDate).day ?? 0
        return max(0, days)
    }
    
    var isOverdue: Bool {
        return Date() > targetDate && !isCompleted
    }
    
    var statusColor: Color {
        if isCompleted {
            return .green
        } else if isOverdue {
            return .red
        } else if progress >= 0.7 {
            return .yellow
        } else {
            return .blue
        }
    }
}

// MARK: - Goal Categories
enum GoalCategory: String, Codable, CaseIterable {
    case weightLoss = "Weight Loss"
    case weightGain = "Weight Gain"
    case nutrition = "Nutrition"
    case exercise = "Exercise"
    case hydration = "Hydration"
    case sleep = "Sleep"
    case mindfulness = "Mindfulness"
    case custom = "Custom"
    
    var icon: String {
        switch self {
        case .weightLoss: return "arrow.down.circle"
        case .weightGain: return "arrow.up.circle"
        case .nutrition: return "fork.knife"
        case .exercise: return "figure.run"
        case .hydration: return "drop.fill"
        case .sleep: return "bed.double.fill"
        case .mindfulness: return "brain.head.profile"
        case .custom: return "star.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .weightLoss: return .blue
        case .weightGain: return .purple
        case .nutrition: return .green
        case .exercise: return .orange
        case .hydration: return .cyan
        case .sleep: return .indigo
        case .mindfulness: return .pink
        case .custom: return .yellow
        }
    }
}

// MARK: - Goal Target Types
enum GoalTargetType: String, Codable, CaseIterable {
    case reachTarget = "Reach Target"
    case stayBelow = "Stay Below"
    case stayAbove = "Stay Above"
    case maintainRange = "Maintain Range"
    
    var description: String {
        switch self {
        case .reachTarget: return "Reach a specific target value"
        case .stayBelow: return "Stay below a maximum value"
        case .stayAbove: return "Stay above a minimum value"
        case .maintainRange: return "Maintain within a range"
        }
    }
}

// MARK: - Goal Frequency
enum GoalFrequency: String, Codable, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case total = "Total"
    
    var trackingPeriod: String {
        switch self {
        case .daily: return "per day"
        case .weekly: return "per week"
        case .monthly: return "per month"
        case .total: return "total"
        }
    }
}

// MARK: - Goal Milestone
struct GoalMilestone: Identifiable, Codable {
    let id: UUID
    var percentage: Int // 25%, 50%, 75%
    var isReached: Bool
    var reachedDate: Date?
    var reward: String?
    
    init(percentage: Int, reward: String? = nil) {
        self.id = UUID()
        self.percentage = percentage
        self.isReached = false
        self.reachedDate = nil
        self.reward = reward
    }
}

// MARK: - Goal Templates
struct GoalTemplate {
    let title: String
    let description: String
    let category: GoalCategory
    let targetType: GoalTargetType
    let suggestedTarget: Double
    let unit: String
    let frequency: GoalFrequency
    let duration: Int // days
    
    static let templates: [GoalTemplate] = [
        // Weight Loss
        GoalTemplate(
            title: "Lose 10 Pounds",
            description: "Achieve a healthy weight loss of 10 pounds",
            category: .weightLoss,
            targetType: .reachTarget,
            suggestedTarget: 10,
            unit: "lbs",
            frequency: .total,
            duration: 60
        ),
        GoalTemplate(
            title: "Lose 1-2 Pounds per Week",
            description: "Maintain a steady, healthy weight loss pace",
            category: .weightLoss,
            targetType: .reachTarget,
            suggestedTarget: 1.5,
            unit: "lbs",
            frequency: .weekly,
            duration: 90
        ),
        
        // Nutrition
        GoalTemplate(
            title: "Daily Calorie Goal",
            description: "Stay within your daily calorie target",
            category: .nutrition,
            targetType: .stayBelow,
            suggestedTarget: 2000,
            unit: "calories",
            frequency: .daily,
            duration: 30
        ),
        GoalTemplate(
            title: "Protein Intake",
            description: "Meet your daily protein requirements",
            category: .nutrition,
            targetType: .reachTarget,
            suggestedTarget: 50,
            unit: "grams",
            frequency: .daily,
            duration: 30
        ),
        GoalTemplate(
            title: "Reduce Sugar",
            description: "Limit daily sugar intake",
            category: .nutrition,
            targetType: .stayBelow,
            suggestedTarget: 25,
            unit: "grams",
            frequency: .daily,
            duration: 30
        ),
        
        // Exercise
        GoalTemplate(
            title: "Daily Steps",
            description: "Walk 10,000 steps every day",
            category: .exercise,
            targetType: .reachTarget,
            suggestedTarget: 10000,
            unit: "steps",
            frequency: .daily,
            duration: 30
        ),
        GoalTemplate(
            title: "Weekly Workouts",
            description: "Exercise 4 times per week",
            category: .exercise,
            targetType: .reachTarget,
            suggestedTarget: 4,
            unit: "workouts",
            frequency: .weekly,
            duration: 90
        ),
        GoalTemplate(
            title: "Burn Calories",
            description: "Burn 500 calories through exercise daily",
            category: .exercise,
            targetType: .reachTarget,
            suggestedTarget: 500,
            unit: "calories",
            frequency: .daily,
            duration: 30
        ),
        
        // Hydration
        GoalTemplate(
            title: "Daily Water Intake",
            description: "Drink 8 glasses of water daily",
            category: .hydration,
            targetType: .reachTarget,
            suggestedTarget: 64,
            unit: "oz",
            frequency: .daily,
            duration: 30
        ),
        
        // Sleep
        GoalTemplate(
            title: "Sleep 8 Hours",
            description: "Get a full night's rest every night",
            category: .sleep,
            targetType: .reachTarget,
            suggestedTarget: 8,
            unit: "hours",
            frequency: .daily,
            duration: 30
        ),
        
        // Mindfulness
        GoalTemplate(
            title: "Daily Meditation",
            description: "Practice meditation for 10 minutes daily",
            category: .mindfulness,
            targetType: .reachTarget,
            suggestedTarget: 10,
            unit: "minutes",
            frequency: .daily,
            duration: 30
        )
    ]
}

// MARK: - Goal Suggestions based on User Data
extension Goal {
    static func generateSuggestions(for profile: UserProfile?, recentData: HealthData?) -> [GoalTemplate] {
        var suggestions = GoalTemplate.templates
        
        // Customize suggestions based on user profile and recent data
        if let profile = profile {
            // Add personalized suggestions based on activity level, age, etc.
            if profile.activityLevel == .sedentary {
                suggestions.insert(
                    GoalTemplate(
                        title: "Start Moving",
                        description: "Begin with 5,000 steps daily",
                        category: .exercise,
                        targetType: .reachTarget,
                        suggestedTarget: 5000,
                        unit: "steps",
                        frequency: .daily,
                        duration: 30
                    ),
                    at: 0
                )
            }
        }
        
        return suggestions
    }
}

// Helper struct for recent health data
struct HealthData {
    var averageCalories: Double?
    var averageSteps: Double?
    var currentWeight: Double?
    var averageWaterIntake: Double?
}