//
//  CardioProgressViewModel.swift
//  ExerciseTracker
//
//  Created by Mark A Stewart on 9/24/25.
//

import Foundation
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
    private var startDate: Date = Date()
    private var endDate: Date = Date()
    
    init(exercises: [CardioExercise], startDate: Date, endDate: Date) {
        self.exercises = exercises
        self.startDate = startDate
        self.endDate = endDate
        self.aggregateData()
    }
    
        /// Public method to update the exercises array and re-aggregate data.
    func update(exercises: [CardioExercise], startDate: Date, endDate: Date) {
        self.exercises = exercises
        self.startDate = startDate
        self.endDate = endDate
        self.aggregateData()
    }
    
        /// Aggregates raw exercise data into daily totals, padding with zero entries for missing days.
    func aggregateData() {
        let calendar = Calendar.current
        
            // Aggregate actual data into a dictionary keyed by the date's startOfDay
        let actualData: [Date: AggregatedCardioData] = Dictionary(grouping: exercises) { exercise in
            calendar.startOfDay(for: exercise.exerciseDate)
        }
        .compactMapValues { dailyExercises in
            let date = calendar.startOfDay(for: dailyExercises.first!.exerciseDate)
            let totalDistance = dailyExercises.reduce(0.0) { $0 + $1.distance }
            let totalCalories = dailyExercises.reduce(0) { $0 + $1.calories }
            let totalDuration = dailyExercises.reduce(0.0) { $0 + $1.duration }
            
                // Calculate pace: distance/time * 60 (to get units per minute)
            let averagePace = totalDuration > 0 ? (totalDistance / totalDuration) * 60 : 0.0
            
            return AggregatedCardioData(
                date: date,
                totalDistance: totalDistance,
                totalCalories: totalCalories,
                averagePace: averagePace
            )
        }
        
            // Generate a list of all dates in the range. Normalize the dates to startOfDay
        var date = calendar.startOfDay(for: startDate)
        let endOfRange = calendar.startOfDay(for: endDate)
        var fullDateRange: [Date] = []
        
        while date <= endOfRange {
            fullDateRange.append(date)
            date = calendar.date(byAdding: .day, value: 1, to: date)!
        }
        
            // Merge the full date range with the actual data, filling in zeros
        self.aggregatedData = fullDateRange.map { day in
            if let data = actualData[day] {
                return data
            } else {
                // Pad with zero data for days without exercises
                return AggregatedCardioData(
                    date: day,
                    totalDistance: 0.0,
                    totalCalories: 0,
                    averagePace: 0.0
                )
            }
        }
        .sorted { $0.date < $1.date }
    }
}
