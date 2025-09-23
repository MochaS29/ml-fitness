import SwiftUI
import UserNotifications

struct WaterReminderSettingsView: View {
    @StateObject private var reminderService = WaterReminderService.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showingPermissionAlert = false
    @State private var tempStartTime = Date()
    @State private var tempEndTime = Date()

    var body: some View {
        NavigationView {
            Form {
                // Enable/Disable Section
                Section {
                    Toggle("Enable Water Reminders", isOn: Binding(
                        get: { reminderService.isEnabled },
                        set: { newValue in
                            if newValue {
                                reminderService.enableReminders()
                            } else {
                                reminderService.disableReminders()
                            }
                        }
                    ))
                    .tint(Color.mindfulTeal)

                    if reminderService.isEnabled {
                        Label("Reminders are active", systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                } header: {
                    Text("Notifications")
                } footer: {
                    Text("Receive gentle reminders throughout the day to stay hydrated")
                }

                // Current Progress Section
                Section("Today's Progress") {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(Int(reminderService.currentIntake)) oz")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text("of \(Int(reminderService.dailyGoal)) oz goal")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        CircularProgressView(
                            progress: reminderService.progressPercentage,
                            lineWidth: 8,
                            color: Color.mindfulTeal
                        )
                        .frame(width: 60, height: 60)
                    }

                    // Quick add buttons
                    HStack(spacing: 12) {
                        ForEach([8, 12, 16, 20], id: \.self) { amount in
                            Button(action: {
                                reminderService.addWaterIntake(Double(amount))
                            }) {
                                Text("+\(amount)")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(Color.mindfulTeal)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }

                // Schedule Settings
                if reminderService.isEnabled {
                    Section("Reminder Schedule") {
                        // Frequency Picker
                        Picker("Frequency", selection: $reminderService.reminderInterval) {
                            ForEach(WaterReminderService.intervalOptions, id: \.1) { option in
                                Text(option.0).tag(option.1)
                            }
                        }
                        .onChange(of: reminderService.reminderInterval) { _ in
                            reminderService.saveSettings()
                            reminderService.scheduleReminders()
                        }

                        // Start Time
                        DatePicker(
                            "Start Time",
                            selection: Binding(
                                get: { reminderService.startTime },
                                set: { newValue in
                                    reminderService.startTime = newValue
                                    reminderService.saveSettings()
                                    reminderService.scheduleReminders()
                                }
                            ),
                            displayedComponents: .hourAndMinute
                        )

                        // End Time
                        DatePicker(
                            "End Time",
                            selection: Binding(
                                get: { reminderService.endTime },
                                set: { newValue in
                                    reminderService.endTime = newValue
                                    reminderService.saveSettings()
                                    reminderService.scheduleReminders()
                                }
                            ),
                            displayedComponents: .hourAndMinute
                        )
                    }

                    // Daily Goal
                    Section("Daily Goal") {
                        HStack {
                            Text("Target")
                            Spacer()
                            Text("\(Int(reminderService.dailyGoal)) oz")
                                .foregroundColor(.secondary)
                        }

                        Slider(
                            value: $reminderService.dailyGoal,
                            in: 32...128,
                            step: 8
                        ) {
                            Text("Daily Goal")
                        } minimumValueLabel: {
                            Text("32")
                                .font(.caption)
                        } maximumValueLabel: {
                            Text("128")
                                .font(.caption)
                        }
                        .tint(Color.mindfulTeal)
                        .onChange(of: reminderService.dailyGoal) { _ in
                            reminderService.saveSettings()
                        }

                        // Glasses equivalent
                        HStack {
                            Image(systemName: "drop.fill")
                                .foregroundColor(.mindfulTeal)
                            Text("About \(Int(reminderService.dailyGoal / 8)) glasses")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // Smart Features Section
                Section("Smart Features") {
                    VStack(alignment: .leading, spacing: 12) {
                        WaterFeatureRow(
                            icon: "bell.badge",
                            title: "Adaptive Reminders",
                            description: "Notifications adjust to your schedule",
                            color: .blue
                        )

                        WaterFeatureRow(
                            icon: "chart.line.uptrend.xyaxis",
                            title: "Progress Tracking",
                            description: "Monitor your hydration trends",
                            color: .green
                        )

                        WaterFeatureRow(
                            icon: "hand.tap",
                            title: "Quick Actions",
                            description: "Log water directly from notifications",
                            color: .orange
                        )
                    }
                    .padding(.vertical, 4)
                }

                // Tips Section
                Section("Hydration Tips") {
                    VStack(alignment: .leading, spacing: 8) {
                        WaterTipRow(text: "Drink a glass when you wake up")
                        WaterTipRow(text: "Keep a water bottle at your desk")
                        WaterTipRow(text: "Drink before, during, and after exercise")
                        WaterTipRow(text: "Choose water over sugary drinks")
                        WaterTipRow(text: "Eat water-rich foods like fruits")
                    }
                }

                // Debug/Test Section (remove in production)
                #if DEBUG
                Section("Test Notifications") {
                    Button(action: {
                        sendTestNotification()
                    }) {
                        Label("Send Test Reminder", systemImage: "bell")
                            .foregroundColor(.blue)
                    }
                }
                #endif
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
        }
        .alert("Notifications Disabled", isPresented: $showingPermissionAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Enable notifications in Settings to receive water reminders")
        }
        .onAppear {
            checkNotificationPermission()
        }
    }

    private func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                if settings.authorizationStatus == .denied {
                    showingPermissionAlert = reminderService.isEnabled
                }
            }
        }
    }

    private func sendTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "💧 Test Reminder"
        content.body = "This is what your water reminders will look like!"
        content.sound = .default
        content.categoryIdentifier = "WATER_REMINDER"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        let request = UNNotificationRequest(
            identifier: "test_water_reminder",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }
}

// MARK: - Supporting Views

struct CircularProgressView: View {
    let progress: Double
    let lineWidth: CGFloat
    let color: Color

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.3), value: progress)

            Text("\(Int(progress * 100))%")
                .font(.caption)
                .fontWeight(.semibold)
        }
    }
}

struct WaterFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct WaterTipRow: View {
    let text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "drop.fill")
                .font(.caption)
                .foregroundColor(.mindfulTeal)
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// Preview
#if DEBUG
struct WaterReminderSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        WaterReminderSettingsView()
    }
}
#endif