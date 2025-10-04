//
//  DateExtensions.swift
//  ExerciseTracker
//
//  Created by Mark A Stewart on 10/3/25.
//

import Foundation

extension Date {
        /// Returns the date at the very beginning of the current day (12:00:00 AM).
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }

        /// Returns the date at the very end of the current day (11:59:59 PM).
    var endOfDay: Date {
        let calendar = Calendar.current
        
            // Find the start of the next day
        let startOfNextDay = calendar.date(byAdding: .day, value: 1, to: self.startOfDay)!
        
            // Subtract one second/millisecond to get the end of the current day
        return calendar.date(byAdding: .second, value: -1, to: startOfNextDay)!
    }
}
