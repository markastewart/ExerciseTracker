//
//  StrengthProgressViewModel.swift
//  ExerciseTracker
//
//  Created by Mark A Stewart on 9/26/25.
//

import Foundation
import SwiftData

    /// A struct to hold aggregated strength data for a single day.
struct AggregatedStrengthData: Identifiable {
    let id = UUID()
    let date: Date
    let totalWeightLifted: Int
}

@Observable class StrengthProgressViewModel {
    
        /// The aggregated data, published for the view to observe.
    var aggregatedData: [AggregatedStrengthData] = []
    
    private var exercises: [StrengthExercise] = []
    
    init(exercises: [StrengthExercise]) {
        self.exercises = exercises
        self.aggregateData()
    }
    
        /// Public method to update the exercises array and re-aggregate data.
    func update(exercises: [StrengthExercise]) {
        self.exercises = exercises
        self.aggregateData()
    }

        /// Aggregates raw exercise data into daily totals.
    func aggregateData() {
            // Group exercises by day.
        let groupedByDay = Dictionary(grouping: exercises) { exercise in
            Calendar.current.startOfDay(for: exercise.exerciseDate)
        }
            // Map the grouped data into AggregatedStrengthData structs. totalWeightLifted = SUM(weight * sets * reps) for all entries on that day
        self.aggregatedData = groupedByDay.map { (date, dailyExercises) in
            let totalWeightLifted = dailyExercises.reduce(0) { $0 + ($1.weight * $1.sets * $1.reps) }
            return AggregatedStrengthData(date: date, totalWeightLifted: totalWeightLifted)
        }
        .sorted { $0.date < $1.date } // Sort by date for proper chart display
    }
}
