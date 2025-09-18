//
//  NumberFornatterExtension.swift
//  ExerciseTracker
//
//  Created by Mark A Stewart on 9/6/25.
//

import Foundation

public extension NumberFormatter {
    static func decimal(_ count: Int) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = count
        formatter.maximumFractionDigits = count
        return formatter
    }
}
