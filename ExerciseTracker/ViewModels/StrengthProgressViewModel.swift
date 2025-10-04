//
//  StrengthProgressViewModel.swift
//  ExerciseTracker
//
//  Created by Mark A Stewart on 9/26/25.
//

import Foundation
import SwiftData

    /// The aggregated data structure must conform to the ProgressData protocol.
struct AggregatedStrengthData: ProgressData {
    let id = UUID()
    let aggregationStartDate: Date
    let totalWeightLifted: Int
}

@Observable class StrengthProgressViewModel {
    var aggregatedData: [AggregatedStrengthData] = []
    
    private var allExercises: [StrengthExercise] = []
    private(set) var startDate: Date
    private(set) var endDate: Date
    
        /// Accessor for the dynamic aggregator instance (Non-generic class).
    private var aggregator: ExerciseProgressAggregator {
        return ExerciseProgressAggregator()
    }
    
        /// Determines the appropriate aggregation unit based on the date range length.
    var aggregationUnit: AggregationPeriod {
        return aggregator.aggregationPeriod
    }
    
        /// Provides the correct formatter for the X-axis based on the current aggregation unit.
    var xAxisDateFormatter: DateFormatter {
        return aggregator.xAxisDateFormatter
    }
    
        /// Filters the exercises based on the current range (kept for simplicity and debugging).
    var filteredExercises: [StrengthExercise] {
        return allExercises.filter { $0.exerciseDate >= startDate.startOfDay && $0.exerciseDate <= endDate.endOfDay }
    }
    
    init(exercises: [StrengthExercise], startDate: Date, endDate: Date) {
        self.allExercises = exercises
        self.startDate = startDate
        self.endDate = endDate
        aggregateData()
    }
    
        // Re-aggregate if the raw data or range has actually changed.
    func update(exercises: [StrengthExercise], startDate: Date, endDate: Date) {
        if self.allExercises.count != exercises.count || self.startDate != startDate || self.endDate != endDate {
            self.allExercises = exercises
            self.startDate = startDate
            self.endDate = endDate
            aggregateData()
        }
    }
    
        /// Aggregates raw exercise data into dynamic buckets (Day, Week, Month, or Year).
    func aggregateData() {
        
            // Define the data-specific aggregation logic
        let dataAggregator: (Date, [StrengthExercise]) -> AggregatedStrengthData = { dateKey, exercisesForPeriod in
            
                // Strength Aggregation Calculation: Total Weight Lifted = Sum of (Weight * Sets * Reps)
            let totalWeightLifted = exercisesForPeriod.reduce(0) {
                    $0 + ($1.weight * $1.sets * $1.reps) }
            
            return AggregatedStrengthData(aggregationStartDate: dateKey, totalWeightLifted: totalWeightLifted)
        }
            // Define the zero-padding data creator
        let zeroDataCreator: (Date) -> AggregatedStrengthData = { dateKey in
            return AggregatedStrengthData(aggregationStartDate: dateKey, totalWeightLifted: 0)
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
