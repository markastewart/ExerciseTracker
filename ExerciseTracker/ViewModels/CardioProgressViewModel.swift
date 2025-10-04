//
//  CardioProgressViewModel.swift
//  ExerciseTracker
//
//  Created by Mark A Stewart on 9/24/25.

import Foundation
import Observation
import Charts

    /// Defines how the data should be aggregated and how the chart's X-axis should be formatted.
enum AggregationUnit {
    case daily
    case weekly
    case monthly
    case yearly
}

struct AggregatedCardioData: Identifiable {
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
    
        /// Filters the exercises based on the current range.
    var filteredExercises: [CardioExercise] {
        return allExercises.filter { $0.exerciseDate >= startDate.startOfDay && $0.exerciseDate <= endDate.endOfDay }
    }
    
        /// Determines the appropriate aggregation unit based on the date range length.
    var aggregationUnit: AggregationUnit {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: startDate.startOfDay, to: endDate.endOfDay).day ?? 0
        
                        // Date range up to 7 days, aggregated daily
        if days <= 7 {
            return .daily
                        // Short range (e.g., last month) aggregated weekly
        } else if days <= 31 {
            return .weekly
                        // Medium range (up to 15 months) aggregated monthly
        } else if days <= (365 + 90) {
            return .monthly
                        // Long range (more than 15 months) aggregated yearly
        } else {
            return .yearly
        }
    }
    
        /// Provides the correct formatter for the X-axis based on the current aggregation unit.
    var xAxisDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        switch aggregationUnit {
            case .daily:
                formatter.dateFormat = "MMM d" // e.g., Jun 15
            case .weekly:
                formatter.dateFormat = "MMM d" // Week start date, e.g., Jun 16
            case .monthly:
                formatter.dateFormat = "MMM yyyy" // e.g., June 2024
            case .yearly:
                formatter.dateFormat = "yyyy" // e.g., 2024
        }
        return formatter
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
    
        /// Aggregates raw exercise data into dynamic buckets (Day, Week, Month, or Year).
    func aggregateData() {
        let calendar = Calendar.current
        let unit = aggregationUnit
        
            // Group the filtered data based on the dynamic aggregation unit.
        let groupedData = Dictionary(grouping: filteredExercises) { exercise in
            switch unit {
                case .daily:
                    return calendar.startOfDay(for: exercise.exerciseDate)
                    
                case .weekly:       // Group by the start of the week.
                    return calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: exercise.exerciseDate))!
                    
                case .monthly:      // Group by the start of the month
                    return calendar.date(from: calendar.dateComponents([.year, .month], from: exercise.exerciseDate))!
                    
                case .yearly:       // Group by the start of the year
                    return calendar.date(from: calendar.dateComponents([.year], from: exercise.exerciseDate))!
            }
        }
            // Aggregate actual data into a dictionary keyed by the date's start of period.
        var actualData: [Date: AggregatedCardioData] = [:]
        
        for (dateKey, dailyExercises) in groupedData {
            let totalDistance = dailyExercises.reduce(0.0) { $0 + $1.distance }
            let totalCalories = dailyExercises.reduce(0) { $0 + $1.calories }
            let totalDuration = dailyExercises.reduce(0.0) { $0 + $1.duration }
            
                // Calculate average pace for the aggregated period
            let averagePace = totalDuration > 0 ? (totalDistance / totalDuration) * 60 : 0.0
            
            actualData[dateKey] = AggregatedCardioData(
                aggregationStartDate: dateKey,
                totalDistance: totalDistance,
                totalCalories: totalCalories,
                averagePace: averagePace
            )
        }
        
            // Generate full date range for padding (iterating by unit step). Use endOfDay to ensure the loop includes the final period containing the endDate
        var dateIterator = startDate.startOfDay
        let endOfRange = endDate.endOfDay
        var fullDateRange: [Date] = []
        
            // Determine how to step and what the key should look like
        while dateIterator < endOfRange {
            let key: Date
            var component: Calendar.Component
            var value: Int
            
            switch unit {
                case .daily:
                    key = calendar.startOfDay(for: dateIterator)
                    component = .day
                    value = 1

                case .weekly:   // Find start of week for current iterator date. Step by a week
                    key = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: dateIterator))!
                    component = .day
                    value = 7
                    
                case .monthly:  // Find start of month for current iterator date. Step by a month
                    key = calendar.date(from: calendar.dateComponents([.year, .month], from: dateIterator))!
                    component = .month
                    value = 1
                    
                case .yearly:   // Find the start of year for current iterator date. Step by a year
                    key = calendar.date(from: calendar.dateComponents([.year], from: dateIterator))!
                    component = .year
                    value = 1
            }
            
                // Ensure we don't duplicate keys for multi-day/week/month iteration
            if !fullDateRange.contains(key) {
                fullDateRange.append(key)
            }
            
                // Move the iterator to the next period
            guard let nextDate = calendar.date(byAdding: component, value: value, to: dateIterator) else { break }
            dateIterator = nextDate
        }
        
            // Merge and sort the aggregated data with zero-padded entries
        aggregatedData = fullDateRange.map { day in
            if let data = actualData[day] {
                return data
            } else {
                    // Pad with zero data for dates in the range that have no exercises
                return AggregatedCardioData(
                    aggregationStartDate: day,
                    totalDistance: 0.0,
                    totalCalories: 0,
                    averagePace: 0.0
                )
            }
        }
        .sorted { $0.aggregationStartDate < $1.aggregationStartDate }
    }
}
