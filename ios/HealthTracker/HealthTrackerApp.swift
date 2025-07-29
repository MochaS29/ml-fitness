import SwiftUI

@main
struct HealthTrackerApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var userProfileManager = UserProfileManager()
    @AppStorage("hasDemoData") private var hasDemoData = false
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            if userProfileManager.hasCompletedOnboarding {
                ContentView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(userProfileManager)
                    .accentColor(Color.mochaBrown)
                    .onAppear {
                        importSampleDataIfNeeded()
                        
                        // Check if we should generate demo data
                        if CommandLine.arguments.contains("--demo") || ProcessInfo.processInfo.environment["GENERATE_DEMO_DATA"] == "true" {
                            generateDemoData()
                        }
                    }
            } else {
                OnboardingView()
                    .environmentObject(userProfileManager)
                    .accentColor(Color.mochaBrown)
            }
        }
    }
    
    func importSampleDataIfNeeded() {
        let hasImportedKey = "hasImportedSampleData"
        let hasImportedOpenRecipesKey = "hasImportedOpenRecipes"
        let userDefaults = UserDefaults.standard
        
        let context = persistenceController.container.viewContext
        
        if !userDefaults.bool(forKey: hasImportedKey) {
            SampleDataImporter.importSampleUSDAFoods(context: context)
            SampleDataImporter.importSampleUserRecipes(context: context)
            userDefaults.set(true, forKey: hasImportedKey)
        }
        
        // Import open recipes if not already done
        if !userDefaults.bool(forKey: hasImportedOpenRecipesKey) {
            OpenRecipeImporter.importOpenRecipes(context: context)
            userDefaults.set(true, forKey: hasImportedOpenRecipesKey)
        }
    }
    
    func generateDemoData() {
        if !hasDemoData {
            let context = persistenceController.container.viewContext
            DemoDataGenerator.generateDemoData(context: context)
            hasDemoData = true
            print("Demo data generated successfully!")
        }
    }
}