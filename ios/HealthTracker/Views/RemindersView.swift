import SwiftUI

struct RemindersView: View {
    @StateObject private var notificationService = NotificationService.shared
    @State private var showingAddReminder = false
    @State private var selectedReminderType: NotificationType = .meal
    @State private var showingPermissionAlert = false
    
    var body: some View {
        NavigationView {
            VStack {
                if !notificationService.isNotificationEnabled {
                    // Permission request banner
                    VStack(spacing: 12) {
                        Image(systemName: "bell.slash.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        
                        Text("Enable Notifications")
                            .font(.headline)
                        
                        Text("Get timely reminders to track your health goals")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button(action: {
                            notificationService.requestNotificationPermission()
                        }) {
                            Text("Enable Notifications")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.wellnessGreen)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                    
                    Spacer()
                } else {
                    // Reminders list
                    if notificationService.pendingNotifications.isEmpty {
                        EmptyRemindersView()
                    } else {
                        List {
                            ForEach(NotificationType.allCases, id: \.self) { type in
                                let reminders = notificationService.pendingNotifications.filter { $0.type == type }
                                if !reminders.isEmpty {
                                    Section(header: HStack {
                                        Image(systemName: type.icon)
                                        Text(type.rawValue)
                                    }) {
                                        ForEach(reminders) { reminder in
                                            ReminderRow(reminder: reminder)
                                        }
                                        .onDelete { indices in
                                            deleteReminders(reminders: reminders, at: indices)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Reminders")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if notificationService.isNotificationEnabled {
                            showingAddReminder = true
                        } else {
                            showingPermissionAlert = true
                        }
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddReminder) {
                AddReminderView()
            }
            .alert("Notifications Disabled", isPresented: $showingPermissionAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            } message: {
                Text("Please enable notifications in Settings to add reminders.")
            }
        }
    }
    
    private func deleteReminders(reminders: [PendingNotification], at offsets: IndexSet) {
        for index in offsets {
            let reminder = reminders[index]
            notificationService.cancelNotification(identifier: reminder.id)
        }
    }
}

// MARK: - Empty State View

struct EmptyRemindersView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "bell.badge")
                .font(.system(size: 80))
                .foregroundColor(.lightGray)
            
            Text("No Reminders Set")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Add reminders to stay on track with your health goals")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Reminder Row

struct ReminderRow: View {
    let reminder: PendingNotification
    @State private var isEnabled = true
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(reminder.title)
                    .font(.body)
                    .fontWeight(.medium)
                
                HStack {
                    Image(systemName: "clock")
                        .font(.caption)
                    Text(timeString)
                        .font(.caption)
                    
                    if reminder.isRepeating {
                        Text("• Repeats")
                            .font(.caption)
                    }
                }
                .foregroundColor(.secondary)
                
                // Additional info based on type
                if let additionalInfo = getAdditionalInfo() {
                    Text(additionalInfo)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Toggle("", isOn: $isEnabled)
                .labelsHidden()
                .onChange(of: isEnabled) { oldValue, newValue in
                    // Handle enable/disable
                    if !newValue {
                        NotificationService.shared.cancelNotification(identifier: reminder.id)
                    }
                }
        }
        .padding(.vertical, 4)
    }
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: reminder.time)
    }
    
    private func getAdditionalInfo() -> String? {
        switch reminder.type {
        case .meal:
            if let mealType = reminder.metadata["mealType"] {
                return mealType
            }
        case .water:
            if let intervalString = reminder.metadata["interval"],
               let interval = TimeInterval(intervalString) {
                let hours = Int(interval / 3600)
                let minutes = Int((interval.truncatingRemainder(dividingBy: 3600)) / 60)
                if hours > 0 {
                    return "Every \(hours)h \(minutes)m"
                } else {
                    return "Every \(minutes) minutes"
                }
            }
        case .exercise:
            var info = ""
            if let exerciseName = reminder.metadata["exerciseName"], !exerciseName.isEmpty {
                info = exerciseName
            }
            if let daysString = reminder.metadata["days"] {
                let days = daysString.split(separator: ",").compactMap { Int($0) }
                let dayNames = days.map { dayName(for: $0) }.joined(separator: ", ")
                info += info.isEmpty ? dayNames : " • \(dayNames)"
            }
            return info.isEmpty ? nil : info
        case .supplement:
            return reminder.metadata["supplementName"]
        case .weight:
            if let daysString = reminder.metadata["days"] {
                let days = daysString.split(separator: ",").compactMap { Int($0) }
                let dayNames = days.map { dayName(for: $0) }.joined(separator: ", ")
                return dayNames
            }
        case .custom:
            return reminder.metadata["body"]
        }
        return nil
    }
    
    private func dayName(for weekday: Int) -> String {
        let formatter = DateFormatter()
        return formatter.shortWeekdaySymbols[weekday - 1]
    }
}

// MARK: - Add Reminder View

struct AddReminderView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedType: NotificationType = .meal
    @State private var showingTypeSpecificView = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Reminder Type")) {
                    ForEach(NotificationType.allCases, id: \.self) { type in
                        Button(action: {
                            selectedType = type
                            showingTypeSpecificView = true
                        }) {
                            HStack {
                                Image(systemName: type.icon)
                                    .foregroundColor(.wellnessGreen)
                                    .frame(width: 30)
                                
                                Text(type.rawValue)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
                
                Section(header: Text("Quick Actions")) {
                    Button(action: setupDailyMealReminders) {
                        Label("Set Up Daily Meal Reminders", systemImage: "calendar")
                            .foregroundColor(.wellnessGreen)
                    }
                    
                    Button(action: setupHourlyWaterReminder) {
                        Label("Hourly Water Reminder (8AM-8PM)", systemImage: "drop.fill")
                            .foregroundColor(.wellnessGreen)
                    }
                }
            }
            .navigationTitle("Add Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingTypeSpecificView) {
                getReminderDetailView()
            }
        }
    }
    
    @ViewBuilder
    private func getReminderDetailView() -> some View {
        switch selectedType {
        case .meal:
            MealReminderView()
        case .water:
            WaterReminderView()
        case .exercise:
            ExerciseReminderView()
        case .supplement:
            SupplementReminderView()
        case .weight:
            WeightReminderView()
        case .custom:
            CustomReminderView()
        }
    }
    
    private func setupDailyMealReminders() {
        let calendar = Calendar.current
        
        // Breakfast at 8 AM
        if let breakfastTime = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) {
            _ = NotificationService.shared.scheduleMealReminder(mealType: .breakfast, time: breakfastTime)
        }
        
        // Lunch at 12 PM
        if let lunchTime = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: Date()) {
            _ = NotificationService.shared.scheduleMealReminder(mealType: .lunch, time: lunchTime)
        }
        
        // Dinner at 6 PM
        if let dinnerTime = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: Date()) {
            _ = NotificationService.shared.scheduleMealReminder(mealType: .dinner, time: dinnerTime)
        }
        
        dismiss()
    }
    
    private func setupHourlyWaterReminder() {
        let calendar = Calendar.current
        if let startTime = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: Date()),
           let endTime = calendar.date(bySettingHour: 20, minute: 0, second: 0, of: Date()) {
            _ = NotificationService.shared.scheduleWaterReminder(
                interval: 3600, // 1 hour
                startTime: startTime,
                endTime: endTime
            )
        }
        dismiss()
    }
}

#Preview {
    RemindersView()
}