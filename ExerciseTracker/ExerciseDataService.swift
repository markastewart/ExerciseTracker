//
//  ExerciseDataService.swift
//  ExerciseTracker
//
//  Created by Mark A Stewart on 8/29/25.
//

import Foundation
import SwiftData

// MARK: - Data Service

class ExerciseDataService {
        // Singleton to ensure only one instance is used throughout the app
    static let shared = ExerciseDataService()
    
        // The ModelContainer and ModelContext will be injected from the App's environment.
    var modelContext: ModelContext?
    
    private init() {}
    
        // This method is called from the App's entry point to inject the context
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
        // A generic function to save any Model
    func save<T: PersistentModel>(_ model: T) {
        guard let context = modelContext else {
            print("ModelContext not set.")
            return
        }
        context.insert(model)
        do {
            try context.save()
            print("Successfully saved \(T.self).")
        } catch {
            print("Failed to save \(T.self): \(error.localizedDescription)")
        }
    }
    
        // Fetch exercises for a specific day
    func fetchExercises(for date: Date) -> (cardio: [CardioExercise], strength: [StrengthExercise]) {
        guard let context = modelContext else {
            print("ModelContext not set.")
            return ([], [])
        }
            // Define the start and end of the day
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) ?? date
        
        let cardioPredicate = #Predicate<CardioExercise> { exercise in
            exercise.timestamp >= startOfDay && exercise.timestamp < endOfDay
        }
        
        let strengthPredicate = #Predicate<StrengthExercise> { exercise in
            exercise.timestamp >= startOfDay && exercise.timestamp < endOfDay
        }
        
        let cardioDescriptor = FetchDescriptor(predicate: cardioPredicate)
        let strengthDescriptor = FetchDescriptor(predicate: strengthPredicate)
        
        do {
            let cardioResults = try context.fetch(cardioDescriptor)
            let strengthResults = try context.fetch(strengthDescriptor)
            return (cardioResults, strengthResults)
        } catch {
            print("Failed to fetch exercises for date \(date): \(error.localizedDescription)")
            return ([], [])
        }
    }
    
        // Fetch all cardio exercises
    func fetchAllCardioExercises() -> [CardioExercise]? {
        guard let context = modelContext else {
            print("ModelContext not set.")
            return nil
        }
        do {
            return try context.fetch(FetchDescriptor<CardioExercise>())
        } catch {
            print("Failed to fetch all cardio exercises: \(error)")
            return nil
        }
    }
    
        // Fetch all strength exercises
    func fetchAllStrengthExercises() -> [StrengthExercise]? {
        guard let context = modelContext else {
            print("ModelContext not set.")
            return nil
        }
        do {
            return try context.fetch(FetchDescriptor<StrengthExercise>())
        } catch {
            print("Failed to fetch all strength exercises: \(error)")
            return nil
        }
    }
}
