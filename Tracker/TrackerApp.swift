//
//  TrackerApp.swift
//  Tracker
//
//  Created by Jesus Lopez on 1/31/24.
//

import SwiftUI
import SwiftData

@main
struct TrackerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Exercise.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false, cloudKitDatabase: .none)

        do {
            return try ModelContainer(
                for: schema,
                migrationPlan: MigrationPlan.self,
                configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ExercisesView()
        }
        .modelContainer(sharedModelContainer)
    }
}
