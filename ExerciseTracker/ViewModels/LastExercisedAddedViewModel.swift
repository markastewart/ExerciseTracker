//
//  LastExercisedAddedViewModel.swift
//  ExerciseTracker
//
//  Created by Mark A Stewart on 10/2/25.
//

import Foundation
import SwiftData
import Combine

@Observable class LastExerciseAddedViewModel {
    var lastExercise: AnyExercise? = nil
    private let dataService = ExerciseDataService.shared

    init() {
        refreshLastExercise()
    }

    func refreshLastExercise() {
            // Fetch newest Cardio
        if let modelContext = dataService.modelContext {
            
            let latestCardio = try? modelContext.fetch (
                FetchDescriptor<CardioExercise>( sortBy: [SortDescriptor(\.recordedDate, order: .reverse)])
            ).first
            
            let latestStrength = try? modelContext.fetch(
                FetchDescriptor<StrengthExercise>(sortBy: [SortDescriptor(\.recordedDate, order: .reverse)])
            ).first
            
            switch (latestCardio, latestStrength) {
                case let (cardio?, strength?):
                    lastExercise = cardio.recordedDate >= strength.recordedDate ? .cardio(cardio) : .strength(strength)
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
