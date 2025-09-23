import SwiftUI

struct MealReminderView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMealType: MealType = .breakfast
    @State private var reminderTime = Date()
    @State private var repeatDaily = true
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Meal Type")) {
                    Picker("Meal", selection: $selectedMealType) {
                        ForEach(MealType.allCases, id: \.self) { mealType in
                            Text(mealType.rawValue).tag(mealType)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Time")) {
                    DatePicker("Reminder Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.compact)
                }
                
                Section {
                    Toggle("Repeat Daily", isOn: $repeatDaily)
                }
                
                Section {
                    Button(action: scheduleReminder) {
                        Text("Schedule Reminder")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.wellnessGreen)
                            .cornerRadius(10)
                    }
                }
            }
            .navigationTitle("Meal Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func scheduleReminder() {
        _ = NotificationService.shared.scheduleMealReminder(
            mealType: selectedMealType,
            time: reminderTime,
            repeatDaily: repeatDaily
        )
        dismiss()
    }
}

// MARK: - Water Reminder View

struct WaterReminderView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var reminderService = WaterReminderService.shared
    @State private var showingFullSettings = false
    
    var body: some View {
        NavigationView {
            Form {
                // Current Status
                if reminderService.isEnabled {
                    Section("Current Settings") {
                        HStack {
                            Label("Status", systemImage: "bell.fill")
                            Spacer()
                            Text("Active")
                                .foregroundColor(.green)
                        }

                        HStack {
                            Label("Frequency", systemImage: "clock")
                            Spacer()
                            Text(reminderService.intervalDescription)
                                .foregroundColor(.secondary)
                        }

                        HStack {
                            Label("Daily Goal", systemImage: "drop.fill")
                            Spacer()
                            Text("\(Int(reminderService.dailyGoal)) oz")
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // Quick Setup Options
                Section("Quick Setup") {
                    Button(action: { setupInterval(1800) }) { // 30 min
                        HStack {
                            Label("Every 30 minutes", systemImage: "timer")
                            Spacer()
                            if reminderService.reminderInterval == 1800 {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    .foregroundColor(.primary)

                    Button(action: { setupInterval(3600) }) { // 1 hour
                        HStack {
                            Label("Every hour", systemImage: "timer")
                            Spacer()
                            if reminderService.reminderInterval == 3600 {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    .foregroundColor(.primary)

                    Button(action: { setupInterval(7200) }) { // 2 hours
                        HStack {
                            Label("Every 2 hours", systemImage: "timer")
                            Spacer()
                            if reminderService.reminderInterval == 7200 {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }

                // Action Buttons
                Section {
                    if !reminderService.isEnabled {
                        Button(action: enableReminders) {
                            Label("Enable Water Reminders", systemImage: "bell.badge")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.wellnessGreen)
                                .cornerRadius(10)
                        }
                    } else {
                        Button(action: { showingFullSettings = true }) {
                            Label("Advanced Settings", systemImage: "slider.horizontal.3")
                                .font(.headline)
                                .foregroundColor(.wellnessGreen)
                        }

                        Button(action: disableReminders) {
                            Label("Disable Reminders", systemImage: "bell.slash")
                                .font(.headline)
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle("Water Reminders")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingFullSettings) {
                WaterReminderSettingsView()
            }
        }
    }

    private func setupInterval(_ interval: TimeInterval) {
        reminderService.reminderInterval = interval
        reminderService.saveSettings()
        if reminderService.isEnabled {
            reminderService.scheduleReminders()
        } else {
            reminderService.enableReminders()
        }
    }

    private func enableReminders() {
        reminderService.enableReminders()
    }

    private func disableReminders() {
        reminderService.disableReminders()
        dismiss()
    }
}

// MARK: - Exercise Reminder View

struct ExerciseReminderView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var exerciseName = ""
    @State private var reminderTime = Date()
    @State private var selectedDays: Set<Int> = []
    
    let weekdays = [
        (1, "Sun"), (2, "Mon"), (3, "Tue"), (4, "Wed"),
        (5, "Thu"), (6, "Fri"), (7, "Sat")
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Exercise Details")) {
                    TextField("Exercise Name (Optional)", text: $exerciseName)
                }
                
                Section(header: Text("Time")) {
                    DatePicker("Reminder Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                }
                
                Section(header: Text("Days")) {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 10) {
                        ForEach(weekdays, id: \.0) { day in
                            DayToggle(
                                day: day.0,
                                label: day.1,
                                isSelected: selectedDays.contains(day.0)
                            ) { selected in
                                if selected {
                                    selectedDays.insert(day.0)
                                } else {
                                    selectedDays.remove(day.0)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section {
                    Button(action: scheduleReminder) {
                        Text("Schedule Reminder")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.wellnessGreen)
                            .cornerRadius(10)
                    }
                    .disabled(selectedDays.isEmpty)
                }
            }
            .navigationTitle("Exercise Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func scheduleReminder() {
        _ = NotificationService.shared.scheduleExerciseReminder(
            time: reminderTime,
            days: Array(selectedDays).sorted(),
            exerciseName: exerciseName.isEmpty ? nil : exerciseName
        )
        dismiss()
    }
}

// MARK: - Day Toggle Component

struct DayToggle: View {
    let day: Int
    let label: String
    let isSelected: Bool
    let onToggle: (Bool) -> Void
    
    var body: some View {
        Button(action: {
            onToggle(!isSelected)
        }) {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : .primary)
                .frame(width: 50, height: 50)
                .background(isSelected ? Color.wellnessGreen : Color.gray.opacity(0.2))
                .cornerRadius(25)
        }
    }
}

// MARK: - Supplement Reminder View

struct SupplementReminderView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var supplementName = ""
    @State private var reminderTime = Date()
    @State private var repeatDaily = true
    
    // Common supplements for quick selection
    let commonSupplements = [
        "Multivitamin", "Vitamin D", "Omega-3", "Probiotics",
        "Magnesium", "Iron", "Vitamin C", "B-Complex"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Supplement Name")) {
                    TextField("Enter supplement name", text: $supplementName)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(commonSupplements, id: \.self) { supplement in
                                Button(action: {
                                    supplementName = supplement
                                }) {
                                    Text(supplement)
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(supplementName == supplement ? Color.wellnessGreen : Color.gray.opacity(0.2))
                                        .foregroundColor(supplementName == supplement ? .white : .primary)
                                        .cornerRadius(15)
                                }
                            }
                        }
                    }
                }
                
                Section(header: Text("Time")) {
                    DatePicker("Reminder Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                }
                
                Section {
                    Toggle("Repeat Daily", isOn: $repeatDaily)
                }
                
                Section {
                    Button(action: scheduleReminder) {
                        Text("Schedule Reminder")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.wellnessGreen)
                            .cornerRadius(10)
                    }
                    .disabled(supplementName.isEmpty)
                }
            }
            .navigationTitle("Supplement Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func scheduleReminder() {
        _ = NotificationService.shared.scheduleSupplementReminder(
            supplementName: supplementName,
            time: reminderTime,
            repeatDaily: repeatDaily
        )
        dismiss()
    }
}

// MARK: - Weight Reminder View

struct WeightReminderView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var reminderTime = Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var selectedDays: Set<Int> = [2, 6] // Monday and Friday by default
    
    let weekdays = [
        (1, "Sun"), (2, "Mon"), (3, "Tue"), (4, "Wed"),
        (5, "Thu"), (6, "Fri"), (7, "Sat")
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Time")) {
                    DatePicker("Reminder Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                    
                    Text("Tip: Weigh yourself at the same time for consistent tracking")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("Days")) {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 10) {
                        ForEach(weekdays, id: \.0) { day in
                            DayToggle(
                                day: day.0,
                                label: day.1,
                                isSelected: selectedDays.contains(day.0)
                            ) { selected in
                                if selected {
                                    selectedDays.insert(day.0)
                                } else {
                                    selectedDays.remove(day.0)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section {
                    Button(action: scheduleReminder) {
                        Text("Schedule Reminder")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.wellnessGreen)
                            .cornerRadius(10)
                    }
                    .disabled(selectedDays.isEmpty)
                }
            }
            .navigationTitle("Weight Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func scheduleReminder() {
        _ = NotificationService.shared.scheduleWeightReminder(
            time: reminderTime,
            days: Array(selectedDays).sorted()
        )
        dismiss()
    }
}

// MARK: - Custom Reminder View

struct CustomReminderView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var reminderTitle = ""
    @State private var reminderBody = ""
    @State private var reminderTime = Date()
    @State private var repeatDaily = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Reminder Details")) {
                    TextField("Title", text: $reminderTitle)
                    TextField("Message", text: $reminderBody, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section(header: Text("Time")) {
                    DatePicker("Reminder Time", selection: $reminderTime, displayedComponents: [.date, .hourAndMinute])
                }
                
                Section {
                    Toggle("Repeat Daily", isOn: $repeatDaily)
                }
                
                Section {
                    Button(action: scheduleReminder) {
                        Text("Schedule Reminder")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.wellnessGreen)
                            .cornerRadius(10)
                    }
                    .disabled(reminderTitle.isEmpty)
                }
            }
            .navigationTitle("Custom Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func scheduleReminder() {
        _ = NotificationService.shared.scheduleCustomReminder(
            title: reminderTitle,
            body: reminderBody,
            time: reminderTime,
            repeatDaily: repeatDaily
        )
        dismiss()
    }
}

// #Preview {
//     MealReminderView()
// }