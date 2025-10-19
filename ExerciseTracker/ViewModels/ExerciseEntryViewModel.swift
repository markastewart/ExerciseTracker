//
//  ExerciseEntryViewModel.swift
//  ExerciseTracker
//
//  Created by Mark A Stewart on 10/2/25.
//

import Foundation
import SwiftData

@Observable class ExerciseEntryViewModel {
    
        // MARK: - Core Properties
    var mode: ExerciseType = .cardio
    var exerciseDate: Date = Date.now
    var exerciseType: String = ""
    var recordedDate: Date = Date.now
    
        // MARK: - Cardio Properties
    var duration: TimeInterval = 0.0
    var distance: Double = 0.0
    var calories: Int = 0
    var incline: Double = 0.0
    
        // MARK: - Strength Properties
    var sets: Int = 3
    var reps: Int = 12
    var weight: Double = 0.0
    
        // MARK: - Data and State
    var allTypes: [String] = [] // Contains either cardioTypes or strengthTypes based on 'mode'
    var editingCardio: CardioExercise?
    var editingStrength: StrengthExercise?
    
    var isEditing: Bool { editingCardio != nil || editingStrength != nil }
    
    var averagePace: Double = 0.0
    var averageCalories: Int = 0
    var personalBestPace: Double = 0.0
    var personalBestCalories: Int = 0
    var averageTotalWeight: Double = 0.0
    var personalBestTotalWeight: Double = 0.0
    var calculatedPace: Double {
        return distance > 0 ? calculatePace(totalDistance: distance, totalDuration: duration) : 0.0
    }
    var calculatedWeight: Double {
        calculateWeightLifted(weight: weight, sets: sets, reps: reps)
    }
    
    private let dataService = ExerciseDataService.shared
    private let defaultCardioTypes = ["Treadmill", "Stationary Bike", "Rower", "Elliptical"]
    private let defaultStrengthTypes = ["Ab Crunch", "Back Extension", "Bicep Curl", "Chest Press", "Chest Fly", "Inner Thigh Abductor", "Lat Pull", "Lat Raise", "Leg Curl", "Leg Extension", "Leg Press", "Rear Delt", "Seated Calf Raise", "Seated Row", "Shoulder Press", "Tricep Extension"]
    
        /// Initializes the ViewModel for a new entry or editing an existing one.
    init(exerciseMode: ExerciseType, editingCardio: CardioExercise? = nil, editingStrength: StrengthExercise? = nil) {
        self.mode = exerciseMode
        self.editingCardio = editingCardio
        self.editingStrength = editingStrength
        
        if let exercise = editingCardio {
            self.mode = .cardio
            self.exerciseDate = exercise.exerciseDate
            self.exerciseType = exercise.exerciseType
            self.duration = exercise.duration
            self.distance = exercise.distance
            self.calories = exercise.calories
            self.incline = exercise.incline
            self.recordedDate = exercise.recordedDate
        } else if let exercise = editingStrength {
            self.mode = .strength
            self.exerciseDate = exercise.exerciseDate
            self.exerciseType = exercise.exerciseType
            self.sets = exercise.sets
            self.reps = exercise.reps
            self.weight = exercise.weight
            self.recordedDate = exercise.recordedDate
        }
        
        loadSortedTypes()
        
            // For new entries, set default type and load last values
        if !isEditing {
                // Set the initial type to the most frequent one
            exerciseType = allTypes.first ?? ""
            loadLastEntry()
        }
        
            // Calculate history data.
        if exerciseMode == .cardio {
            calculateCardioHistory()
        }
        else {
            calculateStrengthHistory()
        }
    }
    
        /// Loads the values from the most recent entry matching the current exercise mode and exerciseType.
    func loadLastEntry() {
        guard !isEditing else { return } // Only load defaults for new entries
        
        switch mode {
            case .cardio:
                    // Define predicate and descriptor for Cardio
                let predicate = #Predicate<CardioExercise> { $0.exerciseType == exerciseType }
                let descriptor = FetchDescriptor(predicate: predicate, sortBy: [SortDescriptor(\.exerciseDate, order: .reverse)])
                
                if let entry = dataService.fetchLast(descriptor: descriptor) {
                    duration = entry.duration
                    distance = entry.distance
                    calories = entry.calories
                    incline = entry.incline
                } else {
                        // If no entry found, set default Cardio values
                    duration = 0.0
                    distance = 0.0
                    calories = 0
                    incline = 0.0
                }
                
            case .strength:
                    // Define predicate and descriptor for Strength
                let predicate = #Predicate<StrengthExercise> { $0.exerciseType == exerciseType }
                let descriptor = FetchDescriptor(predicate: predicate, sortBy: [SortDescriptor(\.exerciseDate, order: .reverse)])
                
                if let entry = dataService.fetchLast(descriptor: descriptor) {
                    sets = entry.sets
                    reps = entry.reps
                    weight = entry.weight
                } else {
                        // If no entry found, set default Strength values
                    sets = 3
                    reps = 12
                    weight = 0.0
                }
        }
    }
    
        /// Unified save and update function.
    func saveOrUpdateExercise() {
        switch mode {
            case .cardio:
                let exerciseToSave = editingCardio ?? CardioExercise()
                exerciseToSave.exerciseDate = exerciseDate
                exerciseToSave.exerciseType = exerciseType
                exerciseToSave.duration = duration
                exerciseToSave.distance = distance
                exerciseToSave.calories = calories
                exerciseToSave.incline = incline
                
                if editingCardio == nil {
                    exerciseToSave.recordedDate = Date()
                    dataService.save(exerciseToSave)
                }
                
            case .strength:
                let exerciseToSave = editingStrength ?? StrengthExercise()
                exerciseToSave.exerciseDate = exerciseDate
                exerciseToSave.exerciseType = exerciseType
                exerciseToSave.sets = sets
                exerciseToSave.reps = reps
                exerciseToSave.weight = weight
                
                if editingStrength == nil {
                    exerciseToSave.recordedDate = Date()
                    dataService.save(exerciseToSave)
                }
        }
        
            // Notify any listeners that exercise data was updated.
        NotificationCenter.default.post(name: .didUpdateExerciseData, object: nil)
    }
    
        /// Deletes the currently editing exercise.
    func deleteExercise() {
        if let exerciseToDelete: any PersistentModel = editingCardio ?? editingStrength {
            dataService.delete(exerciseToDelete)
        } else {
            fatalError("Error: Attempted to delete a new entry.")
        }
    }
    
        /// Fetches and sorts the exercise types based on the current exericise mode.
    private func loadSortedTypes() {
        let (allExercises, defaults): ([any Exercise], [String]) = {
            switch mode {
                case .cardio:
                    return (dataService.fetchAllCardioExercises() ?? [], defaultCardioTypes)
                case .strength:
                    return (dataService.fetchAllStrengthExercises() ?? [], defaultStrengthTypes)
            }
        }()
        
        var counts: [String: Int] = [:]
        for exercise in allExercises {
            counts[exercise.exerciseType, default: 0] += 1
        }
        
        let recordedTypes = Set(counts.keys)
        let allUniqueTypes = recordedTypes.union(defaults)
        
        let sortedTypes = allUniqueTypes.sorted { (type1, type2) -> Bool in
            let count1 = counts[type1] ?? 0
            let count2 = counts[type2] ?? 0
            
            if count1 != count2 {
                return count1 > count2
            } else {
                return type1 < type2
            }
        }
        allTypes = sortedTypes
    }
    
    func calculateCardioHistory() {
        let cardioStats = CardioStats(exerciseType: exerciseType)
        averagePace = cardioStats.averagePace
        averageCalories = cardioStats.averageCalories
        personalBestPace = cardioStats.personalBestPace
        personalBestCalories = cardioStats.personalBestCalories
    }
    
    func calculateStrengthHistory() {
        let strengthStats = StrengthStats(exerciseType: exerciseType)
        averageTotalWeight = strengthStats.averageTotalWeight
        personalBestTotalWeight = strengthStats.personalBestTotalWeight
    }
}
