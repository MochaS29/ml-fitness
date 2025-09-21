import Foundation
import UserNotifications

enum FastingPlan: String, CaseIterable, Codable {
    case sixteenEight = "16:8"
    case eighteenSix = "18:6"
    case twentyFour = "24 Hour"
    case fiveTwo = "5:2"
    case omad = "OMAD"
    case custom = "Custom"
    
    var displayName: String {
        switch self {
        case .sixteenEight:
            return "16:8 (16 hours fasting, 8 hours eating)"
        case .eighteenSix:
            return "18:6 (18 hours fasting, 6 hours eating)"
        case .twentyFour:
            return "24 Hour (Eat-Stop-Eat)"
        case .fiveTwo:
            return "5:2 (5 days normal, 2 days restricted)"
        case .omad:
            return "OMAD (One Meal A Day)"
        case .custom:
            return "Custom Schedule"
        }
    }
    
    var fastingHours: Int {
        switch self {
        case .sixteenEight:
            return 16
        case .eighteenSix:
            return 18
        case .twentyFour:
            return 24
        case .fiveTwo:
            return 0 // Special case - weekly schedule
        case .omad:
            return 23
        case .custom:
            return 16 // Default for custom
        }
    }
    
    var eatingWindowHours: Int {
        switch self {
        case .sixteenEight:
            return 8
        case .eighteenSix:
            return 6
        case .twentyFour:
            return 0
        case .fiveTwo:
            return 24 // Normal eating days
        case .omad:
            return 1
        case .custom:
            return 8 // Default for custom
        }
    }
    
    var description: String {
        switch self {
        case .sixteenEight:
            return "The most popular intermittent fasting method. Fast for 16 hours and eat within an 8-hour window."
        case .eighteenSix:
            return "A slightly more intensive version with 18 hours of fasting and a 6-hour eating window."
        case .twentyFour:
            return "Fast for a full 24 hours once or twice per week. Also known as Eat-Stop-Eat."
        case .fiveTwo:
            return "Eat normally for 5 days and restrict calories (500-600) for 2 non-consecutive days."
        case .omad:
            return "Eat one meal per day within a 1-hour window. Fast for the remaining 23 hours."
        case .custom:
            return "Create your own fasting schedule that fits your lifestyle."
        }
    }
}

struct FastingSession: Codable, Identifiable, Equatable {
    let id: UUID
    var startTime: Date
    var plannedDuration: TimeInterval
    var actualEndTime: Date?
    var fastingPlan: FastingPlan
    var notes: String?
    
    init(id: UUID = UUID(), startTime: Date, plannedDuration: TimeInterval, actualEndTime: Date? = nil, fastingPlan: FastingPlan, notes: String? = nil) {
        self.id = id
        self.startTime = startTime
        self.plannedDuration = plannedDuration
        self.actualEndTime = actualEndTime
        self.fastingPlan = fastingPlan
        self.notes = notes
    }
    
    var isActive: Bool {
        actualEndTime == nil && startTime.timeIntervalSinceNow < 0
    }
    
    var isCompleted: Bool {
        actualEndTime != nil
    }
    
    var currentDuration: TimeInterval {
        if let endTime = actualEndTime {
            return endTime.timeIntervalSince(startTime)
        } else if isActive {
            return Date().timeIntervalSince(startTime)
        } else {
            return 0
        }
    }
    
    var progress: Double {
        guard plannedDuration > 0 else { return 0 }
        return min(currentDuration / plannedDuration, 1.0)
    }
    
    var timeRemaining: TimeInterval {
        max(0, plannedDuration - currentDuration)
    }
    
    var plannedEndTime: Date {
        startTime.addingTimeInterval(plannedDuration)
    }
}

class FastingManager: ObservableObject {
    @Published var currentSession: FastingSession?
    @Published var sessionHistory: [FastingSession] = []
    @Published var selectedPlan: FastingPlan = .sixteenEight
    @Published var customFastingHours: Int = 16
    @Published var customEatingHours: Int = 8
    
    private let userDefaults = UserDefaults.standard
    private let currentSessionKey = "currentFastingSession"
    private let sessionHistoryKey = "fastingSessionHistory"
    private let selectedPlanKey = "selectedFastingPlan"
    
    init() {
        loadData()
    }
    
    func startFasting(plan: FastingPlan? = nil) {
        let fastingPlan = plan ?? selectedPlan
        let duration: TimeInterval
        
        switch fastingPlan {
        case .custom:
            duration = TimeInterval(customFastingHours * 3600)
        default:
            duration = TimeInterval(fastingPlan.fastingHours * 3600)
        }
        
        currentSession = FastingSession(
            startTime: Date(),
            plannedDuration: duration,
            actualEndTime: nil,
            fastingPlan: fastingPlan,
            notes: nil
        )
        
        saveData()
        scheduleNotification()
    }
    
    func endFasting() {
        guard var session = currentSession else { return }
        session.actualEndTime = Date()
        sessionHistory.insert(session, at: 0)
        currentSession = nil
        
        saveData()
        cancelNotifications()
        
        // Check for achievements
        checkFastingAchievements(session)
    }
    
    func cancelFasting() {
        currentSession = nil
        saveData()
        cancelNotifications()
    }
    
    private func checkFastingAchievements(_ session: FastingSession) {
        let achievementManager = AchievementManager.shared
        
        // Check if fast was completed successfully
        if session.currentDuration >= session.plannedDuration {
            // First successful fast
            if sessionHistory.count == 1 {
                let achievement = Achievement(
                    type: .other,
                    title: "First Fast Complete! 🎉",
                    description: "You completed your first intermittent fast!",
                    dateEarned: Date(),
                    value: 1.0,
                    target: nil
                )
                achievementManager.celebrate(achievement)
            }
            
            // Weekly streak
            let weeklyFasts = sessionHistory.filter { session in
                session.isCompleted &&
                session.startTime > Date().addingTimeInterval(-7 * 24 * 3600)
            }
            
            if weeklyFasts.count >= 3 {
                let achievement = Achievement(
                    type: .streak,
                    title: "Fasting Streak! 🔥",
                    description: "You've completed \(weeklyFasts.count) fasts this week!",
                    dateEarned: Date(),
                    value: Double(weeklyFasts.count),
                    target: nil
                )
                achievementManager.celebrate(achievement)
            }
        }
    }
    
    private func scheduleNotification() {
        guard let session = currentSession else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Fasting Complete! 🎉"
        content.body = "You've successfully completed your \(session.fastingPlan.rawValue) fast. Time to break your fast mindfully."
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: session.plannedDuration,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "fastingComplete",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func cancelNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["fastingComplete"]
        )
    }
    
    private func saveData() {
        if let session = currentSession,
           let encoded = try? JSONEncoder().encode(session) {
            userDefaults.set(encoded, forKey: currentSessionKey)
        } else {
            userDefaults.removeObject(forKey: currentSessionKey)
        }
        
        if let encoded = try? JSONEncoder().encode(sessionHistory) {
            userDefaults.set(encoded, forKey: sessionHistoryKey)
        }
        
        userDefaults.set(selectedPlan.rawValue, forKey: selectedPlanKey)
    }
    
    private func loadData() {
        if let data = userDefaults.data(forKey: currentSessionKey),
           let session = try? JSONDecoder().decode(FastingSession.self, from: data) {
            currentSession = session
        }
        
        if let data = userDefaults.data(forKey: sessionHistoryKey),
           let history = try? JSONDecoder().decode([FastingSession].self, from: data) {
            sessionHistory = history
        }
        
        if let planRaw = userDefaults.string(forKey: selectedPlanKey),
           let plan = FastingPlan(rawValue: planRaw) {
            selectedPlan = plan
        }
    }
}