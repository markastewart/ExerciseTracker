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
    
        /// A formatter suitable for user input that limits the maximum fraction digits, but allows whole numbers to be displayed cleanly (e.g., 5, not 5.0).
    static func inputDecimal(maxDigits: Int) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
            // Setting to 0 prevents automatic addition of ".0" for whole numbers, making input much smoother.
        formatter.minimumFractionDigits = 0
        
            // Caps the input/display at one decimal digit
        formatter.maximumFractionDigits = maxDigits
        
        return formatter
    }
}
