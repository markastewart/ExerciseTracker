//
//  ExerciseProgressAggregator.swift
//  ExerciseTracker
//
//  Created by Mark A Stewart on 10/4/25.
//

import Foundation
import Observation
import SwiftData

    /// Defines how the data should be aggregated and how the chart's X-axis should be formatted.
enum AggregationPeriod {
    case daily
    case weekly
    case monthly
    case yearly
}

    /// The protocol that all aggregated data structs (like AggregatedCardioData) must conform to.
protocol ProgressData: Identifiable {
    var aggregationStartDate: Date { get }
}

    // MARK: - Aggregator Class

    /// A generic service class responsible for all temporal aggregation logic, date formatting, and range calculation, separating it from the specific data calculations.
@Observable class ExerciseProgressAggregator {
    private let calendar = Calendar.current
    
        // Properties determined by the date range
    private(set) var aggregationPeriod: AggregationPeriod = .daily
    
        /// Provides the correct formatter for the X-axis based on the current aggregation unit.
    var xAxisDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        switch aggregationPeriod {
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
    
        /// Determines the appropriate aggregation unit based on the date range length and returns to caller.
    private func setAggregationPeriod(from startDate: Date, to endDate: Date) {
        let days = calendar.dateComponents([.day], from: startDate.startOfDay, to: endDate.endOfDay).day ?? 0
        
        if days <= 7 {
            aggregationPeriod = .daily
        } else if days <= 31 {
            aggregationPeriod = .weekly
        } else if days <= (365 + 90) { // Approx 15 months
            aggregationPeriod = .monthly
        } else {
            aggregationPeriod = .yearly
        }
    }
    
        /// Groups raw exercises by the calculated aggregation period and pads the range with zero entries.
        ///
        /// - Parameters:
        ///   - rawExercises: The list of all raw exercises to process.
        ///   - startDate: The start of the viewable range.
        ///   - endDate: The end of the viewable range.
        ///   - zeroData: A closure to create a zero-value data entry for padding.
        ///   - metricAggregator: A closure that calculates the aggregated metric data.
        /// - Returns: A sorted array of aggregated data including zero-padded entries.
    func aggregate<RawExercise, AggregatedData: ProgressData>(rawExercises: [RawExercise],
        startDate: Date, endDate: Date, zeroData: (Date) -> AggregatedData,
        dataAggregator: (Date, [RawExercise]) -> AggregatedData) -> [AggregatedData] where RawExercise: Exercise {
        
        setAggregationPeriod(from: startDate, to: endDate)
        
            // Filter exercises within the date range
        let filteredExercises = rawExercises.filter { $0.exerciseDate >= startDate.startOfDay && $0.exerciseDate <= endDate.endOfDay }
        
            // Group the filtered data based on the dynamic aggregation unit.
        let groupedData = Dictionary(grouping: filteredExercises) { exercise in
            switch aggregationPeriod {
                case .daily:
                    return calendar.startOfDay(for: exercise.exerciseDate)
                case .weekly:
                    return calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: exercise.exerciseDate))!
                case .monthly:
                    return calendar.date(from: calendar.dateComponents([.year, .month], from: exercise.exerciseDate))!
                case .yearly:
                    return calendar.date(from: calendar.dateComponents([.year], from: exercise.exerciseDate))!
            }
        }
        
            // Generate full date range for padding
        var dateIterator = startDate.startOfDay
        let endOfRange = endDate.endOfDay
        var fullDateRange: [Date] = []
        
        while dateIterator < endOfRange {
            let key: Date
            var component: Calendar.Component
            var value: Int
            
            switch aggregationPeriod {
                case .daily:
                    key = calendar.startOfDay(for: dateIterator)
                    component = .day; value = 1
                case .weekly:
                    key = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: dateIterator))!
                    component = .day; value = 7
                case .monthly:
                    key = calendar.date(from: calendar.dateComponents([.year, .month], from: dateIterator))!
                    component = .month; value = 1
                case .yearly:
                    key = calendar.date(from: calendar.dateComponents([.year], from: dateIterator))!
                    component = .year; value = 1
            }
            
            if !fullDateRange.contains(key) {
                fullDateRange.append(key)
            }
            
            guard let nextDate = calendar.date(byAdding: component, value: value, to: dateIterator) else { break }
            dateIterator = nextDate
        }
        
            // Merge and sort the actual data with zero-padded entries
        return fullDateRange.map { dateKey in
            if let exercises = groupedData[dateKey] {
                return dataAggregator(dateKey, exercises)
            } else {
                    // Pad with zero data using the closure provided by the ViewModel
                return zeroData(dateKey)
            }
        }
        .sorted { $0.aggregationStartDate < $1.aggregationStartDate }
    }
}
