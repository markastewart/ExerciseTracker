//
//  ProgressViewAxisConfig.swift
//  ExerciseTracker
//
//  Created by Mark A Stewart on 10/8/25.
//

import SwiftUI
import Charts
import Foundation

    /// A reusable configuration struct to calculate axis properties based on data and period.
struct ProgressViewAxisConfig {
    
        /// Determines the Calendar.Component unit for the chart stride.
    func xAxisStrideUnit(selectedDateRange: DateRangePeriod) -> Calendar.Component {
        switch selectedDateRange {
            case .daily: return .day
            case .weekly: return .weekOfYear
            case .monthly: return .month
            case .yearly: return .year
        }
    }
    
        /// Determines how many units to skip for the stride count.
    func xAxisStrideCount(selectedDateRange: DateRangePeriod) -> Int {
        if selectedDateRange == .monthly {
                // For monthly views (like 12 months), step by 3 to only label every quarter
            return 3
        }
            // For all other periods (daily, weekly, yearly), show every 1st unit.
        return 1
    }
    
        /// Accesses the formatter for chart X-axis labeling.
    func xAxisDateFormatter(selectedDateRange: DateRangePeriod) -> DateFormatter {
        let formatter = DateFormatter()
        switch selectedDateRange {
            case .daily, .weekly:
                formatter.dateFormat = "MM/dd" // e.g., Jun 15
            case .monthly:
                formatter.dateFormat = "MM/yy" // e.g., Jan '24, Apr '24, etc.
            case .yearly:
                formatter.dateFormat = "yyyy" // e.g., 2024
        }
        return formatter
    }
    
        /// Calculates an array of dates to use as explicit AxisMarks values. This ensures the first date, stride dates, AND the last date are included.
    func xAxisLabelDates<T: ProgressData>(aggregatedData: [T], selectedDateRange: DateRangePeriod) -> [Date] {
        guard !aggregatedData.isEmpty,
              let firstDate = aggregatedData.first?.aggregationStartDate,
              let lastDate = aggregatedData.last?.aggregationStartDate
        else {
            return []
        }
        
        let calendar = Calendar.current
        let unit = xAxisStrideUnit(selectedDateRange: selectedDateRange)
        let count = xAxisStrideCount(selectedDateRange: selectedDateRange)
        
        var dates: Set<Date> = []
        var currentDate = firstDate
        
            // Generate dates based on the calculated stride
        while currentDate <= lastDate {
            dates.insert(currentDate)
            guard let nextDate = calendar.date(byAdding: unit, value: count, to: currentDate) else { break }
            currentDate = nextDate
        }
        
            // Manually insert the last date from the data set to prevent clipping.
        dates.insert(lastDate)
        
            // Set back to a sorted Array for the Chart.
        return Array(dates).sorted()
    }
    
        /// Calculates the date where the X-axis should end. This is necessary to prevent the last data point from being clipped by the chart's edge.
    func xAxisDomainEnd<T: ProgressData>(aggregatedData: [T], selectedDateRange: DateRangePeriod) -> Date? {

        guard let lastDate = aggregatedData.last?.aggregationStartDate else { return nil }
        
        let calendar = Calendar.current
        let unit = xAxisStrideUnit(selectedDateRange: selectedDateRange)
        
            // Add one full unit (day, week, month, etc.) to the last date. This pushes the chart domain boundary out past the final data point.
        guard let domainEndDate = calendar.date(byAdding: unit, value: 1, to: lastDate) else {
            return nil
        }
        return domainEndDate
    }
}
