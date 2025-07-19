//
//  HealthTrackerApp.swift
//  HealthTracker
//
//  Created by Mocha Shmigelsky on 2025-07-18.
//

import SwiftUI

@main
struct HealthTrackerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
