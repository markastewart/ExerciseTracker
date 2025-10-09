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
            fatalError("ModelContext not set.")
        }
        context.insert(model)
        do {
            try context.save()
            print("Successfully saved \(T.self).")
        } catch {
            fatalError("Failed to save \(T.self): \(error.localizedDescription)")
        }
    }
    
        // Fetch exercises for a specific day
    func fetchExercises(for date: Date) -> (cardio: [CardioExercise], strength: [StrengthExercise]) {
        guard let context = modelContext else {
            fatalError("ModelContext not set.")
        }
            // Define the start and end of the day
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) ?? date
        
        let cardioPredicate = #Predicate<CardioExercise> { exercise in
            exercise.exerciseDate >= startOfDay && exercise.exerciseDate < endOfDay
        }
        
        let strengthPredicate = #Predicate<StrengthExercise> { exercise in
            exercise.exerciseDate >= startOfDay && exercise.exerciseDate < endOfDay
        }
        
        let cardioDescriptor = FetchDescriptor(predicate: cardioPredicate)
        let strengthDescriptor = FetchDescriptor(predicate: strengthPredicate)
        
        do {
            let cardioResults = try context.fetch(cardioDescriptor)
            let strengthResults = try context.fetch(strengthDescriptor)
            return (cardioResults, strengthResults)
        } catch {
            fatalError("Failed to fetch exercises for date \(date): \(error.localizedDescription)")
        }
    }
    
        // Fetch all cardio exercises
    func fetchAllCardioExercises() -> [CardioExercise]? {
        guard let context = modelContext else {
            fatalError("ModelContext not set.")
        }
        do {
            return try context.fetch(FetchDescriptor<CardioExercise>())
        } catch {
            fatalError("Failed to fetch all cardio exercises: \(error)")
        }
    }
    
        // Fetch all strength exercises
    func fetchAllStrengthExercises() -> [StrengthExercise]? {
        guard let context = modelContext else {
            fatalError("ModelContext not set.")
        }
        do {
            return try context.fetch(FetchDescriptor<StrengthExercise>())
        } catch {
            fatalError("Failed to fetch all strength exercises: \(error)")
        }
    }
    
    func delete<T: PersistentModel>(_ model: T) {
        guard let _ = modelContext else {
            fatalError("ModelContext not set.")
        }
        
        do {
            modelContext?.delete(model)
            try modelContext?.save() // Not strictly needed, but common practice
        } catch {
            fatalError("Error deleting model: \(error)")
        }
    }
    
        /// Generic fetch for the last entry based on a FetchDescriptor
    func fetchLast<T: Exercise>(descriptor: FetchDescriptor<T>) -> T? {
        guard let modelContext = self.modelContext else {
            fatalError("Error: Unable to obtain modelContext")
        }
        return try? modelContext.fetch(descriptor).first
    }
}
