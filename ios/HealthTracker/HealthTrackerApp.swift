import SwiftUI

@main
struct HealthTrackerApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var userProfileManager = UserProfileManager()
    
    var body: some Scene {
        WindowGroup {
            if userProfileManager.hasCompletedOnboarding {
                ContentView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(userProfileManager)
                    .accentColor(Color.mochaBrown)
                    .onAppear {
                        importSampleDataIfNeeded()
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
}