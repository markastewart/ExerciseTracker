//
//  StrengthEntryViewModel.swift
//  ExerciseTracker
//
//  Created by Mark A Stewart on 9/17/25.
//

import Foundation
import SwiftData

@Observable class StrengthEntryViewModel {
    var exerciseDate = Date()
    var exerciseType: String
    var sets: Int
    var reps: Int
    var weight: Int
    var strengthTypes: [String] = []
    var recordedDate = Date()
    
    private let dataService = ExerciseDataService.shared
    private let defaultStrengthTypes = ["Ab Crunch",
                                        "Back Extension",
                                        "Bicep Curl",
                                        "Chest Press",
                                        "Inward Thigh",
                                        "Lateral Pull",
                                        "Lateral Raise",
                                        "Leg Curl",
                                        "Leg Extensions",
                                        "Rear Delt",
                                        "Seated Calf Raise",
                                        "Seated Row",
                                        "Shoulder Press",
                                        "Tricep Extension",
                                       ]
    
    init() {
        self.exerciseDate = Date()
        self.exerciseType = ""
        self.sets = 3
        self.reps = 12
        self.weight = 0
        self.recordedDate = Date()
        
        // Init strengthTypes based on previously stored results, set exerciseType to align with most frequently recorded result and fetch its values
        loadSortedStrengthTypes()
        exerciseType = strengthTypes.first ?? ""
        loadLastStrengthEntry()
    }
    
    private func setDefaultValues() {
        sets = 3
        reps = 12
        weight = 0
    }
    
        // A function to fetch the most recent entry for a given exercise type
    func loadLastStrengthEntry() {
        let predicate = #Predicate<StrengthExercise> { exercise in
            exercise.exerciseType == exerciseType
        }
        
        let descriptor = FetchDescriptor(
            predicate: predicate,
            sortBy: [SortDescriptor(\.exerciseDate, order: .reverse)]
        )
        
        do {
                // If an exercise entry is found, set the view model's properties with the results of the last exercise
            if let modelContext = dataService.modelContext {
                if let entry = try? modelContext.fetch(descriptor).first {
                    sets = entry.sets
                    reps = entry.reps
                    weight = entry.weight
                }
                else {      // No exercise records of this type exist; use default values
                    setDefaultValues()
                }
            }
            else {
                fatalError("Error: Unable to obtain modelContext")
            }
        }
    }
    
        // Fetch and sort the exercise types
    func loadSortedStrengthTypes() {
        guard let allExercises = dataService.fetchAllStrengthExercises() else {
            strengthTypes = defaultStrengthTypes
            exerciseType = defaultStrengthTypes.first ?? ""
            return
        }
            // Count the frequency of each exercise type
        var counts: [String: Int] = [:]
        for exercise in allExercises {
            counts[exercise.exerciseType, default: 0] += 1
        }
            // Get a combined set of all recorded types and default types.
        let recordedTypes = Set(counts.keys)
        let allUniqueTypes = recordedTypes.union(defaultStrengthTypes)
        
            // Sort the combined list using your criteria.
        let sortedTypes = allUniqueTypes.sorted { (type1, type2) -> Bool in
            let count1 = counts[type1] ?? 0
            let count2 = counts[type2] ?? 0
            
                // Primary sort: by count (descending)
            if count1 != count2 {
                return count1 > count2
            } else {
                // Secondary sort: alphabetical (ascending) for ties
                return type1 < type2
            }
        }
            // Update the @Published property
        strengthTypes = sortedTypes
    }
    
    
    func saveStrength() {
        let newStrength = StrengthExercise()
        newStrength.exerciseDate = exerciseDate
        newStrength.exerciseType = exerciseType
        newStrength.sets = sets
        newStrength.reps = reps
        newStrength.weight = weight
        newStrength.recordedDate = recordedDate
        dataService.save(newStrength)
    }
}
