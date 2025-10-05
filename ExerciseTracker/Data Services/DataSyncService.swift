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
        let cardioHeader = "exerciseDate,cardio_name,duration,distance,calories,incline,recordedDate\n"
        exportString += cardioHeader
        do {
            let cardioDescriptor = FetchDescriptor<CardioExercise>(sortBy: [SortDescriptor(\.exerciseDate)])
            let allCardio = try modelContext.fetch(cardioDescriptor)
            
            for exercise in allCardio {
                let formattedExerciseDate = DateFormatter.shortDate.string(from: exercise.exerciseDate)
                let formattedRecordedDate = DateFormatter.shortDate.string(from: exercise.recordedDate)
                let line = "\(formattedExerciseDate), \(exercise.exerciseType), \(exercise.duration), \(exercise.distance), \(exercise.calories), \(exercise.incline), \(formattedRecordedDate)\n"
                exportString += line
            }
        } catch {
            fatalError("Failed to fetch cardio data for export: \(error)")
        }
        
            // Export Strength Data
        exportString += "\n# Strength Data\n"
        let strengthHeader = "exerciseDate,strength_name,sets,reps,weight,recordedDate\n"
        exportString += strengthHeader
        do {
            let strengthDescriptor = FetchDescriptor<StrengthExercise>(sortBy: [SortDescriptor(\.exerciseDate)])
            let allStrength = try modelContext.fetch(strengthDescriptor)
            
            for exercise in allStrength {
                let formattedExerciseDate = DateFormatter.shortDate.string(from: exercise.exerciseDate)
                let line = "\(formattedExerciseDate),\(exercise.exerciseType),\(exercise.sets),\(exercise.reps), \(exercise.weight), \(exercise.recordedDate)\n"
                exportString += line
            }
        } catch {
            fatalError("Failed to fetch strength data for export: \(error)")
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
            if line.hasPrefix("cardio_name") || line.hasPrefix("strength_name") || line.hasPrefix("exerciseDate"){
                continue
            }
            
            let components = line.components(separatedBy: ",")
            
            if isCardioSection && components.count == CardioExercise.columnIndex.allCases.count {
                let exerciseType = components[CardioExercise.columnIndex.exerciseType].trimmingCharacters(in: .whitespacesAndNewlines)
                if let exerciseDate = DateFormatter.shortDate.date(from: components[CardioExercise.columnIndex.exerciseDate]),
                   !exerciseType.isEmpty,
                   let duration = TimeInterval(components[CardioExercise.columnIndex.duration].trimmingCharacters(in: .whitespacesAndNewlines)),
                   let distance = Double(components[CardioExercise.columnIndex.distance].trimmingCharacters(in: .whitespacesAndNewlines)),
                   let calories = Int(components[CardioExercise.columnIndex.calories].trimmingCharacters(in: .whitespacesAndNewlines)),
                   let incline = Double(components[CardioExercise.columnIndex.incline].trimmingCharacters(in: .whitespacesAndNewlines)),
                   let recordedDate = DateFormatter.shortDate.date(from: components[CardioExercise.columnIndex.recordedDate])
                {
                    let newCardio = CardioExercise()
                    newCardio.exerciseDate = exerciseDate
                    newCardio.exerciseType = exerciseType
                    newCardio.duration = duration
                    newCardio.distance = distance
                    newCardio.calories = calories
                    newCardio.incline = incline
                    newCardio.recordedDate = recordedDate
                    modelContext.insert(newCardio)
                }
                else {
                    print("Failed to parse Cardio Exercise line: \(components)")
                    isParseError = true
                }
            } else if isStrengthSection && components.count == StrengthExercise.columnIndex.allCases.count {
                let exerciseType = components[StrengthExercise.columnIndex.exerciseType].trimmingCharacters(in: .whitespacesAndNewlines)
                if let exerciseDate = DateFormatter.shortDate.date(from: components[StrengthExercise.columnIndex.exerciseDate]),
                   !exerciseType.isEmpty,
                   let sets = Int(components[StrengthExercise.columnIndex.sets].trimmingCharacters(in: .whitespacesAndNewlines)),
                   let reps = Int(components[StrengthExercise.columnIndex.reps].trimmingCharacters(in: .whitespacesAndNewlines)),
                   let weight = Int(components[StrengthExercise.columnIndex.weight].trimmingCharacters(in: .whitespacesAndNewlines)),
                   let recordedDate = DateFormatter.shortDate.date(from: components[StrengthExercise.columnIndex.recordedDate])
                {
                    let newStrength = StrengthExercise()
                    newStrength.exerciseDate = exerciseDate
                    newStrength.exerciseType = exerciseType
                    newStrength.sets = sets
                    newStrength.reps = reps
                    newStrength.weight = weight
                    newStrength.recordedDate = recordedDate
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
                fatalError("Failed to save imported data: \(error)")
            }
        }
    }
    
        // Prepares the data for export by writing it to a temporary file
    func prepareFileForExport() -> URL? {
        let dateString = DateFormatter.filenameDateFormatter.string(from: Date.now)
        let fileURL = URL.temporaryDirectory.appending(path: "WorkoutData-\(dateString).csv")
        
        let csvString = self.exportData()
        do {
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            fatalError("Failed to write temporary file: \(error)")
        }
    }
}
