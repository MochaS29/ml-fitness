import Foundation
import UserNotifications
import CoreData

class NotificationService: NSObject, ObservableObject {
    static let shared = NotificationService()
    
    @Published var isNotificationEnabled = false
    @Published var pendingNotifications: [PendingNotification] = []
    
    private override init() {
        super.init()
        checkNotificationStatus()
        loadPendingNotifications()
    }
    
    // MARK: - Permission Management
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.isNotificationEnabled = granted
                if granted {
                    self.registerNotificationCategories()
                }
            }
        }
    }
    
    func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isNotificationEnabled = settings.authorizationStatus == .authorized
            }
        }
    }
    
    // MARK: - Notification Categories
    
    private func registerNotificationCategories() {
        let categories: [UNNotificationCategory] = [
            // Meal reminder category
            UNNotificationCategory(
                identifier: "MEAL_REMINDER",
                actions: [
                    UNNotificationAction(identifier: "LOG_MEAL", title: "Log Meal", options: .foreground),
                    UNNotificationAction(identifier: "SNOOZE_15", title: "15 min", options: [])
                ],
                intentIdentifiers: []
            ),
            
            // Water reminder category
            UNNotificationCategory(
                identifier: "WATER_REMINDER",
                actions: [
                    UNNotificationAction(identifier: "LOG_WATER", title: "Log Water", options: .foreground),
                    UNNotificationAction(identifier: "SNOOZE_30", title: "30 min", options: [])
                ],
                intentIdentifiers: []
            ),
            
            // Exercise reminder category
            UNNotificationCategory(
                identifier: "EXERCISE_REMINDER",
                actions: [
                    UNNotificationAction(identifier: "START_WORKOUT", title: "Start", options: .foreground),
                    UNNotificationAction(identifier: "SNOOZE_60", title: "1 hour", options: [])
                ],
                intentIdentifiers: []
            )
        ]
        
        UNUserNotificationCenter.current().setNotificationCategories(Set(categories))
    }
    
    // MARK: - Schedule Notifications
    
    func scheduleMealReminder(mealType: MealType, time: Date, repeatDaily: Bool = true) -> String {
        let content = UNMutableNotificationContent()
        content.title = "\(mealType.rawValue) Time!"
        content.body = "Don't forget to log your \(mealType.rawValue.lowercased())"
        content.sound = .default
        content.categoryIdentifier = "MEAL_REMINDER"
        content.userInfo = ["type": "meal", "mealType": mealType.rawValue]
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: repeatDaily)
        
        let identifier = "meal_\(mealType.rawValue.lowercased())_\(UUID().uuidString)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling meal reminder: \(error)")
            } else {
                self.savePendingNotification(
                    id: identifier,
                    type: .meal,
                    title: content.title,
                    time: time,
                    repeatDaily: repeatDaily,
                    metadata: ["mealType": mealType.rawValue]
                )
            }
        }
        
        return identifier
    }
    
    func scheduleWaterReminder(interval: TimeInterval, startTime: Date, endTime: Date) -> String {
        let content = UNMutableNotificationContent()
        content.title = "Stay Hydrated! 💧"
        content.body = "Time to drink some water"
        content.sound = .default
        content.categoryIdentifier = "WATER_REMINDER"
        content.userInfo = ["type": "water"]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: true)
        
        let identifier = "water_\(UUID().uuidString)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling water reminder: \(error)")
            } else {
                self.savePendingNotification(
                    id: identifier,
                    type: .water,
                    title: content.title,
                    time: Date(),
                    repeatDaily: true,
                    metadata: ["interval": interval, "startTime": startTime, "endTime": endTime]
                )
            }
        }
        
        return identifier
    }
    
    func scheduleExerciseReminder(time: Date, days: [Int], exerciseName: String? = nil) -> String {
        let content = UNMutableNotificationContent()
        content.title = "Time to Exercise! 💪"
        content.body = exerciseName ?? "Ready for your workout?"
        content.sound = .default
        content.categoryIdentifier = "EXERCISE_REMINDER"
        content.userInfo = ["type": "exercise", "exerciseName": exerciseName ?? ""]
        
        let identifier = "exercise_\(UUID().uuidString)"
        
        // Schedule for each selected day
        for day in days {
            var components = Calendar.current.dateComponents([.hour, .minute], from: time)
            components.weekday = day
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let dayIdentifier = "\(identifier)_day\(day)"
            let request = UNNotificationRequest(identifier: dayIdentifier, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request)
        }
        
        savePendingNotification(
            id: identifier,
            type: .exercise,
            title: content.title,
            time: time,
            repeatDaily: false,
            metadata: ["days": days, "exerciseName": exerciseName ?? ""]
        )
        
        return identifier
    }
    
    func scheduleSupplementReminder(supplementName: String, time: Date, repeatDaily: Bool = true) -> String {
        let content = UNMutableNotificationContent()
        content.title = "Supplement Reminder 💊"
        content.body = "Time to take your \(supplementName)"
        content.sound = .default
        content.userInfo = ["type": "supplement", "supplementName": supplementName]
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: repeatDaily)
        
        let identifier = "supplement_\(UUID().uuidString)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling supplement reminder: \(error)")
            } else {
                self.savePendingNotification(
                    id: identifier,
                    type: .supplement,
                    title: content.title,
                    time: time,
                    repeatDaily: repeatDaily,
                    metadata: ["supplementName": supplementName]
                )
            }
        }
        
        return identifier
    }
    
    func scheduleWeightReminder(time: Date, days: [Int]) -> String {
        let content = UNMutableNotificationContent()
        content.title = "Weight Check-in ⚖️"
        content.body = "Time to log your weight"
        content.sound = .default
        content.userInfo = ["type": "weight"]
        
        let identifier = "weight_\(UUID().uuidString)"
        
        // Schedule for each selected day
        for day in days {
            var components = Calendar.current.dateComponents([.hour, .minute], from: time)
            components.weekday = day
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let dayIdentifier = "\(identifier)_day\(day)"
            let request = UNNotificationRequest(identifier: dayIdentifier, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request)
        }
        
        savePendingNotification(
            id: identifier,
            type: .weight,
            title: content.title,
            time: time,
            repeatDaily: false,
            metadata: ["days": days]
        )
        
        return identifier
    }
    
    func scheduleCustomReminder(title: String, body: String, time: Date, repeatDaily: Bool = false) -> String {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.userInfo = ["type": "custom"]
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: repeatDaily)
        
        let identifier = "custom_\(UUID().uuidString)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling custom reminder: \(error)")
            } else {
                self.savePendingNotification(
                    id: identifier,
                    type: .custom,
                    title: title,
                    time: time,
                    repeatDaily: repeatDaily,
                    metadata: ["body": body]
                )
            }
        }
        
        return identifier
    }
    
    // MARK: - Cancel Notifications
    
    func cancelNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        removePendingNotification(id: identifier)
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        pendingNotifications.removeAll()
        savePendingNotifications()
    }
    
    // MARK: - Persistence
    
    private func savePendingNotification(id: String, type: NotificationType, title: String, time: Date, repeatDaily: Bool, metadata: [String: Any]) {
        let notification = PendingNotification(
            id: id,
            type: type,
            title: title,
            time: time,
            isRepeating: repeatDaily,
            metadata: metadata
        )
        
        pendingNotifications.append(notification)
        savePendingNotifications()
    }
    
    private func removePendingNotification(id: String) {
        pendingNotifications.removeAll { $0.id == id }
        savePendingNotifications()
    }
    
    private func savePendingNotifications() {
        if let encoded = try? JSONEncoder().encode(pendingNotifications) {
            UserDefaults.standard.set(encoded, forKey: "pendingNotifications")
        }
    }
    
    private func loadPendingNotifications() {
        if let data = UserDefaults.standard.data(forKey: "pendingNotifications"),
           let decoded = try? JSONDecoder().decode([PendingNotification].self, from: data) {
            pendingNotifications = decoded
        }
    }
}

// MARK: - Models

enum NotificationType: String, Codable, CaseIterable {
    case meal = "Meal"
    case water = "Water"
    case exercise = "Exercise"
    case supplement = "Supplement"
    case weight = "Weight"
    case custom = "Custom"
    
    var icon: String {
        switch self {
        case .meal: return "fork.knife"
        case .water: return "drop.fill"
        case .exercise: return "figure.run"
        case .supplement: return "pills.fill"
        case .weight: return "scalemass.fill"
        case .custom: return "bell.fill"
        }
    }
}

struct PendingNotification: Identifiable, Codable {
    let id: String
    let type: NotificationType
    let title: String
    let time: Date
    let isRepeating: Bool
    let metadata: [String: String]
    
    init(id: String, type: NotificationType, title: String, time: Date, isRepeating: Bool, metadata: [String: Any]) {
        self.id = id
        self.type = type
        self.title = title
        self.time = time
        self.isRepeating = isRepeating
        
        // Convert metadata to string dictionary for Codable
        var stringMetadata: [String: String] = [:]
        for (key, value) in metadata {
            if let stringValue = value as? String {
                stringMetadata[key] = stringValue
            } else if let intArray = value as? [Int] {
                stringMetadata[key] = intArray.map { String($0) }.joined(separator: ",")
            } else {
                stringMetadata[key] = String(describing: value)
            }
        }
        self.metadata = stringMetadata
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .list, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        switch response.actionIdentifier {
        case "LOG_MEAL":
            // Handle meal logging
            NotificationCenter.default.post(name: .openMealLogging, object: nil, userInfo: userInfo)
        case "LOG_WATER":
            // Handle water logging
            NotificationCenter.default.post(name: .openWaterLogging, object: nil, userInfo: userInfo)
        case "START_WORKOUT":
            // Handle workout start
            NotificationCenter.default.post(name: .openExerciseLogging, object: nil, userInfo: userInfo)
        case "SNOOZE_15", "SNOOZE_30", "SNOOZE_60":
            // Handle snooze
            handleSnooze(response: response)
        default:
            // Handle notification tap
            NotificationCenter.default.post(name: .notificationTapped, object: nil, userInfo: userInfo)
        }
        
        completionHandler()
    }
    
    private func handleSnooze(response: UNNotificationResponse) {
        let content = response.notification.request.content
        var snoozeInterval: TimeInterval = 900 // Default 15 minutes
        
        switch response.actionIdentifier {
        case "SNOOZE_15":
            snoozeInterval = 900
        case "SNOOZE_30":
            snoozeInterval = 1800
        case "SNOOZE_60":
            snoozeInterval = 3600
        default:
            break
        }
        
        // Create new notification with snooze
        let snoozeContent = UNMutableNotificationContent()
        snoozeContent.title = content.title
        snoozeContent.body = content.body
        snoozeContent.sound = content.sound
        snoozeContent.categoryIdentifier = content.categoryIdentifier
        snoozeContent.userInfo = content.userInfo
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: snoozeInterval, repeats: false)
        let request = UNNotificationRequest(
            identifier: "snooze_\(UUID().uuidString)",
            content: snoozeContent,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let openMealLogging = Notification.Name("openMealLogging")
    static let openWaterLogging = Notification.Name("openWaterLogging")
    static let openExerciseLogging = Notification.Name("openExerciseLogging")
    static let notificationTapped = Notification.Name("notificationTapped")
}