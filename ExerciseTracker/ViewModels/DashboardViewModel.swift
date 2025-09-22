//
//  DashboardViewModel.swift
//  ExerciseTracker
//
//  Created by Mark A Stewart on 9/20/25.
//

import Foundation
import SwiftData
import Combine

/// Enum to unify Cardio and Strength exercises
enum AnyExercise: Identifiable {
    case cardio(CardioExercise)
    case strength(StrengthExercise)

    var id: PersistentIdentifier {
        switch self {
        case .cardio(let c): return c.persistentModelID
        case .strength(let s): return s.persistentModelID
        }
    }

    var timestamp: Date {
        switch self {
        case .cardio(let c): return c.timestamp
        case .strength(let s): return s.timestamp
        }
    }
}

final class DashboardViewModel: ObservableObject {
    @Published var lastExercise: AnyExercise?
    
    private let dataService = ExerciseDataService.shared
    private var cancellable: AnyCancellable?

    // MARK: - Init
    init() {
            // Listen for any changes in the context (insert/update/delete)
        if let modelContext = dataService.modelContext {
            cancellable = NotificationCenter.default
                .publisher(for: .NSManagedObjectContextObjectsDidChange, object: modelContext)
                .receive(on: RunLoop.main)
                .sink { [weak self] _ in
                    self?.refreshLastExercise()
                }
        }
            // Initial fetch
        refreshLastExercise()
    }

    // MARK: - Helpers
    func refreshLastExercise() {
            // Fetch newest Cardio
        if let modelContext = dataService.modelContext {
            let latestCardio = try? modelContext.fetch(
                FetchDescriptor<CardioExercise>(
                    sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
                )
            ).first
            
                // Fetch newest Strength
            let latestStrength = try? modelContext.fetch(
                FetchDescriptor<StrengthExercise>(
                    sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
                )
            ).first
            
                // Determine most recent
            switch (latestCardio, latestStrength) {
                case let (c?, s?):
                    lastExercise = c.timestamp >= s.timestamp ? .cardio(c) : .strength(s)
                case let (c?, nil):
                    lastExercise = .cardio(c)
                case let (nil, s?):
                    lastExercise = .strength(s)
                default:
                    lastExercise = nil
            }
        }
        else {
            fatalError("Error: Unable to obtain modelContext")
        }
    }
}
