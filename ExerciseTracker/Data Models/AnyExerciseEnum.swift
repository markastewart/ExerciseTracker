//
//  AnyExerciseEnum.swift
//  ExerciseTracker
//
//  Created by Mark A Stewart on 9/21/25.
//

import Foundation
import SwiftData

    /// Enum to unify Cardio and Strength exercises
enum AnyExercise: Identifiable {
    case cardio(CardioExercise)
    case strength(StrengthExercise)
    case none           // 'no data' state
    
    var id: PersistentIdentifier? {
        switch self {
            case .cardio(let cardioEnum): return cardioEnum.persistentModelID
            case .strength(let strengthEnum): return strengthEnum.persistentModelID
            case .none: return nil
        }
    }
    
    var exerciseDate: Date? {
        switch self {
            case .cardio(let cardioEnum): return cardioEnum.exerciseDate
            case .strength(let strengthEnum): return strengthEnum.exerciseDate
            case .none: return nil
        }
    }
}
