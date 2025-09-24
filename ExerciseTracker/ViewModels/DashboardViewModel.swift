//
//  DashboardViewModel.swift
//  ExerciseTracker
//
//  Created by Mark A Stewart on 9/20/25.
//

import Foundation
import SwiftData
import Combine

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
            
            let latestCardio = try? modelContext.fetch (
                FetchDescriptor<CardioExercise>( sortBy: [SortDescriptor(\.exerciseDate, order: .reverse)])
            ).first
            
            let latestStrength = try? modelContext.fetch(
                FetchDescriptor<StrengthExercise>(sortBy: [SortDescriptor(\.exerciseDate, order: .reverse)])
            ).first
            
            switch (latestCardio, latestStrength) {
                case let (cardio?, strength?):
                    lastExercise = cardio.exerciseDate >= strength.exerciseDate ? .cardio(cardio) : .strength(strength)
                case let (cardio?, nil):
                    lastExercise = .cardio(cardio)
                case let (nil, strength?):
                    lastExercise = .strength(strength)
                default:
                    lastExercise = nil
            }
        }
        else {
            fatalError("Error: Unable to obtain modelContext")
        }
    }
}
