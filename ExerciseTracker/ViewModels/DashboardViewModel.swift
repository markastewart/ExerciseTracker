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
    /// The most recent exercise of either type
    @Published var lastExercise: AnyExercise?

    private let context: ModelContext
    private var cancellable: AnyCancellable?

    // MARK: - Init
    init(context: ModelContext) {
        self.context = context

        // Listen for any changes in the context (insert/update/delete)
        cancellable = NotificationCenter.default
            .publisher(for: .NSManagedObjectContextObjectsDidChange, object: context)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.refreshLastExercise()
            }

        // Initial fetch
        refreshLastExercise()
    }

    // MARK: - Helpers
    private func refreshLastExercise() {
        // Fetch newest Cardio
        let latestCardio = try? context.fetch(
            FetchDescriptor<CardioExercise>(
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
        ).first

        // Fetch newest Strength
        let latestStrength = try? context.fetch(
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
}
