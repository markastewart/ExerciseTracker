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
    private let dateRangeService: DateRangeService
    private var allExercises: [CardioExercise] = []
    
        /// Accessor for the dynamic aggregator instance (Non-generic class).
    private var aggregator: ExerciseProgressAggregator {
        return ExerciseProgressAggregator()
    }
    
        /// Accesses the aggregator's formatter for chart X-axis labeling.
    var xAxisDateFormatter: DateFormatter {
        return aggregator.xAxisDateFormatter(aggregationPeriod: dateRangeService.aggregationPeriod)
    }
    
    var xAxisStrideUnit: Calendar.Component {
        let currentAggregationPeriod = dateRangeService.aggregationPeriod
        switch currentAggregationPeriod {
            case .daily: return .day
            case .weekly: return .weekOfYear
            case .monthly: return .month
            case .yearly: return .year
        }
    }
    
    var xAxisStrideCount: Int {
        let currentAggregationPeriod = dateRangeService.aggregationPeriod
        if currentAggregationPeriod == .monthly {
                // For monthly views (like 12 months), step by 3 to only label every quarter (Jan, Apr, Jul, Oct)
            return 3
        }
            // For all other periods (daily, weekly, yearly), show every 1st unit.
        return 1
    }
    
        // This ensures the first date, stride dates, AND the last date are included.
    var xAxisLabelDates: [Date] {
        guard !aggregatedData.isEmpty,
              let firstDate = aggregatedData.first?.aggregationStartDate,
              let lastDate = aggregatedData.last?.aggregationStartDate
        else {
            return []
        }
        
        let calendar = Calendar.current
        let unit = xAxisStrideUnit
        let count = xAxisStrideCount
        
        var dates: Set<Date> = []
        var currentDate = firstDate
        
            // 1. Generate dates based on the calculated stride
        while currentDate <= lastDate {
            dates.insert(currentDate)
            guard let nextDate = calendar.date(byAdding: unit, value: count, to: currentDate) else { break }
            currentDate = nextDate
        }
        
            // 2. CRITICAL STEP: Manually insert the last date from the data set.
            // This guarantees the far-right label is always included.
        dates.insert(lastDate)
        
            // 3. Convert Set back to a sorted Array for the Chart.
        return Array(dates).sorted()
    }
    
        /// Filters the exercises based on the current range.
    var filteredExercises: [CardioExercise] {
        return allExercises.filter { $0.exerciseDate >= dateRangeService.startDate.startOfDay && $0.exerciseDate <= dateRangeService.endDate.endOfDay }
    }
    
    init(exercises: [CardioExercise], dateRangeService: DateRangeService) {
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
    
    func update(exercises: [CardioExercise]) {
        if self.allExercises.count != exercises.count {
            self.allExercises = exercises
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
            startDate: currentStartDate,
            endDate: currentEndDate,
            aggregationPeriod: currentAggregationPeriod,
            zeroData: zeroDataCreator,
            dataAggregator: dataAggregator
        )
    }
}
