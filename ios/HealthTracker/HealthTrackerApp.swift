import SwiftUI

@main
struct HealthTrackerApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var userProfileManager = UserProfileManager()
    @AppStorage("hasDemoData") private var hasDemoData = false
    
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
        let userDefaults = UserDefaults.standard
        
        if !userDefaults.bool(forKey: hasImportedKey) {
            let context = persistenceController.container.viewContext
            SampleDataImporter.importSampleUSDAFoods(context: context)
            SampleDataImporter.importSampleUserRecipes(context: context)
            userDefaults.set(true, forKey: hasImportedKey)
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