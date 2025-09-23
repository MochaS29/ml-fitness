import Foundation
import UserNotifications
import SwiftUI

class WaterReminderService: NSObject, ObservableObject {
    static let shared = WaterReminderService()

    @Published var isEnabled = false
    @Published var reminderInterval: TimeInterval = 7200 // 2 hours default
    @Published var startTime = Date()
    @Published var endTime = Date()
    @Published var dailyGoal: Double = 64.0 // oz
    @Published var currentIntake: Double = 0.0

    private let notificationCenter = UNUserNotificationCenter.current()
    private let userDefaults = UserDefaults.standard

    // Keys for UserDefaults
    private let kWaterRemindersEnabled = "waterRemindersEnabled"
    private let kWaterReminderInterval = "waterReminderInterval"
    private let kWaterReminderStartTime = "waterReminderStartTime"
    private let kWaterReminderEndTime = "waterReminderEndTime"
    private let kWaterDailyGoal = "waterDailyGoal"
    private let kLastWaterIntakeDate = "lastWaterIntakeDate"
    private let kDailyWaterIntake = "dailyWaterIntake"

    override init() {
        super.init()
        loadSettings()
        setupNotificationCategories()
        notificationCenter.delegate = self
        resetDailyIntakeIfNeeded()
    }

    // MARK: - Settings Management

    func loadSettings() {
        isEnabled = userDefaults.bool(forKey: kWaterRemindersEnabled)
        reminderInterval = userDefaults.double(forKey: kWaterReminderInterval)
        if reminderInterval == 0 { reminderInterval = 7200 } // Default 2 hours

        // Default times: 8 AM to 8 PM
        if let startData = userDefaults.data(forKey: kWaterReminderStartTime) {
            startTime = (try? JSONDecoder().decode(Date.self, from: startData)) ?? defaultStartTime()
        } else {
            startTime = defaultStartTime()
        }

        if let endData = userDefaults.data(forKey: kWaterReminderEndTime) {
            endTime = (try? JSONDecoder().decode(Date.self, from: endData)) ?? defaultEndTime()
        } else {
            endTime = defaultEndTime()
        }

        dailyGoal = userDefaults.double(forKey: kWaterDailyGoal)
        if dailyGoal == 0 { dailyGoal = 64.0 } // Default 64 oz

        currentIntake = userDefaults.double(forKey: kDailyWaterIntake)
    }

    func saveSettings() {
        userDefaults.set(isEnabled, forKey: kWaterRemindersEnabled)
        userDefaults.set(reminderInterval, forKey: kWaterReminderInterval)

        if let startData = try? JSONEncoder().encode(startTime) {
            userDefaults.set(startData, forKey: kWaterReminderStartTime)
        }
        if let endData = try? JSONEncoder().encode(endTime) {
            userDefaults.set(endData, forKey: kWaterReminderEndTime)
        }

        userDefaults.set(dailyGoal, forKey: kWaterDailyGoal)
        userDefaults.set(currentIntake, forKey: kDailyWaterIntake)
    }

    private func defaultStartTime() -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = 8
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }

    private func defaultEndTime() -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = 20 // 8 PM
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }

    // MARK: - Daily Intake Management

    func resetDailyIntakeIfNeeded() {
        let lastDate = userDefaults.object(forKey: kLastWaterIntakeDate) as? Date ?? Date.distantPast
        if !Calendar.current.isDateInToday(lastDate) {
            currentIntake = 0
            userDefaults.set(currentIntake, forKey: kDailyWaterIntake)
            userDefaults.set(Date(), forKey: kLastWaterIntakeDate)
        }
    }

    func addWaterIntake(_ amount: Double) {
        resetDailyIntakeIfNeeded()
        currentIntake += amount
        userDefaults.set(currentIntake, forKey: kDailyWaterIntake)
        userDefaults.set(Date(), forKey: kLastWaterIntakeDate)

        // Check if goal is met
        if currentIntake >= dailyGoal {
            scheduleGoalAchievedNotification()
        }
    }

    var remainingIntake: Double {
        max(0, dailyGoal - currentIntake)
    }

    var progressPercentage: Double {
        guard dailyGoal > 0 else { return 0 }
        return min(1.0, currentIntake / dailyGoal)
    }

    // MARK: - Notification Setup

    private func setupNotificationCategories() {
        // Quick action buttons for notifications
        let drinkAction = UNNotificationAction(
            identifier: "DRINK_WATER",
            title: "Log 8 oz",
            options: [.foreground]
        )

        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE_REMINDER",
            title: "Remind in 30 min",
            options: []
        )

        let category = UNNotificationCategory(
            identifier: "WATER_REMINDER",
            actions: [drinkAction, snoozeAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )

        notificationCenter.setNotificationCategories([category])
    }

    // MARK: - Permission Management

    func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    completion(true)
                } else {
                    self.isEnabled = false
                    self.saveSettings()
                    completion(false)
                }
            }
        }
    }

    // MARK: - Scheduling

    func enableReminders() {
        requestNotificationPermission { [weak self] granted in
            guard granted, let self = self else { return }
            self.isEnabled = true
            self.saveSettings()
            self.scheduleReminders()
        }
    }

    func disableReminders() {
        isEnabled = false
        saveSettings()
        cancelAllReminders()
    }

    func scheduleReminders() {
        // Cancel existing reminders first
        cancelAllReminders()

        guard isEnabled else { return }

        let calendar = Calendar.current
        let now = Date()

        // Get start and end times for today
        let startComponents = calendar.dateComponents([.hour, .minute], from: startTime)
        let endComponents = calendar.dateComponents([.hour, .minute], from: endTime)

        guard let startHour = startComponents.hour,
              let startMinute = startComponents.minute,
              let endHour = endComponents.hour,
              let endMinute = endComponents.minute else { return }

        // Calculate total minutes in the active period
        let startTotalMinutes = startHour * 60 + startMinute
        let endTotalMinutes = endHour * 60 + endMinute
        let intervalMinutes = Int(reminderInterval / 60)

        // Schedule notifications for the next 7 days
        for dayOffset in 0..<7 {
            guard let targetDate = calendar.date(byAdding: .day, value: dayOffset, to: now) else { continue }

            var currentMinutes = startTotalMinutes
            var notificationCount = 0

            while currentMinutes < endTotalMinutes && notificationCount < 10 { // Max 10 per day
                let hour = currentMinutes / 60
                let minute = currentMinutes % 60

                var dateComponents = calendar.dateComponents([.year, .month, .day], from: targetDate)
                dateComponents.hour = hour
                dateComponents.minute = minute

                // Create notification
                let content = UNMutableNotificationContent()
                content.title = "💧 Time to Hydrate!"
                content.body = motivationalMessage()
                content.sound = .default
                content.categoryIdentifier = "WATER_REMINDER"
                content.badge = NSNumber(value: Int(remainingIntake / 8)) // Remaining glasses

                // Add custom data
                content.userInfo = ["type": "water_reminder"]

                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                let identifier = "water_reminder_\(dayOffset)_\(notificationCount)"
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

                notificationCenter.add(request) { error in
                    if let error = error {
                        print("Error scheduling water reminder: \(error)")
                    }
                }

                currentMinutes += intervalMinutes
                notificationCount += 1
            }
        }
    }

    private func motivationalMessage() -> String {
        let messages = [
            "You've had \(Int(currentIntake)) oz today. Keep it up! 💪",
            "Stay hydrated! Only \(Int(remainingIntake)) oz to reach your goal!",
            "Your body will thank you! 🌟",
            "Hydration check! How about a glass of water?",
            "Water break time! You're \(Int(progressPercentage * 100))% to your goal!",
            "Keep your energy up with some H2O! 💧",
            "Almost there! \(Int(remainingIntake)) oz left today!",
            "Refresh yourself with a glass of water! 🥤"
        ]
        return messages.randomElement() ?? messages[0]
    }

    func scheduleGoalAchievedNotification() {
        let content = UNMutableNotificationContent()
        content.title = "🎉 Daily Goal Achieved!"
        content.body = "Congratulations! You've reached your daily water intake goal of \(Int(dailyGoal)) oz!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "water_goal_achieved", content: content, trigger: trigger)

        notificationCenter.add(request)
    }

    func cancelAllReminders() {
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
    }

    // MARK: - Quick Actions

    func scheduleSnoozeReminder() {
        let content = UNMutableNotificationContent()
        content.title = "💧 Hydration Reminder"
        content.body = "Don't forget to drink water!"
        content.sound = .default
        content.categoryIdentifier = "WATER_REMINDER"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1800, repeats: false) // 30 minutes
        let request = UNNotificationRequest(identifier: "water_snooze", content: content, trigger: trigger)

        notificationCenter.add(request)
    }
}

// MARK: - Notification Delegate

extension WaterReminderService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {

        switch response.actionIdentifier {
        case "DRINK_WATER":
            // Log 8 oz of water
            addWaterIntake(8)

        case "SNOOZE_REMINDER":
            // Schedule a reminder in 30 minutes
            scheduleSnoozeReminder()

        case UNNotificationDefaultActionIdentifier:
            // User tapped the notification itself
            // Could open the water tracking view
            break

        default:
            break
        }

        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        completionHandler([.alert, .sound, .badge])
    }
}

// MARK: - Interval Options

extension WaterReminderService {
    static let intervalOptions: [(String, TimeInterval)] = [
        ("Every 30 minutes", 1800),
        ("Every hour", 3600),
        ("Every 90 minutes", 5400),
        ("Every 2 hours", 7200),
        ("Every 3 hours", 10800),
        ("Every 4 hours", 14400)
    ]

    var intervalDescription: String {
        Self.intervalOptions.first(where: { $0.1 == reminderInterval })?.0 ?? "Every 2 hours"
    }
}