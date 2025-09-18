//
//  DateFormatter+Extensions.swift
//  ExerciseTracker
//
//  Created by Mark A Stewart on 9/7/25.
//

import Foundation

public extension DateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
}

public extension DateFormatter {
    /// A static date formatter for creating filenames with the format "MM-dd-yyyy".
    static let filenameDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        return formatter
    }()
}
