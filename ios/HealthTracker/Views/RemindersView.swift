import SwiftUI
import UserNotifications

// MARK: - Smart Reminder Settings (persisted)

class SmartReminderSettings: ObservableObject {
    static let shared = SmartReminderSettings()

    // Water
    @AppStorage("reminder_water_enabled")    var waterEnabled: Bool = false
    @AppStorage("reminder_water_interval")   var waterInterval: Double = 3600
    @AppStorage("reminder_water_start")      var waterStartHour: Int = 8
    @AppStorage("reminder_water_end")        var waterEndHour: Int = 20

    // Steps
    @AppStorage("reminder_steps_enabled")    var stepsEnabled: Bool = false
    @AppStorage("reminder_steps_hour")       var stepsHour: Int = 19
    @AppStorage("reminder_steps_minute")     var stepsMinute: Int = 0

    // Meals
    @AppStorage("reminder_meals_enabled")    var mealsEnabled: Bool = false
    @AppStorage("reminder_breakfast_hour")   var breakfastHour: Int = 8
    @AppStorage("reminder_lunch_hour")       var lunchHour: Int = 12
    @AppStorage("reminder_dinner_hour")      var dinnerHour: Int = 18

    // Exercise
    @AppStorage("reminder_exercise_enabled") var exerciseEnabled: Bool = false
    @AppStorage("reminder_exercise_hour")    var exerciseHour: Int = 7
    @AppStorage("reminder_exercise_minute")  var exerciseMinute: Int = 0

    // Weight
    @AppStorage("reminder_weight_enabled")   var weightEnabled: Bool = false
    @AppStorage("reminder_weight_hour")      var weightHour: Int = 8
    @AppStorage("reminder_weight_minute")    var weightMinute: Int = 0

    private init() {}
}

// MARK: - Main View

struct RemindersView: View {
    @StateObject private var settings = SmartReminderSettings.shared
    @StateObject private var notificationService = NotificationService.shared
    @StateObject private var waterService = WaterReminderService.shared

    @State private var notificationsAuthorized = false
    @State private var waterExpanded = false
    @State private var stepsExpanded = false
    @State private var mealsExpanded = false
    @State private var exerciseExpanded = false
    @State private var weightExpanded = false
    @State private var customReminders: [PendingNotification] = []
    @State private var showingAddCustom = false

    var body: some View {
        NavigationView {
            Group {
                if !notificationsAuthorized {
                    permissionBanner
                } else {
                    List {
                        smartRemindersSection
                        customRemindersSection
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Reminders")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if notificationsAuthorized {
                        Button(action: { showingAddCustom = true }) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddCustom) {
                CustomReminderView()
            }
            .onAppear {
                checkPermissions()
                loadCustomReminders()
            }
        }
    }

    // MARK: - Permission Banner

    private var permissionBanner: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 60))
                .foregroundColor(.mindfulTeal)

            Text("Enable Notifications")
                .font(.title2)
                .fontWeight(.bold)

            Text("Allow notifications to receive water, meal, and step goal reminders.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button(action: {
                NotificationService.shared.requestNotificationPermission()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    checkPermissions()
                }
            }) {
                Text("Enable Notifications")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.mindfulTeal)
                    .cornerRadius(14)
            }
            .padding(.horizontal, 32)

            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .font(.subheadline)
            .foregroundColor(.secondary)

            Spacer()
        }
    }

    // MARK: - Smart Reminders Section

    private var smartRemindersSection: some View {
        Section {
            // WATER
            ReminderToggleRow(
                icon: "drop.fill",
                iconColor: .blue,
                title: "Water Reminders",
                subtitle: settings.waterEnabled ? "Every \(waterIntervalLabel) · \(settings.waterStartHour):00–\(settings.waterEndHour):00" : "Stay hydrated throughout the day",
                isOn: Binding(
                    get: { settings.waterEnabled },
                    set: { val in
                        settings.waterEnabled = val
                        applyWaterReminder(enabled: val)
                    }
                ),
                isExpanded: $waterExpanded
            )
            if waterExpanded && settings.waterEnabled {
                waterSettings
            }

            // STEP GOAL
            ReminderToggleRow(
                icon: "figure.walk",
                iconColor: .orange,
                title: "Step Goal Nudge",
                subtitle: settings.stepsEnabled ? "Daily at \(timeLabel(settings.stepsHour, settings.stepsMinute))" : "Get a nudge to hit your daily steps",
                isOn: Binding(
                    get: { settings.stepsEnabled },
                    set: { val in
                        settings.stepsEnabled = val
                        applyStepReminder(enabled: val)
                    }
                ),
                isExpanded: $stepsExpanded
            )
            if stepsExpanded && settings.stepsEnabled {
                stepSettings
            }

            // MEALS
            ReminderToggleRow(
                icon: "fork.knife",
                iconColor: .green,
                title: "Meal Reminders",
                subtitle: settings.mealsEnabled ? "Breakfast, Lunch & Dinner" : "Reminders to log your meals",
                isOn: Binding(
                    get: { settings.mealsEnabled },
                    set: { val in
                        settings.mealsEnabled = val
                        applyMealReminders(enabled: val)
                    }
                ),
                isExpanded: $mealsExpanded
            )
            if mealsExpanded && settings.mealsEnabled {
                mealSettings
            }

            // EXERCISE
            ReminderToggleRow(
                icon: "figure.run",
                iconColor: Color(red: 1, green: 0.6, blue: 0),
                title: "Exercise Reminder",
                subtitle: settings.exerciseEnabled ? "Daily at \(timeLabel(settings.exerciseHour, settings.exerciseMinute))" : "Daily reminder to move",
                isOn: Binding(
                    get: { settings.exerciseEnabled },
                    set: { val in
                        settings.exerciseEnabled = val
                        applyExerciseReminder(enabled: val)
                    }
                ),
                isExpanded: $exerciseExpanded
            )
            if exerciseExpanded && settings.exerciseEnabled {
                exerciseSettings
            }

            // WEIGHT
            ReminderToggleRow(
                icon: "scalemass.fill",
                iconColor: Color(red: 0.55, green: 0.27, blue: 0.07),
                title: "Weight Check-in",
                subtitle: settings.weightEnabled ? "Daily at \(timeLabel(settings.weightHour, settings.weightMinute))" : "Reminder to log your weight",
                isOn: Binding(
                    get: { settings.weightEnabled },
                    set: { val in
                        settings.weightEnabled = val
                        applyWeightReminder(enabled: val)
                    }
                ),
                isExpanded: $weightExpanded
            )
            if weightExpanded && settings.weightEnabled {
                weightSettings
            }
        } header: {
            Text("Smart Reminders")
        } footer: {
            Text("Toggle any reminder on/off instantly. Tap the chevron to adjust timing.")
                .font(.caption)
        }
    }

    // MARK: - Inline Settings

    private var waterSettings: some View {
        Group {
            Picker("Frequency", selection: Binding(
                get: { settings.waterInterval },
                set: { val in
                    settings.waterInterval = val
                    applyWaterReminder(enabled: true)
                }
            )) {
                Text("Every 30 min").tag(1800.0)
                Text("Every hour").tag(3600.0)
                Text("Every 90 min").tag(5400.0)
                Text("Every 2 hours").tag(7200.0)
                Text("Every 3 hours").tag(10800.0)
            }
            .pickerStyle(.menu)

            HStack {
                Text("Active from")
                Spacer()
                Picker("Start", selection: Binding(
                    get: { settings.waterStartHour },
                    set: { val in
                        settings.waterStartHour = val
                        applyWaterReminder(enabled: true)
                    }
                )) {
                    ForEach(6..<12) { h in Text("\(h):00").tag(h) }
                }
                .pickerStyle(.menu)
                Text("to")
                Picker("End", selection: Binding(
                    get: { settings.waterEndHour },
                    set: { val in
                        settings.waterEndHour = val
                        applyWaterReminder(enabled: true)
                    }
                )) {
                    ForEach(16..<24) { h in Text("\(h):00").tag(h) }
                }
                .pickerStyle(.menu)
            }
        }
        .font(.subheadline)
    }

    private var stepSettings: some View {
        HStack {
            Text("Reminder time")
            Spacer()
            Picker("Hour", selection: Binding(
                get: { settings.stepsHour },
                set: { val in
                    settings.stepsHour = val
                    applyStepReminder(enabled: true)
                }
            )) {
                ForEach(6..<23) { h in Text("\(h):00").tag(h) }
            }
            .pickerStyle(.menu)
        }
        .font(.subheadline)
    }

    private var mealSettings: some View {
        Group {
            HStack {
                Text("Breakfast")
                Spacer()
                Picker("", selection: Binding(
                    get: { settings.breakfastHour },
                    set: { val in
                        settings.breakfastHour = val
                        applyMealReminders(enabled: true)
                    }
                )) {
                    ForEach(5..<11) { h in Text("\(h):00 AM").tag(h) }
                }
                .pickerStyle(.menu)
            }
            HStack {
                Text("Lunch")
                Spacer()
                Picker("", selection: Binding(
                    get: { settings.lunchHour },
                    set: { val in
                        settings.lunchHour = val
                        applyMealReminders(enabled: true)
                    }
                )) {
                    ForEach(11..<15) { h in Text("\(h):00").tag(h) }
                }
                .pickerStyle(.menu)
            }
            HStack {
                Text("Dinner")
                Spacer()
                Picker("", selection: Binding(
                    get: { settings.dinnerHour },
                    set: { val in
                        settings.dinnerHour = val
                        applyMealReminders(enabled: true)
                    }
                )) {
                    ForEach(15..<21) { h in Text("\(h):00").tag(h) }
                }
                .pickerStyle(.menu)
            }
        }
        .font(.subheadline)
    }

    private var exerciseSettings: some View {
        HStack {
            Text("Reminder time")
            Spacer()
            Picker("Hour", selection: Binding(
                get: { settings.exerciseHour },
                set: { val in
                    settings.exerciseHour = val
                    applyExerciseReminder(enabled: true)
                }
            )) {
                ForEach(5..<22) { h in Text("\(h):00").tag(h) }
            }
            .pickerStyle(.menu)
        }
        .font(.subheadline)
    }

    private var weightSettings: some View {
        HStack {
            Text("Reminder time")
            Spacer()
            Picker("Hour", selection: Binding(
                get: { settings.weightHour },
                set: { val in
                    settings.weightHour = val
                    applyWeightReminder(enabled: true)
                }
            )) {
                ForEach(5..<22) { h in Text("\(h):00").tag(h) }
            }
            .pickerStyle(.menu)
        }
        .font(.subheadline)
    }

    // MARK: - Custom Reminders Section

    private var customRemindersSection: some View {
        Section("Custom Reminders") {
            if customReminders.isEmpty {
                Text("No custom reminders")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            } else {
                ForEach(customReminders) { reminder in
                    VStack(alignment: .leading, spacing: 3) {
                        Text(reminder.title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text(reminder.time, style: .time)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 2)
                }
                .onDelete { indices in
                    for i in indices {
                        NotificationService.shared.cancelNotification(identifier: customReminders[i].id)
                    }
                    loadCustomReminders()
                }
            }
        }
    }

    // MARK: - Helpers

    private var waterIntervalLabel: String {
        switch settings.waterInterval {
        case 1800: return "30 min"
        case 3600: return "1 hr"
        case 5400: return "90 min"
        case 7200: return "2 hrs"
        case 10800: return "3 hrs"
        default: return "1 hr"
        }
    }

    private func timeLabel(_ hour: Int, _ minute: Int) -> String {
        let h = hour % 12 == 0 ? 12 : hour % 12
        let suffix = hour < 12 ? "AM" : "PM"
        return minute == 0 ? "\(h) \(suffix)" : "\(h):\(String(format: "%02d", minute)) \(suffix)"
    }

    private func checkPermissions() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                notificationsAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }

    private func loadCustomReminders() {
        customReminders = notificationService.pendingNotifications.filter { $0.type == .custom }
    }

    // MARK: - Apply Reminders

    private func applyWaterReminder(enabled: Bool) {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { requests in
            let ids = requests.filter { $0.identifier.hasPrefix("smart_water") }.map { $0.identifier }
            center.removePendingNotificationRequests(withIdentifiers: ids)
        }
        guard enabled else { return }

        let interval = Int(settings.waterInterval / 60)
        let start = settings.waterStartHour * 60
        let end = settings.waterEndHour * 60
        var current = start
        var count = 0

        // Schedule for next 7 days
        let calendar = Calendar.current
        for day in 0..<7 {
            current = start
            count = 0
            while current < end && count < 12 {
                let hour = current / 60
                let minute = current % 60
                var components = DateComponents()
                components.hour = hour
                components.minute = minute
                if let targetDate = calendar.date(byAdding: .day, value: day, to: Date()) {
                    let dayComponents = calendar.dateComponents([.year, .month, .day], from: targetDate)
                    components.year = dayComponents.year
                    components.month = dayComponents.month
                    components.day = dayComponents.day
                }
                let content = UNMutableNotificationContent()
                content.title = "💧 Time to Hydrate!"
                content.body = "Keep sipping — every glass counts toward your goal."
                content.sound = .default
                content.categoryIdentifier = "WATER_REMINDER"
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                let id = "smart_water_\(day)_\(count)"
                let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request)
                current += interval
                count += 1
            }
        }
    }

    private func applyStepReminder(enabled: Bool) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["smart_steps_daily"])
        guard enabled else { return }
        let content = UNMutableNotificationContent()
        content.title = "🚶 Keep Moving!"
        content.body = "Check your step count and push to hit your daily goal."
        content.sound = .default
        var components = DateComponents()
        components.hour = settings.stepsHour
        components.minute = settings.stepsMinute
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "smart_steps_daily", content: content, trigger: trigger)
        center.add(request)
    }

    private func applyMealReminders(enabled: Bool) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["smart_meal_breakfast", "smart_meal_lunch", "smart_meal_dinner"])
        guard enabled else { return }

        let meals: [(String, String, Int)] = [
            ("smart_meal_breakfast", "🍳 Breakfast Time!", settings.breakfastHour),
            ("smart_meal_lunch",     "🥗 Lunch Time!",    settings.lunchHour),
            ("smart_meal_dinner",    "🍽️ Dinner Time!",  settings.dinnerHour)
        ]
        for (id, title, hour) in meals {
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = "Don't forget to log your meal."
            content.sound = .default
            content.categoryIdentifier = "MEAL_REMINDER"
            var components = DateComponents()
            components.hour = hour
            components.minute = 0
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
        }
    }

    private func applyExerciseReminder(enabled: Bool) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["smart_exercise_daily"])
        guard enabled else { return }
        let content = UNMutableNotificationContent()
        content.title = "💪 Time to Move!"
        content.body = "A quick workout will keep you on track with your goals."
        content.sound = .default
        content.categoryIdentifier = "EXERCISE_REMINDER"
        var components = DateComponents()
        components.hour = settings.exerciseHour
        components.minute = settings.exerciseMinute
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        center.add(UNNotificationRequest(identifier: "smart_exercise_daily", content: content, trigger: trigger))
    }

    private func applyWeightReminder(enabled: Bool) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["smart_weight_daily"])
        guard enabled else { return }
        let content = UNMutableNotificationContent()
        content.title = "⚖️ Weight Check-in"
        content.body = "Log your weight to keep your progress up to date."
        content.sound = .default
        var components = DateComponents()
        components.hour = settings.weightHour
        components.minute = settings.weightMinute
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        center.add(UNNotificationRequest(identifier: "smart_weight_daily", content: content, trigger: trigger))
    }
}

// MARK: - Toggle Row

struct ReminderToggleRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    @Binding var isExpanded: Bool

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.system(size: 16, weight: .semibold))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            if isOn {
                Button(action: { withAnimation(.easeInOut(duration: 0.2)) { isExpanded.toggle() } }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .onChange(of: isOn) { _, newVal in
                    if !newVal { isExpanded = false }
                }
        }
        .padding(.vertical, 2)
    }
}
