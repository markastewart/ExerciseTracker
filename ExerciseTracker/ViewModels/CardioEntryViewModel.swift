//
//  CardioEntryViewModel.swift
//  ExerciseTracker
//
//  Created by Mark A Stewart on 9/17/25.
//

import Foundation
import SwiftData

class CardioEntryViewModel: ObservableObject {
    @Published var timestamp: Date
    @Published var exerciseType: String
    @Published var duration: TimeInterval
    @Published var distance: Double
    @Published var calories: Int
    @Published var incline: Double
    @Published var cardioTypes: [String] = []
    
    private let dataService = ExerciseDataService.shared
    private let defaultCardioTypes = ["Treadmill", "Stationary Bike", "Rower", "Elliptical"]
    
    init() {
        self.timestamp = Date()
        self.exerciseType = ""
        self.duration = 0.0
        self.distance = 0.0
        self.calories = 0
        self.incline = 0.0
        
        fetchSortedCardioTypes()
    }
    
    private func setDefaultValues() {
        self.duration = 0.0
        self.distance = 0.0
        self.calories = 0
        self.incline = 0.0
    }
    
        // A function to fetch the most recent entry for a given exercise type
    func fetchLastCardioEntry() {
        let predicate = #Predicate<CardioExercise> { exercise in
            exercise.exerciseType == exerciseType
        }
        
        let descriptor = FetchDescriptor(
            predicate: predicate,
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        
        do {
                // If an exercise entry is found, set the view model's properties with the results of the last exercise
            if let modelContext = dataService.modelContext {
                if let entry = try? modelContext.fetch(descriptor).first {
                    self.duration = entry.duration
                    self.distance = entry.distance
                    self.calories = entry.calories
                    self.incline = entry.incline
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
    func fetchSortedCardioTypes() {
        // 1. Fetch all exercises and create a count dictionary.
        guard let allExercises = dataService.fetchAllCardioExercises() else {
            self.exerciseType = defaultCardioTypes.first ?? ""
            self.cardioTypes = defaultCardioTypes
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
            // Update the @Published properties especially exerciseType for the benefit of the Picker in the view.
        self.cardioTypes = sortedTypes
        self.exerciseType = cardioTypes.first ?? ""
    }
    
    func saveCardio() {
        let newCardio = CardioExercise()
        newCardio.timestamp = timestamp
        newCardio.exerciseType = exerciseType
        newCardio.duration = duration
        newCardio.distance = distance
        newCardio.calories = calories
        newCardio.incline = incline
        dataService.save(newCardio)
    }
}
