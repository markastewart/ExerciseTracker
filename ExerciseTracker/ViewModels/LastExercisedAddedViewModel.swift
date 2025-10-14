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
    var pace: Double = 0.0
    var totalWeight: Int = 0

    func refreshLastExercise(allCardio: [CardioExercise], allStrength: [StrengthExercise]) {
        
            // Use the first (latest) item from the live, sorted @Query arrays
        let latestCardio = allCardio.first
        let latestStrength = allStrength.first
        
        switch (latestCardio, latestStrength) {
            case let (cardio?, strength?):
                lastExercise = cardio.recordedDate >= strength.recordedDate ? .cardio(cardio) : .strength(strength)
                pace = calculatePace(totalDistance: cardio.distance, totalDuration: cardio.duration)
                totalWeight = calculateWeightLifted(weight: strength.weight, sets: strength.sets, reps: strength.reps)
            case let (cardio?, nil):
                lastExercise = .cardio(cardio)
                pace = calculatePace(totalDistance: cardio.distance, totalDuration: cardio.duration)
            case let (nil, strength?):
                lastExercise = .strength(strength)
                totalWeight = calculateWeightLifted(weight: strength.weight, sets: strength.sets, reps: strength.reps)
            default:
                lastExercise = nil
        }
    }
}
