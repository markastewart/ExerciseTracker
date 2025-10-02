//
//  CardioExercise.swift
//  ExerciseTracker
//
//  Created by Mark A Stewart on 8/27/25.
//

import Foundation
import SwiftData

@Model
final class CardioExercise : Exercise {
    var exerciseDate: Date = Date.now
    var exerciseType: String = ""
    var duration: TimeInterval = 0.0
    var distance: Double = 0.0
    var calories: Int = 0
    var incline: Double = 0.0
    var recordedDate: Date = Date.now

    init() {
    }
    
    enum columnIndex: Int, CaseIterable {
        case exerciseDate = 0
        case exerciseType = 1
        case duration = 2
        case distance = 3
        case calories = 4
        case incline = 5
        case recordedDate = 6
    }
}

