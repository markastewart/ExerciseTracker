//
//  CardioProgressViewModel.swift
//  ExerciseTracker
//
//  Created by Mark A Stewart on 9/24/25.

import Foundation
import SwiftData

    /// The aggregated data structure must conform to the ProgressData protocol.
struct AggregatedCardioData: ProgressData {
    let id = UUID()
    let aggregationStartDate: Date
    let totalDistance: Double
    let totalCalories: Int
    let averagePace: Double
}

@Observable class CardioProgressViewModel {
    var aggregatedData: [AggregatedCardioData] = []
    
    private var allExercises: [CardioExercise] = []
    private(set) var startDate: Date
    private(set) var endDate: Date
    
        /// Accessor for the dynamic aggregator instance (Non-generic class).
    private var aggregator: ExerciseProgressAggregator {
        return ExerciseProgressAggregator()
    }
    
        /// Accesses the aggregator's formatter for chart X-axis labeling.
    var xAxisDateFormatter: DateFormatter {
        return aggregator.xAxisDateFormatter
    }
    
        /// Accesses the aggregator's unit for view logic (if needed).
    var aggregationUnit: AggregationUnit {
        return aggregator.aggregationUnit
    }
    
        /// Filters the exercises based on the current range.
    var filteredExercises: [CardioExercise] {
        return allExercises.filter { $0.exerciseDate >= startDate.startOfDay && $0.exerciseDate <= endDate.endOfDay }
    }
    
    init(exercises: [CardioExercise], startDate: Date, endDate: Date) {
        self.allExercises = exercises
        self.startDate = startDate
        self.endDate = endDate
        aggregateData()
    }
    
    func update(exercises: [CardioExercise], startDate: Date, endDate: Date) {
        if self.allExercises.count != exercises.count || self.startDate != startDate || self.endDate != endDate {
            self.allExercises = exercises
            self.startDate = startDate
            self.endDate = endDate
            aggregateData()
        }
    }
    
        /// Uses the DateProgressAggregator for temporal grouping and handles the data-specific aggregation.
    func aggregateData() {
        
            // Define the data-specific aggregation logic
        let dataAggregator: (Date, [CardioExercise]) -> AggregatedCardioData = { dateKey, exercisesForPeriod in
            
            let totalDistance = exercisesForPeriod.reduce(0.0) { $0 + $1.distance }
            let totalCalories = exercisesForPeriod.reduce(0) { $0 + $1.calories }
            let totalDuration = exercisesForPeriod.reduce(0.0) { $0 + $1.duration }
            
                // Calculate average pace
            let averagePace = totalDuration > 0 ? (totalDistance / totalDuration) * 60 : 0.0
            
            return AggregatedCardioData(
                aggregationStartDate: dateKey,
                totalDistance: totalDistance,
                totalCalories: totalCalories,
                averagePace: averagePace
            )
        }
        
            // Define the zero-padding data creator
        let zeroDataCreator: (Date) -> AggregatedCardioData = { dateKey in
            return AggregatedCardioData(
                aggregationStartDate: dateKey,
                totalDistance: 0.0,
                totalCalories: 0,
                averagePace: 0.0
            )
        }
        
            // Perform the aggregation using the service
        aggregatedData = aggregator.aggregate(
            rawExercises: allExercises,
            startDate: startDate,
            endDate: endDate,
            zeroData: zeroDataCreator,
            dataAggregator: dataAggregator
        )
    }
}
