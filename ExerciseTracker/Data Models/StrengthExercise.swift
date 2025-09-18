//
//  StrengthExercise.swift
//  ExerciseTracker
//
//  Created by Mark A Stewart on 8/29/25.
//

import Foundation
import SwiftData

@Model
final class StrengthExercise {
    var timestamp: Date = Date()
    var exerciseType: String = ""
    var sets: Int = 0
    var reps: Int = 0
    var weight: Int = 0

    init() {
    }
    
    enum columnIndex: Int, CaseIterable {
        case timestamp = 0
        case exerciseType = 1
        case sets = 2
        case reps = 3
        case weight = 4
    }
}
