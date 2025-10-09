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
    let averageCalories: Int
    let averagePace: Double
}

@Observable class CardioProgressViewModel {
    var aggregatedData: [AggregatedCardioData] = []
    private let dateRangeService: DateRangeService
    private var allExercises: [CardioExercise] = []
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
    
        /// Filters the exercises based on the current range.
    var filteredExercises: [CardioExercise] {
        return allExercises.filter { $0.exerciseDate >= dateRangeService.startDate.startOfDay && $0.exerciseDate <= dateRangeService.endDate.endOfDay }
    }
    
    init(exercises: [CardioExercise], dateRangeService: DateRangeService) {
        self.allExercises = exercises
        self.dateRangeService = dateRangeService
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleExerciseDataUpdate), name: .didUpdateExerciseData, object: nil)
        
        aggregateData()
    }
    
        // Called when existing data is saved/updated and need to reaggregate data for display
    @objc private func handleExerciseDataUpdate() {
        aggregateData()
    }
    
    func update(exercises: [CardioExercise]) {
        if allExercises.count != exercises.count {
            allExercises = exercises
            aggregateData()
        }
    }
        /// Uses the DateProgressAggregator for temporal grouping and handles the data-specific aggregation.
    func aggregateData() {
        let currentStartDate = dateRangeService.startDate
        let currentEndDate = dateRangeService.endDate
        let currentAggregationPeriod = dateRangeService.aggregationPeriod
        
            // Define the data-specific aggregation logic
        let dataAggregator: (Date, [CardioExercise]) -> AggregatedCardioData = { dateKey, exercisesForPeriod in
            
            let totalDistance = exercisesForPeriod.reduce(0.0) { $0 + $1.distance }
            let totalCalories = exercisesForPeriod.reduce(0) { $0 + $1.calories }
            let totalDuration = exercisesForPeriod.reduce(0.0) { $0 + $1.duration }
            let totalCardioExercises = exercisesForPeriod.count
            
                // Calculate average pace and average calories
            let averagePace = totalDuration > 0 ? (totalDistance / totalDuration) * 60 : 0.0
            let averageCalories = totalCardioExercises > 0 ? (totalCalories / Int(totalCardioExercises)) : 0
            
            return AggregatedCardioData(
                aggregationStartDate: dateKey,
                totalDistance: totalDistance,
                averageCalories: averageCalories,
                averagePace: averagePace
            )
        }
            // Define the zero-padding data creator
        let zeroDataCreator: (Date) -> AggregatedCardioData = { dateKey in
            return AggregatedCardioData(
                aggregationStartDate: dateKey,
                totalDistance: 0.0,
                averageCalories: 0,
                averagePace: 0.0
            )
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
