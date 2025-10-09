//
//  DateRangeService.swift
//  ExerciseTracker
//
//  Created by Mark A Stewart on 10/5/25.
//

import Foundation
import SwiftData
import Combine

    /// Defines the aggregation periods used by the Exercise Progress aggregator service.
enum DateRangePeriod: String, Identifiable {
    case daily, weekly, monthly, yearly
    var id: String { self.rawValue }
}

    /// Defines the user-selectable time ranges for the chart view.
enum TimePeriod: String, CaseIterable, Identifiable {
    case last7Days, last4Weeks, last6Months, last12Months, custom
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .last7Days: return "Last 7 Days"
        case .last4Weeks: return "Last Month"
        case .last6Months: return "Last 6 Months"
        case .last12Months: return "Last Year"
        case .custom: return "Custom"
        }
    }
}

class DateRangeService: ObservableObject {
    @Published var selectedPeriod: TimePeriod = .last7Days {
        didSet { updateDateRange() }
    }
    
        // The DateRangeSelector view binds to these properties directly when .custom selected. Recalc range when currently in custom mode. NotificationCenter ensures observers update.
    var customStartDate: Date = Calendar.current.date(byAdding: .day, value: -365, to: Date())!  {
        didSet { if selectedPeriod == .custom { updateDateRange() }
        }
    }

    var customEndDate: Date = Date.now {
        didSet { if selectedPeriod == .custom { updateDateRange() }
        }
    }
    
       // The start and end date used for filtering data. The dynamically calculated period (daily, weekly, etc.) that the Exercise Progress aggregator must use.
    private(set) var startDate: Date
    private(set) var endDate: Date
    private(set) var aggregationPeriod: DateRangePeriod

    init() {
        let now = Date.now
        self.endDate = now
        self.startDate = Calendar.current.date(byAdding: .day, value: -6, to: now)!
        self.aggregationPeriod = .daily
        updateDateRange()
    }
    
        // Updates the start/end dates and calculates the required aggregation period
    private func updateDateRange() {
        let now = Date.now
        
        switch selectedPeriod {
        case .last7Days:
            startDate = Calendar.current.date(byAdding: .day, value: -6, to: now)!
            endDate = now
            aggregationPeriod = .daily
            
        case .last4Weeks:
            startDate = Calendar.current.date(byAdding: .month, value: -1, to: now)!
            endDate = now
            aggregationPeriod = .weekly
            
        case .last6Months:
            startDate = Calendar.current.date(byAdding: .month, value: -6, to: now)!
            endDate = now
            aggregationPeriod = .monthly
            
        case .last12Months:
            startDate = Calendar.current.date(byAdding: .year, value: -1, to: now)!
            endDate = now
            aggregationPeriod = .monthly
            
        case .custom:
            startDate = customStartDate
            endDate = customEndDate
            
                    // Ensure end date is not before start date
            if startDate > endDate {
                (startDate, endDate) = (endDate, startDate)
            }
            aggregationPeriod = determineCustomPeriod(start: startDate, end: endDate)
        }
            // Trigger aggregation in consumers (ViewModels) after dates are finalized
        NotificationCenter.default.post(name: .didUpdateExerciseData, object: nil)
    }
    
        // Implements the logic to determine the cadence for the custom date range.
    private func determineCustomPeriod(start: Date, end: Date) -> DateRangePeriod {
        let calendar = Calendar.current
        
            // Calculate the difference in days.
        guard let days = calendar.dateComponents([.day], from: start.startOfDay, to: end.startOfDay).day else {
            return .daily
        }
        
            // Use the absolute value of days in case the range was flipped
        let totalDays = abs(days)
        if totalDays <= 10 {
            return .daily
        } else if totalDays <= 70 {
            return .weekly
        } else if totalDays <= 455 {
            return .monthly
        } else {
            return .yearly
        }
    }
    
        // Reset start and end date when custom start or end dates changed
    func setCustomDateRange(start: Date, end: Date) {
        self.customStartDate = start
        self.customEndDate = end
        
            // If period wasn't custom, setting selectedPeriod will call it.
        if selectedPeriod != .custom {
             selectedPeriod = .custom
        } else {
            updateDateRange()
        }
    }
}
