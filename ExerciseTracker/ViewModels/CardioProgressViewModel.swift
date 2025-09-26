//
//  CardioProgressViewModel.swift
//  ExerciseTracker
//
//  Created by Mark A Stewart on 9/24/25.
//

import Foundation
import SwiftUI
import SwiftData

    /// A struct to hold aggregated cardio data for a single day.
struct AggregatedCardioData: Identifiable {
    let id = UUID()
    let date: Date
    let totalDistance: Double
    let totalCalories: Int
    let averagePace: Double
}

@Observable class CardioProgressViewModel {
    
        /// The aggregated data, published for the view to observe.
    var aggregatedData: [AggregatedCardioData] = []
    
    private var exercises: [CardioExercise] = []
    
    init(exercises: [CardioExercise]) {
        self.exercises = exercises
        self.aggregateData()
    }
    
        /// Public method to update the exercises array and re-aggregate data.
    func update(exercises: [CardioExercise]) {
        self.exercises = exercises
        self.aggregateData()
    }
    
    /// Aggregates raw exercise data into daily totals.
    func aggregateData() {
            // Group exercises by day.
        let groupedByDay = Dictionary(grouping: exercises) { exercise in
            Calendar.current.startOfDay(for: exercise.exerciseDate)
        }
        
            // Map the grouped data into AggregatedCardioData structs.
        self.aggregatedData = groupedByDay.map { (date, dailyExercises) in
            let totalDistance = dailyExercises.reduce(0.0) { $0 + $1.distance }
            let totalCalories = dailyExercises.reduce(0) { $0 + $1.calories }
            let totalDuration = dailyExercises.reduce(0.0) { $0 + $1.duration }
            
                // Calculate pace, handling potential division by zero
            let averagePace = totalDuration > 0 ? (totalDistance / totalDuration) * 60 : 0.0
            
            return AggregatedCardioData(
                date: date,
                totalDistance: totalDistance,
                totalCalories: totalCalories,
                averagePace: averagePace
            )
        }
        .sorted { $0.date < $1.date } // Sort by date for proper chart display
    }
}
