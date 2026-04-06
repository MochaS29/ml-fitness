import SwiftUI
import HealthKit
import CoreData

struct MoreView: View {
    @EnvironmentObject var userProfileManager: UserProfileManager
    @ObservedObject private var dataManager = UnifiedDataManager.shared
    @State private var showingProfile = false
    @State private var showingProgress = false
    @State private var showingFoodDatabase = false
    @State private var showingRecipes = false
    @State private var showingGoals = false
    @State private var showingReminders = false
    @State private var showingExport = false
    @State private var showingSettings = false
    @State private var showingHelp = false
    @State private var showingDemoDataAlert = false
    @AppStorage("hasDemoData") private var hasDemoData = false
    @State private var showingResetAlert = false
    @State private var showingResetConfirmation = false
    @State private var showingPaywall = false
    @EnvironmentObject var storeManager: StoreManager
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        List {
            UserProfileSection(showingProfile: $showingProfile)

            ProUpgradeSection(showingPaywall: $showingPaywall)

            ProgressAnalysisSection(showingGoals: $showingGoals)

            FoodRecipesSection(
                showingFoodDatabase: $showingFoodDatabase
            )

            #if DEBUG
            DeveloperToolsSection(viewContext: viewContext)
            #endif

            SettingsSupportSection(
                showingReminders: $showingReminders,
                showingExport: $showingExport,
                showingSettings: $showingSettings,
                showingHelp: $showingHelp,
                showingResetAlert: $showingResetAlert
            )

            // Developer Tools - Disabled for production release
            // Section("Developer Tools") {
            //     Button(action: { showingDemoDataAlert = true }) {
            //         HStack {
            //             Image(systemName: "wand.and.stars")
            //                 .foregroundColor(.blue)
            //             Text("Generate Demo Data")
            //                 .foregroundColor(.primary)
            //             Spacer()
            //             if hasDemoData {
            //                 Image(systemName: "checkmark.circle.fill")
            //                     .foregroundColor(.green)
            //             }
            //         }
            //     }
            //     .disabled(hasDemoData)
            //
            //     NavigationLink(destination: AppIconPreview()) {
            //         HStack {
            //             Image(systemName: "app.badge")
            //                 .foregroundColor(.purple)
            //             Text("App Icon Generator")
            //                 .foregroundColor(.primary)
            //         }
            //     }
            // }

            AppInfoSection()
        }
        .navigationTitle("More")
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
                .environmentObject(storeManager)
        }
        .sheet(isPresented: $showingFoodDatabase) {
            UnifiedFoodSearchSheet(mealType: .breakfast, targetDate: Date())
        }
        .sheet(isPresented: $showingProfile) {
            ProfileView()
        }
        .sheet(isPresented: $showingProgress) {
            NavigationView {
                ProfessionalProgressView()
            }
        }
        .sheet(isPresented: $showingGoals) {
            SimpleGoalsView()
        }
        .sheet(isPresented: $showingReminders) {
            RemindersView()
        }
        .sheet(isPresented: $showingExport) {
            ExportDataView()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showingHelp) {
            HelpView()
        }
        .alert("Generate Demo Data?", isPresented: $showingDemoDataAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Generate") {
                generateDemoData()
            }
        } message: {
            Text("This will create sample food, exercise, weight, and supplement entries for the past 30 days. This helps you see how the app looks with data.")
        }
        .alert("Reset All Data?", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                showingResetConfirmation = true
            }
        } message: {
            Text("This will permanently delete all your data including food entries, exercises, weight records, supplements, and custom foods. This action cannot be undone.")
        }
        .alert("Are You Sure?", isPresented: $showingResetConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete Everything", role: .destructive) {
                resetAllData()
            }
        } message: {
            Text("This is your final confirmation. All data will be permanently deleted and cannot be recovered.")
        }
    }

    private func generateDemoData() {
        let context = PersistenceController.shared.container.viewContext
        DemoDataGenerator.generateDemoData(context: context)
        hasDemoData = true
    }

    private func resetAllData() {
        // Delete all Food Entries
        let foodFetchRequest: NSFetchRequest<NSFetchRequestResult> = FoodEntry.fetchRequest()
        let foodDeleteRequest = NSBatchDeleteRequest(fetchRequest: foodFetchRequest)

        // Delete all Exercise Entries
        let exerciseFetchRequest: NSFetchRequest<NSFetchRequestResult> = ExerciseEntry.fetchRequest()
        let exerciseDeleteRequest = NSBatchDeleteRequest(fetchRequest: exerciseFetchRequest)

        // Delete all Weight Entries
        let weightFetchRequest: NSFetchRequest<NSFetchRequestResult> = WeightEntry.fetchRequest()
        let weightDeleteRequest = NSBatchDeleteRequest(fetchRequest: weightFetchRequest)

        // Delete all Supplement Entries
        let supplementFetchRequest: NSFetchRequest<NSFetchRequestResult> = SupplementEntry.fetchRequest()
        let supplementDeleteRequest = NSBatchDeleteRequest(fetchRequest: supplementFetchRequest)

        // Delete all Water Entries
        let waterFetchRequest: NSFetchRequest<NSFetchRequestResult> = WaterEntry.fetchRequest()
        let waterDeleteRequest = NSBatchDeleteRequest(fetchRequest: waterFetchRequest)

        // Delete all Custom Foods
        let customFoodFetchRequest: NSFetchRequest<NSFetchRequestResult> = CustomFood.fetchRequest()
        let customFoodDeleteRequest = NSBatchDeleteRequest(fetchRequest: customFoodFetchRequest)

        // Delete all User Goals (if they exist)
        // Note: Commenting out as DailyGoals entity might not exist
        // let goalsRequest: NSFetchRequest<NSFetchRequestResult> = DailyGoals.fetchRequest()
        // let goalsDeleteRequest = NSBatchDeleteRequest(fetchRequest: goalsRequest)

        // Execute all delete requests
        do {
            try viewContext.execute(foodDeleteRequest)
            try viewContext.execute(exerciseDeleteRequest)
            try viewContext.execute(weightDeleteRequest)
            try viewContext.execute(supplementDeleteRequest)
            try viewContext.execute(waterDeleteRequest)
            try viewContext.execute(customFoodDeleteRequest)
            // try viewContext.execute(goalsDeleteRequest)

            // Save the context
            try viewContext.save()

            // Reset the demo data flag
            hasDemoData = false

            // Reset the user profile to trigger welcome screen
            userProfileManager.resetProfile()

            // Force refresh the UI
            // The data will automatically refresh via Core Data observers

        } catch {
            print("Error resetting data: \(error)")
        }
    }
}

// #Preview {
//     MoreView()
//         .environmentObject(UserProfileManager())
//         .environmentObject(AchievementManager())
// }
