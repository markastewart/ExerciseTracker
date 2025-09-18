//
//  DataSyncService.swift
//  ExerciseTracker
//
//  Created by Mark A Stewart on 9/7/25.
//

import Foundation
import SwiftData

    // MARK: - Data Sync Service

    /// A service to handle exporting and importing data to/from a CSV file.
class DataSyncService {
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
        /// Exports all cardio and strength data to a CSV formatted string.
    func exportData() -> String {
        var exportString = ""
        
            // Export Cardio Data
        exportString += "# Cardio Data\n"
        let cardioHeader = "timestamp,cardio_name,duration,distance,calories,incline\n"
        exportString += cardioHeader
        do {
            let cardioDescriptor = FetchDescriptor<CardioExercise>(sortBy: [SortDescriptor(\.timestamp)])
            let allCardio = try modelContext.fetch(cardioDescriptor)
            
            for exercise in allCardio {
                let formattedTimestamp = DateFormatter.shortDate.string(from: exercise.timestamp)
                let line = "\(formattedTimestamp), \(exercise.exerciseType), \(exercise.duration), \(exercise.distance), \(exercise.calories), \(exercise.incline)\n"
                exportString += line
            }
        } catch {
            print("Failed to fetch cardio data for export: \(error)")
        }
        
            // Export Strength Data
        exportString += "\n# Strength Data\n"
        let strengthHeader = "timestamp,strength_name,sets,reps,weight\n"
        exportString += strengthHeader
        do {
            let strengthDescriptor = FetchDescriptor<StrengthExercise>(sortBy: [SortDescriptor(\.timestamp)])
            let allStrength = try modelContext.fetch(strengthDescriptor)
            
            for exercise in allStrength {
                let formattedTimestamp = DateFormatter.shortDate.string(from: exercise.timestamp)
                let line = "\(formattedTimestamp),\(exercise.exerciseType),\(exercise.sets),\(exercise.reps), \(exercise.weight)\n"
                exportString += line
            }
        } catch {
            print("Failed to fetch strength data for export: \(error)")
        }
        
        return exportString
    }
    
        /// Imports data from a CSV formatted string and saves it to the database.
    func importData(csvString: String) {
        let lines = csvString.components(separatedBy: .newlines)
        
        var isCardioSection = false
        var isStrengthSection = false
        var isParseError = false
        
        for line in lines {
            if line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { continue }
            
            if line.hasPrefix("# Cardio Data") {
                isCardioSection = true
                isStrengthSection = false
                continue
            }
            
            if line.hasPrefix("# Strength Data") {
                isCardioSection = false
                isStrengthSection = true
                continue
            }
                // Skip header lines
            if line.hasPrefix("cardio_name") || line.hasPrefix("strength_name") || line.hasPrefix("timestamp"){
                continue
            }
            
            let components = line.components(separatedBy: ",")
            
            if isCardioSection && components.count == CardioExercise.columnIndex.allCases.count {
                let exerciseType = components[CardioExercise.columnIndex.exerciseType]
                if let timestamp = DateFormatter.shortDate.date(from: components[CardioExercise.columnIndex.timestamp]),
                   !exerciseType.isEmpty,
                   let duration = TimeInterval(components[CardioExercise.columnIndex.duration].trimmingCharacters(in: .whitespacesAndNewlines)),
                   let distance = Double(components[CardioExercise.columnIndex.distance].trimmingCharacters(in: .whitespacesAndNewlines)),
                   let calories = Int(components[CardioExercise.columnIndex.calories].trimmingCharacters(in: .whitespacesAndNewlines)),
                   let incline = Double(components[CardioExercise.columnIndex.incline].trimmingCharacters(in: .whitespacesAndNewlines))
                {
                    let newCardio = CardioExercise()
                    newCardio.timestamp = timestamp
                    newCardio.exerciseType = exerciseType
                    newCardio.duration = duration
                    newCardio.distance = distance
                    newCardio.calories = calories
                    newCardio.incline = incline
                    modelContext.insert(newCardio)
                }
                else {
                    print("Failed to parse Cardio Exercise line: \(components)")
                    isParseError = true
                }
            } else if isStrengthSection && components.count == StrengthExercise.columnIndex.allCases.count {
                let exerciseType = components[StrengthExercise.columnIndex.exerciseType]
                if let timestamp = DateFormatter.shortDate.date(from: components[StrengthExercise.columnIndex.timestamp]),
                   !exerciseType.isEmpty,
                   let sets = Int(components[StrengthExercise.columnIndex.sets].trimmingCharacters(in: .whitespacesAndNewlines)),
                   let reps = Int(components[StrengthExercise.columnIndex.reps].trimmingCharacters(in: .whitespacesAndNewlines)),
                   let weight = Int(components[StrengthExercise.columnIndex.weight].trimmingCharacters(in: .whitespacesAndNewlines))
                {
                    let newStrength = StrengthExercise()
                    newStrength.timestamp = timestamp
                    newStrength.exerciseType = exerciseType
                    newStrength.sets = sets
                    newStrength.reps = reps
                    newStrength.weight = weight
                    modelContext.insert(newStrength)
                }
                else {
                    print("Failed to parse Strength Exercise line: \(components)")
                    isParseError = true
                }
            }
        }
        
        if !isParseError {
            do {
                try modelContext.save()
                print("Data successfully imported.")
            } catch {
                print("Failed to save imported data: \(error)")
            }
        }
    }
    
        // Prepares the data for export by writing it to a temporary file
    func prepareFileForExport() -> URL? {
        let dateString = DateFormatter.filenameDateFormatter.string(from: Date())
        let fileURL = URL.temporaryDirectory.appending(path: "WorkoutData-\(dateString).csv")
        
        let csvString = self.exportData()
        do {
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Failed to write temporary file: \(error)")
            return nil
        }
    }
}
