import SwiftUI

@main
struct HealthTrackerApp: App {
    @StateObject private var userProfileManager = UserProfileManager()
    @StateObject private var achievementManager = AchievementManager.shared
    @StateObject private var waterReminderService = WaterReminderService.shared
    @State private var showMainApp = false
    @State private var showQuickSetup = false

    init() {
        // Initialize water reminder service to set up notification delegate
        _ = WaterReminderService.shared
    }

    var body: some Scene {
        WindowGroup {
            if showMainApp || userProfileManager.hasCompletedOnboarding {
                ContentView()
                    .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                    .environmentObject(userProfileManager)
                    .environmentObject(achievementManager)
                    .accentColor(Color.mochaBrown)
            } else if showQuickSetup {
                QuickSetupView(showMainApp: $showMainApp)
                    .environmentObject(userProfileManager)
            } else {
                // Welcome screen with setup options
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
                FeatureRow(icon: "fork.knife", title: "Track Nutrition", subtitle: "Log meals and monitor calories")
                FeatureRow(icon: "figure.run", title: "Exercise Tracking", subtitle: "Record workouts and activities")
                FeatureRow(icon: "chart.line.uptrend.xyaxis", title: "Progress Insights", subtitle: "Visualize your health journey")
                FeatureRow(icon: "target", title: "Set Goals", subtitle: "Achieve your wellness targets")
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
                    // Create minimal profile with entered name if available
                    let profileName = name.isEmpty ? "User" : name
                    let profile = UserProfile(name: profileName, gender: .other, birthDate: Date())
                    userProfileManager.saveProfile(profile)
                    UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                    showMainApp = true
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

        // Save profile and navigate to main app
        userProfileManager.saveProfile(profile)
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        showMainApp = true
    }
}