//
//  StrengthEntryViewModel.swift
//  ExerciseTracker
//
//  Created by Mark A Stewart on 9/17/25.

import Foundation
import SwiftData

    // MARK: - StrengthEntryViewModel (Matching the editing pattern)

@Observable class StrengthEntryViewModel {
    var exerciseDate: Date
    var exerciseType: String
    var sets: Int
    var reps: Int
    var weight: Int
    var strengthTypes: [String] = []
    var recordedDate: Date
    var editingExercise: StrengthExercise?      // Reference to the existing model if in edit mode
    
    private let dataService = ExerciseDataService.shared
    private let defaultStrengthTypes = ["Ab Crunch", "Back Extension", "Bicep Curl", "Chest Press", "Lateral Pull", "Leg Curl", "Leg Extensions", "Seated Row", "Shoulder Press"]
    
    init(editingExercise: StrengthExercise? = nil) {
        self.editingExercise = editingExercise
        
        if let exercise = editingExercise {
                // Editing an existing entry
            self.exerciseDate = exercise.exerciseDate
            self.exerciseType = exercise.exerciseType
            self.sets = exercise.sets
            self.reps = exercise.reps
            self.weight = exercise.weight
            self.recordedDate = exercise.recordedDate
        } else {
                // New entry
            self.exerciseDate = Date.now
            self.exerciseType = ""
            self.sets = 0
            self.reps = 0
            self.weight = 0
            self.recordedDate = Date.now
            setDefaultValues()
        }
        
        loadSortedStrengthTypes()
        
        if editingExercise == nil {
            exerciseType = strengthTypes.first ?? ""
            loadLastStrengthEntry()
        }
    }
    
    private func setDefaultValues() {
        sets = 3
        reps = 12
        weight = 0
    }
    
    func loadLastStrengthEntry() {
        guard editingExercise == nil else { return }
        
        let predicate = #Predicate<StrengthExercise> { exercise in
            exercise.exerciseType == exerciseType
        }
        
        let descriptor = FetchDescriptor(
            predicate: predicate,
            sortBy: [SortDescriptor(\.exerciseDate, order: .reverse)]
        )
        
        do {
            if let modelContext = dataService.modelContext {
                if let entry = try? modelContext.fetch(descriptor).first {
                    sets = entry.sets
                    reps = entry.reps
                    weight = entry.weight
                }
                else {
                    setDefaultValues()
                }
            }
            else {
                fatalError("Error: Unable to obtain modelContext")
            }
        }
    }
    
    func loadSortedStrengthTypes() {
        guard let allExercises = dataService.fetchAllStrengthExercises() else {
            if exerciseType.isEmpty {
                exerciseType = defaultStrengthTypes.first ?? ""
            }
            strengthTypes = defaultStrengthTypes
            return
        }
        
        var counts: [String: Int] = [:]
        for exercise in allExercises {
            counts[exercise.exerciseType, default: 0] += 1
        }
        
        let recordedTypes = Set(counts.keys)
        let allUniqueTypes = recordedTypes.union(defaultStrengthTypes)
        
        let sortedTypes = allUniqueTypes.sorted { (type1, type2) -> Bool in
            let count1 = counts[type1] ?? 0
            let count2 = counts[type2] ?? 0
            
            if count1 != count2 {
                return count1 > count2
            } else {
                return type1 < type2
            }
        }
        
        strengthTypes = sortedTypes
    }
    
        // Unified save and update function
    func saveOrUpdateStrength() {
        let exerciseToSave: StrengthExercise
        
        if let existing = editingExercise {     // Update existing entry
            exerciseToSave = existing
        } else {
                // Create a new entry
            exerciseToSave = StrengthExercise()
            exerciseToSave.recordedDate = Date.now
        }
        
        exerciseToSave.exerciseDate = exerciseDate
        exerciseToSave.exerciseType = exerciseType
        exerciseToSave.sets = sets
        exerciseToSave.reps = reps
        exerciseToSave.weight = weight
        
        if editingExercise == nil {
            dataService.save(exerciseToSave)
        }
    }
    
        /// Deletes the currently editing exercise from SwiftData.
    func deleteStrength() {
        guard let exerciseToDelete = editingExercise else {
            print("Error: Attempted to delete a strength exercise when editingExercise is nil.")
            return
        }
        dataService.delete(exerciseToDelete)
    }
}
