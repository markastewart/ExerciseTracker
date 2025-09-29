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
    private var startDate: Date = Date()
    private var endDate: Date = Date()
    
    init(exercises: [StrengthExercise], startDate: Date, endDate: Date) {
        self.exercises = exercises
        self.startDate = startDate
        self.endDate = endDate
        aggregateData()
    }
    
        /// Public method to update the exercises array and re-aggregate data.
    func update(exercises: [StrengthExercise], startDate: Date, endDate: Date) {
        self.exercises = exercises
        self.startDate = startDate
        self.endDate = endDate
        aggregateData()
    }

        /// Aggregates raw exercise data into daily totals, padding with zero entries for missing days.
    func aggregateData() {
        let calendar = Calendar.current
        
            // Aggregate the actual data into a dictionary keyed by the date's startOfDay
        let actualData: [Date: AggregatedStrengthData] = Dictionary(grouping: exercises) { exercise in
            calendar.startOfDay(for: exercise.exerciseDate)
        }
        .compactMapValues { dailyExercises in
            let date = calendar.startOfDay(for: dailyExercises.first!.exerciseDate)
            let totalWeightLifted = dailyExercises.reduce(0) { $0 + ($1.weight * $1.sets * $1.reps) }
            
            return AggregatedStrengthData(
                date: date,
                totalWeightLifted: totalWeightLifted,
            )
        }
        
            // Generate a list of all dates in the range
        var date = calendar.startOfDay(for: startDate)
        let endOfRange = calendar.startOfDay(for: endDate)
        var fullDateRange: [Date] = []
        
        while date <= endOfRange {
            fullDateRange.append(date)
            date = calendar.date(byAdding: .day, value: 1, to: date)!
        }
        
                // Merge the full date range with the actual data, filling in zeros
            aggregatedData = fullDateRange.map { day in
            if let data = actualData[day] {
                return data
            } else {
                    // Pad with zero data for days without exercises
                return AggregatedStrengthData(
                    date: day,
                    totalWeightLifted: 0,
                )
            }
        }
        .sorted { $0.date < $1.date }
    }
}
