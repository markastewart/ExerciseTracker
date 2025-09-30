//
//  CardioEntryViewModel.swift
//  ExerciseTracker
//
//  Created by Mark A Stewart on 9/17/25.

import Foundation
import SwiftData

    // MARK: - CardioEntryViewModel

@Observable class CardioEntryViewModel {
    var exerciseDate: Date
    var exerciseType: String
    var duration: TimeInterval
    var distance: Double
    var calories: Int
    var incline: Double
    var cardioTypes: [String] = []
    var recordedDate: Date
    var editingExercise: CardioExercise?        // Reference to the existing model if in edit mode
    
    private let dataService = ExerciseDataService.shared
    private let defaultCardioTypes = ["Treadmill", "Stationary Bike", "Rower", "Elliptical"]
    
        // Updated initializer to handle editing or new entry creation
    init(editingExercise: CardioExercise? = nil) {
        self.editingExercise = editingExercise
        
        if let exercise = editingExercise {
                // Case 1: Editing an existing entry (use its data)
            self.exerciseDate = exercise.exerciseDate
            self.exerciseType = exercise.exerciseType
            self.duration = exercise.duration
            self.distance = exercise.distance
            self.calories = exercise.calories
            self.incline = exercise.incline
            self.recordedDate = exercise.recordedDate // Preserve original date
        } else {
                // Case 2: New entry (set defaults)
            self.exerciseDate = Date()
            self.exerciseType = ""
            self.duration = 0.0
            self.distance = 0.0
            self.calories = 0
            self.incline = 0.0
            self.recordedDate = Date()
        }
        
        loadSortedCardioTypes()
        
            // If not editing, set exerciseType to the most frequent type and load its last values
        if editingExercise == nil {
            exerciseType = cardioTypes.first ?? ""
            loadLastCardioEntry()
        }
    }
    
    private func setDefaultValues() {
        duration = 0.0
        distance = 0.0
        calories = 0
        incline = 0.0
    }
    
        // A function to fetch the most recent entry for a given exercise type
    func loadLastCardioEntry() {
            // Only load last entry data if we are creating a *new* exercise
        guard editingExercise == nil else { return }
        
        let predicate = #Predicate<CardioExercise> { exercise in
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
                    duration = entry.duration
                    distance = entry.distance
                    calories = entry.calories
                    incline = entry.incline
                }
                else {     // No exercise records of this type exist; use default values
                    setDefaultValues()
                }
            }
            else {
                fatalError("Error: Unable to obtain modelContext")
            }
        }
    }
    
        // Fetch and sort the exercise types
    func loadSortedCardioTypes() {
            // 1. Fetch all exercises and create a count dictionary.
        guard let allExercises = dataService.fetchAllCardioExercises() else {
            if exerciseType.isEmpty { // Only set default if it wasn't set by editingExercise init
                exerciseType = defaultCardioTypes.first ?? ""
            }
            cardioTypes = defaultCardioTypes
            return
        }
        
        var counts: [String: Int] = [:]
        for exercise in allExercises {
            counts[exercise.exerciseType, default: 0] += 1
        }
        
            // Get a combined set of all recorded types and default types.
        let recordedTypes = Set(counts.keys)
        let allUniqueTypes = recordedTypes.union(defaultCardioTypes)
        
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
        cardioTypes = sortedTypes
    }
    
        // Unified save and update function
    func saveOrUpdateCardio() {
        let exerciseToSave: CardioExercise
        
        if let existing = editingExercise {    // Update existing entry
            exerciseToSave = existing
        } else {
                // Create a new entry
            exerciseToSave = CardioExercise()
            exerciseToSave.recordedDate = Date()
        }
        
        exerciseToSave.exerciseDate = exerciseDate
        exerciseToSave.exerciseType = exerciseType
        exerciseToSave.duration = duration
        exerciseToSave.distance = distance
        exerciseToSave.calories = calories
        exerciseToSave.incline = incline
        
            // If new, save it. If existing, SwiftData tracks the update automatically.
        if editingExercise == nil {
            dataService.save(exerciseToSave)
        }
    }
    
        /// Deletes the currently editing exercise from SwiftData.
    func deleteCardio() {
        guard let exerciseToDelete = editingExercise else {
            print("Error: Attempted to delete a cardio exercise when editingExercise is nil.")
            return
        }
        dataService.delete(exerciseToDelete)
    }
}
