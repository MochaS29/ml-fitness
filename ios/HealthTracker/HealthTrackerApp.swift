import SwiftUI
import WatchConnectivity
import UserNotifications

@main
struct HealthTrackerApp: App {
    @StateObject private var userProfileManager = UserProfileManager()
    @ObservedObject private var achievementManager = AchievementManager.shared
    @ObservedObject private var waterReminderService = WaterReminderService.shared
    @ObservedObject private var phoneConnectivity = PhoneConnectivityManager.shared
    @ObservedObject private var storeManager = StoreManager.shared
    @State private var showMainApp = false
    @State private var showQuickSetup = false
    @State private var showReminderSetup = false
    @State private var showWhatsNew = false
    @AppStorage("lastSeenAppVersion") private var lastSeenAppVersion = ""

    // Check if running UI tests
    private var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains("UI_TESTING")
    }

    private var shouldSkipOnboarding: Bool {
        ProcessInfo.processInfo.arguments.contains("SKIP_ONBOARDING")
    }

    init() {
        _ = WaterReminderService.shared
        _ = PhoneConnectivityManager.shared
    }

    private func checkWhatsNew() {
        let current = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        if current != lastSeenAppVersion && !current.isEmpty {
            lastSeenAppVersion = current
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                showWhatsNew = true
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            if showMainApp || userProfileManager.hasCompletedOnboarding || shouldSkipOnboarding {
                ContentView()
                    .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                    .environmentObject(userProfileManager)
                    .environmentObject(achievementManager)
                    .environmentObject(phoneConnectivity)
                    .environmentObject(storeManager)
                    .accentColor(Color.mochaBrown)
                    .onAppear {
                        phoneConnectivity.sendDailyUpdate()
                        checkWhatsNew()
                        SmartNotificationScheduler.shared.rescheduleAll()
                    }
                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                        SmartNotificationScheduler.shared.rescheduleAll()
                    }
                    .sheet(isPresented: $showWhatsNew) {
                        WhatsNewView(isPresented: $showWhatsNew)
                    }
            } else if showReminderSetup {
                ReminderSetupView(showMainApp: $showMainApp)
            } else if showQuickSetup {
                QuickSetupView(showMainApp: $showMainApp, showReminderSetup: $showReminderSetup)
                    .environmentObject(userProfileManager)
            } else {
                WelcomeScreenView(showMainApp: $showMainApp, showQuickSetup: $showQuickSetup)
                    .environmentObject(userProfileManager)
            }
        }
    }
}

// MARK: - Welcome Screen
struct WelcomeScreenView: View {
    @EnvironmentObject var userProfileManager: UserProfileManager
    @Binding var showMainApp: Bool
    @Binding var showQuickSetup: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Top section with app icon and title
            VStack(spacing: 20) {
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Color(red: 127/255, green: 176/255, blue: 105/255))
                    .padding(.top, 60)

                Text("Welcome to")
                    .font(.title2)
                    .foregroundColor(.secondary)

                Text("Health Tracker")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Your Personal Health Companion")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top, 5)
            }

            Spacer()

            // Features list
            VStack(alignment: .leading, spacing: 20) {
                FeatureRow(icon: "camera.viewfinder", title: "AI Food Scanner", subtitle: "Snap a photo to instantly log any meal")
                FeatureRow(icon: "calendar", title: "Smart Meal Planning", subtitle: "4-week personalized meal plans")
                FeatureRow(icon: "figure.run", title: "Exercise & Step Tracking", subtitle: "Workouts, steps, and activity synced")
                FeatureRow(icon: "chart.line.uptrend.xyaxis", title: "Progress Insights", subtitle: "Visualize your health journey")
            }
            .padding(.horizontal, 30)

            Spacer()

            // Action buttons
            VStack(spacing: 15) {
                // Quick Setup button
                Button(action: {
                    showQuickSetup = true
                }) {
                    HStack {
                        Image(systemName: "bolt.fill")
                        Text("Quick Setup")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 127/255, green: 176/255, blue: 105/255))
                    .cornerRadius(12)
                }

                // Skip Setup button
                Button(action: {
                    // Create minimal default profile
                    let profile = UserProfile(name: "User", gender: .other, birthDate: Date())
                    userProfileManager.saveProfile(profile)
                    UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                    showMainApp = true
                }) {
                    Text("Skip Setup")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(UIColor.systemBackground), Color(UIColor.systemGray6)]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

// MARK: - Feature Row Component
struct FeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Color(red: 127/255, green: 176/255, blue: 105/255))
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
    }
}

// MARK: - Quick Setup View
struct QuickSetupView: View {
    @EnvironmentObject var userProfileManager: UserProfileManager
    @Binding var showMainApp: Bool
    @Binding var showReminderSetup: Bool

    @State private var name = ""
    @State private var selectedGender = Gender.other
    @State private var birthDate = Date()
    @State private var weight = ""
    @State private var activityLevel = ActivityLevel.moderate

    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Complete Setup button at the top
                Button(action: completeSetup) {
                    HStack {
                        Spacer()
                        Text("Complete Setup")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding()
                    .background(isValid ? Color(red: 127/255, green: 176/255, blue: 105/255) : Color.gray)
                    .cornerRadius(12)
                }
                .disabled(!isValid)
                .padding()

                Form {
                    Section("Basic Information") {
                        TextField("Name", text: $name)
                            .autocapitalization(.words)

                        Picker("Gender", selection: $selectedGender) {
                            ForEach(Gender.allCases, id: \.self) { gender in
                                Text(gender.rawValue).tag(gender)
                            }
                        }

                        DatePicker("Birth Date",
                                  selection: $birthDate,
                                  in: ...Date(),
                                  displayedComponents: .date)
                    }

                    Section("Physical Stats (Optional)") {
                        HStack {
                            TextField("Starting Weight", text: $weight)
                                .keyboardType(.decimalPad)
                            Text("lbs")
                                .foregroundColor(.secondary)
                        }
                    }

                    Section("Activity Level") {
                        Picker("How active are you?", selection: $activityLevel) {
                            ForEach(ActivityLevel.allCases, id: \.self) { level in
                                Text(level.rawValue).tag(level)
                            }
                        }
                        .pickerStyle(.menu)

                        Text(activityDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                // Skip button at the bottom
                Button(action: {
                    let profileName = name.isEmpty ? "User" : name
                    let profile = UserProfile(name: profileName, gender: .other, birthDate: Date())
                    userProfileManager.saveProfile(profile)
                    UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                    showReminderSetup = true
                }) {
                    Text("Skip Setup")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding()
                }
            }
            .navigationTitle("Quick Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        showMainApp = false
                    }
                }
            }
        }
    }

    private var activityDescription: String {
        switch activityLevel {
        case .sedentary: return "Little to no exercise"
        case .light: return "Light exercise 1-3 days per week"
        case .moderate: return "Moderate exercise 3-5 days per week"
        case .active: return "Hard exercise 6-7 days per week"
        case .veryActive: return "Very hard exercise & physical job"
        }
    }

    private func completeSetup() {
        // Create profile with all entered information
        var profile = UserProfile(
            name: name,
            gender: selectedGender,
            birthDate: birthDate
        )

        // Add optional fields if provided
        if let weightValue = Double(weight) {
            profile.startingWeight = weightValue
        }

        profile.activityLevel = activityLevel

        userProfileManager.saveProfile(profile)
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        showReminderSetup = true
    }
}

// MARK: - Reminder Setup View
struct ReminderSetupView: View {
    @Binding var showMainApp: Bool
    @ObservedObject private var settings = SmartReminderSettings.shared
    @State private var mealsEnabled = true
    @State private var permissionDenied = false

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 16) {
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 64))
                    .foregroundColor(Color(red: 127/255, green: 176/255, blue: 105/255))
                    .padding(.top, 60)

                Text("Stay on Track")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Meal reminders help you log consistently — which means better insights and faster progress.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
            }

            Spacer()

            VStack(spacing: 16) {
                Toggle(isOn: $mealsEnabled) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: "fork.knife")
                                .foregroundColor(Color(red: 127/255, green: 176/255, blue: 105/255))
                            Text("Meal Logging Reminders")
                                .font(.headline)
                        }
                        Text("Breakfast 8am · Lunch 12pm · Dinner 6pm")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(12)

                if permissionDenied {
                    Text("Notifications are blocked. Enable them in Settings → Notifications.")
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 30)

            Spacer()

            VStack(spacing: 12) {
                Button(action: enableAndContinue) {
                    Text("Enable & Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 127/255, green: 176/255, blue: 105/255))
                        .cornerRadius(12)
                }

                Button(action: { showMainApp = true }) {
                    Text("Skip for Now")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(UIColor.systemBackground), Color(UIColor.systemGray6)]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private func enableAndContinue() {
        guard mealsEnabled else {
            showMainApp = true
            return
        }
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                if granted {
                    settings.mealsEnabled = true
                    scheduleMealNotifications()
                } else {
                    permissionDenied = true
                }
                showMainApp = true
            }
        }
    }

    private func scheduleMealNotifications() {
        let center = UNUserNotificationCenter.current()
        let meals: [(String, String, Int)] = [
            ("smart_meal_breakfast", "🍳 Breakfast Time!", 8),
            ("smart_meal_lunch",     "🥗 Lunch Time!",    12),
            ("smart_meal_dinner",    "🍽️ Dinner Time!",  18)
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
}

// MARK: - What's New View
struct WhatsNewView: View {
    @Binding var isPresented: Bool

    private let features: [(icon: String, color: Color, title: String, detail: String)] = [
        ("camera.viewfinder", .blue, "Smarter AI Food Scanner", "Upgraded to the latest Claude model for more accurate meal recognition"),
        ("arrow.left.arrow.right", Color(red: 127/255, green: 176/255, blue: 105/255), "Swipeable Meal Planning", "Swipe through the week in Today view and add any day's meal to your diary"),
        ("calendar.badge.plus", .orange, "Add Week or Month to Diary", "Bulk-add an entire week or month of planned meals in one tap"),
        ("book.closed", .purple, "Log Recipes Directly", "Tap 'Log This Meal' on any recipe to add it straight to your food diary"),
        ("figure.walk", .teal, "Apple Watch Step Sync", "Step count now pulls from HealthKit so Apple Watch steps are included"),
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Image(systemName: "star.circle.fill")
                            .font(.system(size: 56))
                            .foregroundColor(.yellow)
                            .padding(.top, 20)

                        Text("What's New")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("Here's what's been updated in this version.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal)

                    VStack(spacing: 0) {
                        ForEach(features, id: \.title) { feature in
                            HStack(alignment: .top, spacing: 16) {
                                Image(systemName: feature.icon)
                                    .font(.title2)
                                    .foregroundColor(feature.color)
                                    .frame(width: 36)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(feature.title)
                                        .font(.headline)
                                    Text(feature.detail)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                            .padding()

                            if feature.title != features.last?.title {
                                Divider().padding(.leading, 52)
                            }
                        }
                    }
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)

                    Button(action: { isPresented = false }) {
                        Text("Continue")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(red: 127/255, green: 176/255, blue: 105/255))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            .navigationBarHidden(true)
        }
    }
}