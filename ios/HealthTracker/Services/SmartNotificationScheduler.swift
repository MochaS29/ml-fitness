import Foundation
import UserNotifications
import CoreData

/// Reschedules smart reminders with live progress data each time the app foregrounds.
/// Local notifications can't self-update at fire time, so we rebuild them on every
/// app open — the next notification that fires always reflects the latest logged data.
final class SmartNotificationScheduler {
    static let shared = SmartNotificationScheduler()
    private init() {}

    private let viewContext = PersistenceController.shared.container.viewContext

    func rescheduleAll() {
        let settings = SmartReminderSettings.shared
        guard settings.stepsEnabled || settings.waterEnabled ||
              settings.mealsEnabled || settings.exerciseEnabled else { return }

        fetchTodayData { [weak self] data in
            guard let self else { return }
            if settings.stepsEnabled    { self.scheduleStepReminder(settings: settings, data: data) }
            if settings.waterEnabled    { self.scheduleWaterReminders(settings: settings, data: data) }
            if settings.mealsEnabled    { self.scheduleMealReminders(settings: settings, data: data) }
            if settings.exerciseEnabled { self.scheduleExerciseReminder(settings: settings, data: data) }
        }
    }

    // MARK: - Data snapshot

    private struct TodayData {
        var steps: Int = 0
        var stepGoal: Int = 8000
        var waterGlasses: Int = 0
        var waterGoal: Int = 8
        var caloriesLogged: Int = 0
        var calorieGoal: Int = 2000
        var exerciseMinutes: Int = 0
        var breakfastLogged: Bool = false
        var lunchLogged: Bool = false
        var dinnerLogged: Bool = false
    }

    private func fetchTodayData(completion: @escaping (TodayData) -> Void) {
        var data = TodayData()
        data.stepGoal    = max(UserDefaults.standard.integer(forKey: "dailyStepGoal"), 1000)
        data.waterGoal   = max(UserDefaults.standard.integer(forKey: "dailyWaterGoal"), 1)
        data.calorieGoal = max(UserDefaults.standard.integer(forKey: "dailyCalorieGoal"), 500)

        // Steps from HealthKit
        HealthKitManager.shared.fetchTodaySteps { steps in
            data.steps = Int(steps ?? 0)

            // Core Data reads on the context queue
            self.viewContext.perform {
                // Water
                let waterReq = NSFetchRequest<WaterEntry>(entityName: "WaterEntry")
                waterReq.predicate = .forDay()
                if let entries = try? self.viewContext.fetch(waterReq) {
                    data.waterGlasses = Int(entries.reduce(0) { $0 + $1.amount } / 8.0)
                }

                // Food / calories + meal slot detection
                let foodReq = NSFetchRequest<FoodEntry>(entityName: "FoodEntry")
                foodReq.predicate = .forDay()
                if let entries = try? self.viewContext.fetch(foodReq) {
                    data.caloriesLogged = entries.reduce(0) { $0 + Int($1.calories) }

                    let calendar = Calendar.current
                    for entry in entries {
                        guard let ts = entry.timestamp else { continue }
                        let hour = calendar.component(.hour, from: ts)
                        if hour < 10  { data.breakfastLogged = true }
                        else if hour < 15 { data.lunchLogged = true }
                        else              { data.dinnerLogged = true }
                    }
                }

                // Exercise
                let exReq = NSFetchRequest<ExerciseEntry>(entityName: "ExerciseEntry")
                exReq.predicate = .forDay()
                if let entries = try? self.viewContext.fetch(exReq) {
                    data.exerciseMinutes = entries.reduce(0) { $0 + Int($1.duration) }
                }

                DispatchQueue.main.async { completion(data) }
            }
        }
    }

    // MARK: - Step reminder

    private func scheduleStepReminder(settings: SmartReminderSettings, data: TodayData) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["smart_steps_daily"])

        let content = UNMutableNotificationContent()
        content.sound = .default

        let remaining = data.stepGoal - data.steps
        if remaining <= 0 {
            content.title = "🎉 Step Goal Crushed!"
            content.body = "You hit \(data.steps.formatted()) steps today. Amazing work!"
        } else if data.steps == 0 {
            content.title = "🚶 Let's Get Moving!"
            content.body = "You haven't logged any steps yet. Your \(data.stepGoal.formatted())-step goal is waiting!"
        } else {
            let pct = Int(Double(data.steps) / Double(data.stepGoal) * 100)
            content.title = "🚶 Keep Moving!"
            content.body = "\(data.steps.formatted()) of \(data.stepGoal.formatted()) steps (\(pct)%) — only \(remaining.formatted()) to go!"
        }

        var components = DateComponents()
        components.hour = settings.stepsHour
        components.minute = settings.stepsMinute
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        center.add(UNNotificationRequest(identifier: "smart_steps_daily", content: content, trigger: trigger))
    }

    // MARK: - Water reminders

    private func scheduleWaterReminders(settings: SmartReminderSettings, data: TodayData) {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { requests in
            let ids = requests.filter { $0.identifier.hasPrefix("smart_water") }.map { $0.identifier }
            center.removePendingNotificationRequests(withIdentifiers: ids)

            let interval = Int(settings.waterInterval / 60)
            let start = settings.waterStartHour * 60
            let end   = settings.waterEndHour * 60
            let calendar = Calendar.current

            for day in 0..<7 {
                var current = start
                var count = 0
                while current < end && count < 12 {
                    let hour   = current / 60
                    let minute = current % 60

                    var components = DateComponents()
                    components.hour   = hour
                    components.minute = minute
                    if let target = calendar.date(byAdding: .day, value: day, to: Date()) {
                        let dc = calendar.dateComponents([.year, .month, .day], from: target)
                        components.year  = dc.year
                        components.month = dc.month
                        components.day   = dc.day
                    }

                    let content = UNMutableNotificationContent()
                    content.sound = .default
                    content.categoryIdentifier = "WATER_REMINDER"

                    if day == 0 {
                        // Personalise today's notifications
                        let remaining = data.waterGoal - data.waterGlasses
                        if remaining <= 0 {
                            content.title = "💧 Hydration Goal Met!"
                            content.body  = "You've hit your \(data.waterGoal)-glass goal today. Keep it up!"
                        } else {
                            content.title = "💧 Time to Hydrate!"
                            content.body  = "\(data.waterGlasses) of \(data.waterGoal) glasses so far — \(remaining) more to go!"
                        }
                    } else {
                        content.title = "💧 Time to Hydrate!"
                        content.body  = "Keep sipping — every glass counts toward your goal."
                    }

                    let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                    let id = "smart_water_\(day)_\(count)"
                    center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))

                    current += interval
                    count += 1
                }
            }
        }
    }

    // MARK: - Meal reminders

    private func scheduleMealReminders(settings: SmartReminderSettings, data: TodayData) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [
            "smart_meal_breakfast", "smart_meal_lunch", "smart_meal_dinner"
        ])

        let meals: [(id: String, title: String, hour: Int, logged: Bool)] = [
            ("smart_meal_breakfast", "🍳 Breakfast Time!", settings.breakfastHour, data.breakfastLogged),
            ("smart_meal_lunch",     "🥗 Lunch Time!",     settings.lunchHour,     data.lunchLogged),
            ("smart_meal_dinner",    "🍽️ Dinner Time!",   settings.dinnerHour,    data.dinnerLogged),
        ]

        for meal in meals {
            let content = UNMutableNotificationContent()
            content.title = meal.title
            content.sound = .default
            content.categoryIdentifier = "MEAL_REMINDER"

            if meal.logged {
                content.body = "Meal logged ✓ — you've tracked \(data.caloriesLogged.formatted()) cal today."
            } else {
                let remaining = data.calorieGoal - data.caloriesLogged
                if remaining > 0 {
                    content.body = "Don't forget to log your meal — \(data.caloriesLogged.formatted()) of \(data.calorieGoal.formatted()) cal logged so far."
                } else {
                    content.body = "You've hit your calorie goal today! Log your meal to stay on track."
                }
            }

            var components = DateComponents()
            components.hour   = meal.hour
            components.minute = 0
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            center.add(UNNotificationRequest(identifier: meal.id, content: content, trigger: trigger))
        }
    }

    // MARK: - Exercise reminder

    private func scheduleExerciseReminder(settings: SmartReminderSettings, data: TodayData) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["smart_exercise_daily"])

        let content = UNMutableNotificationContent()
        content.sound = .default
        content.categoryIdentifier = "EXERCISE_REMINDER"

        if data.exerciseMinutes >= 30 {
            content.title = "💪 Exercise Goal Hit!"
            content.body  = "You've logged \(data.exerciseMinutes) min of exercise today. Fantastic effort!"
        } else if data.exerciseMinutes > 0 {
            let left = 30 - data.exerciseMinutes
            content.title = "💪 Keep Going!"
            content.body  = "\(data.exerciseMinutes) min logged — just \(left) more minutes to hit your daily exercise goal."
        } else {
            content.title = "💪 Time to Move!"
            content.body  = "No exercise logged yet today. Even a 10-minute walk counts!"
        }

        var components = DateComponents()
        components.hour   = settings.exerciseHour
        components.minute = settings.exerciseMinute
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        center.add(UNNotificationRequest(identifier: "smart_exercise_daily", content: content, trigger: trigger))
    }
}
