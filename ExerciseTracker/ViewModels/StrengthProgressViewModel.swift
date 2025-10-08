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
    private let dateRangeService: DateRangeService
    private var allExercises: [StrengthExercise] = []
    private let axisConfig = ProgressViewAxisConfig()
    
        /// Accessor for the dynamic aggregator instance (Non-generic class).
    private var aggregator: ExerciseProgressAggregator {
        return ExerciseProgressAggregator()
    }
    
        /// Provides the explicit end date for the chart's X-axis domain to prevent the last label from clipping.
    var xAxisDomainEnd: Date? {
        return axisConfig.xAxisDomainEnd(aggregatedData: aggregatedData,
            selectedDateRange: dateRangeService.aggregationPeriod
        )
    }
    
        /// Accesses the aggregator's formatter for chart X-axis labeling.
    var xAxisDateFormatter: DateFormatter {
        return aggregator.xAxisDateFormatter(aggregationPeriod: dateRangeService.aggregationPeriod)
    }
    
        /// Provides the explicit dates to mark on the X-axis.
    var xAxisLabelDates: [Date] {
        return axisConfig.xAxisLabelDates(
            aggregatedData: aggregatedData,
            selectedDateRange: dateRangeService.aggregationPeriod
        )
    }
    
        /// Filters the exercises based on the current range (kept for simplicity and debugging).
    var filteredExercises: [StrengthExercise] {
        return allExercises.filter { $0.exerciseDate >= dateRangeService.startDate.startOfDay && $0.exerciseDate <= dateRangeService.endDate.endOfDay }
    }
    
    init(exercises: [StrengthExercise], dateRangeService: DateRangeService) {
        self.allExercises = exercises
        self.dateRangeService = dateRangeService
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleDateRangeUpdate), name: .didUpdateDateRange, object: nil)
        
        aggregateData()
    }
    
        // Cleanup observer
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
        // Selector method called by NotificationCenter. When DateRangeService changes dates, re-aggregate the data.
    @objc private func handleDateRangeUpdate() {
        aggregateData()
    }
    
        // Re-aggregate if the raw data has actually changed.
    func update(exercises: [StrengthExercise]) {
        if self.allExercises.count != exercises.count {
            self.allExercises = exercises
            aggregateData()
        }
    }
    
        /// Aggregates raw exercise data into dynamic buckets (Day, Week, Month, or Year).
    func aggregateData() {
        let currentStartDate = dateRangeService.startDate
        let currentEndDate = dateRangeService.endDate
        let currentAggregationPeriod = dateRangeService.aggregationPeriod
        
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
            startDate: currentStartDate,
            endDate: currentEndDate,
            aggregationPeriod: currentAggregationPeriod,
            zeroData: zeroDataCreator,
            dataAggregator: dataAggregator
        )
    }
}
