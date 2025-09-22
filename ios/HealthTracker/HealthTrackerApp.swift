import SwiftUI

@main
struct HealthTrackerApp: App {
    @StateObject private var userProfileManager = UserProfileManager()
    @State private var showMainApp = false

    var body: some Scene {
        WindowGroup {
            if showMainApp || userProfileManager.hasCompletedOnboarding {
                ContentView()
                    .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                    .environmentObject(userProfileManager)
                    .accentColor(Color.mochaBrown)
            } else {
                // Simplified onboarding with bypass option
                VStack(spacing: 30) {
                    Text("Welcome to Health Tracker")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, 50)

                    Text("Quick Setup")
                        .font(.title3)
                        .foregroundColor(.secondary)

                    Spacer()

                    // Direct bypass button
                    Button(action: {
                        // Create a default profile
                        let profile = UserProfile(name: "User", gender: .other, birthDate: Date())
                        userProfileManager.saveProfile(profile)
                        // Force navigation to main app
                        showMainApp = true
                    }) {
                        Text("Start Using App")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)

                    Button(action: {
                        // Alternative: just set the flag
                        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                        showMainApp = true
                    }) {
                        Text("Skip Setup")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                    .padding(.bottom, 30)
                }
                .environmentObject(userProfileManager)
            }
        }
    }
}