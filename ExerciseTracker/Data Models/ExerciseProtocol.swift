//
//  ExerciseProtocol.swift
//  ExerciseTracker
//
//  Created by Mark A Stewart on 10/2/25.
//

import Foundation
import SwiftData

    /// Protocol to unify the CardioExercise and StrengthExercise types, allowing them
    /// to be used as a single generic constraint in the DataService extension.
protocol Exercise: PersistentModel {
    var exerciseType: String { get set }
    var exerciseDate: Date { get set }
}

enum ExerciseType: String, CaseIterable {
    case cardio = "Cardio"
    case strength = "Strength"
}
