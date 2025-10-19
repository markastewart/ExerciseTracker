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

func calculatePace (totalDistance: Double, totalDuration: Double) -> Double {
     return (totalDistance / totalDuration) * 60
}

    // A statistics calculator initialized with a specific, filtered set of exercises. All requested calculations are available as computed properties.
struct CardioStats {
    private let dataService = ExerciseDataService.shared
    private var filteredExercises: [CardioExercise] = []
    
    
    init(exerciseType: String) {
        let allExercises = dataService.fetchAllCardioExercises() ?? []
        self.filteredExercises = allExercises.filter { $0.exerciseType == exerciseType }
    }

        // Calculates average pace (total duration / total distance) across all filtered exercises. Pace returned in MPH
    var averagePace: Double {
        let measurableWorkouts = filteredExercises.filter { $0.distance > 0.0 && $0.duration > 0.0 }
        
        guard !measurableWorkouts.isEmpty else {
            return 0.0
        }
            // Sum total duration (in minutes) and total distance (in miles)
        let totalDurationInHours = (measurableWorkouts.reduce(0.0) { $0 + $1.duration }) / 60.0
        let totalDistanceInMiles = measurableWorkouts.reduce(0.0) { $0 + $1.distance }
        return totalDurationInHours > 0.0 ? (totalDistanceInMiles / totalDurationInHours) : 0.0
    }
    
        // Calculates average calories burned per session across all filtered exercises.
    var averageCalories: Int {
        let measurableWorkouts = filteredExercises.filter { $0.calories > 0 }
        
        guard !measurableWorkouts.isEmpty else {
            return 0
        }
        
        let totalCalories = measurableWorkouts.reduce(0) { $0 + $1.calories }
        let workoutCount = measurableWorkouts.count
        return totalCalories / workoutCount
    }
    

        // Calculate personal best pace (duration/distance) for all valid sessions and return the minimum pace (the fastest time)
    var personalBestPace: Double {
        let validPaces = filteredExercises
            .filter { $0.distance > 0.0 && $0.duration > 0.0 }
            .map { $0.duration / $0.distance }
        
            // Find minimum pace (the fastest time)
        return validPaces.min() ?? 0.0
    }
    
        // Retrieve personal best (highest) calorie count in a single session. Returns 0 if no exercises are present.
    var personalBestCalories: Int {
        return filteredExercises.map { $0.calories }.max() ?? 0
    }
}

