//
//  ExerciseTrackerApp.swift
//  ExerciseTracker
//
//  Created by Mark A Stewart on 8/27/25.
//

import SwiftUI
import SwiftData

@main
struct ExerciseApp: App {
    
        // Create the ModelContainer for the entire app.
    let sharedModelContainer: ModelContainer = {
        let schema = Schema([
            CardioExercise.self,
            StrengthExercise.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            if let url = try! ModelContainer(for: schema, configurations: [modelConfiguration]).configurations.first?.url {
                print("SwiftData DB Path: \(url.path)")
            }
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            DashboardView(viewModel: DashboardViewModel())
                .environment(\.modelContext, sharedModelContainer.mainContext)
        }
        .modelContainer(sharedModelContainer)
    }
    
        // A temporary workaround to set the ModelContext in the data service
        // This is not standard but necessary for this code to work as presented
        // without using a fully-fledged Dependency Injection framework.
    init() {
        ExerciseDataService.shared.setModelContext(sharedModelContainer.mainContext)
    }
}
