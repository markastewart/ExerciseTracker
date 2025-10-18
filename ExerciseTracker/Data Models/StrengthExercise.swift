//
//  StrengthExercise.swift
//  ExerciseTracker
//
//  Created by Mark A Stewart on 8/29/25.
//

import Foundation
import SwiftData

@Model
final class StrengthExercise: Exercise {
    var exerciseDate: Date = Date.now
    var exerciseType: String = ""
    var sets: Int = 0
    var reps: Int = 0
    var weight: Double = 0.0
    var recordedDate: Date = Date.now

    init() {
    }
    
    enum columnIndex: Int, CaseIterable {
        case exerciseDate = 0
        case exerciseType = 1
        case sets = 2
        case reps = 3
        case weight = 4
        case recordedDate = 5
    }
}

    // A statistics calculator initialized with a specific, filtered set of exercises. All requested calculations are available as computed properties.
struct StrengthStats {
    private let dataService = ExerciseDataService.shared
    private var filteredExercises: [StrengthExercise] = []
    
    
    init(exerciseType: String) {
        let allExercises = dataService.fetchAllStrengthExercises() ?? []
        self.filteredExercises = allExercises.filter { $0.exerciseType == exerciseType }
    }
    
        // Calculates average total weight (total weight / total count) across all filtered exercises.
    var averageTotalWeight: Double {
        let measurableWorkouts = filteredExercises.filter { $0.weight > 0 }
        
        guard !measurableWorkouts.isEmpty else {
            return 0.0
        }
        let totalWeight = measurableWorkouts.reduce(0) { $0 + calculateWeightLifted(weight: $1.weight, sets: $1.sets, reps: $1.reps) }
        return totalWeight / Double (measurableWorkouts.count)
    }
    
        // Retrieve personal best maximum total weightin a single session. Returns 0.0 if no exercises are present.
    var personalBestTotalWeight: Double {
        return filteredExercises.map { calculateWeightLifted(weight: $0.weight, sets: $0.sets, reps: $0.reps) }.max() ?? 0.0
    }
}
