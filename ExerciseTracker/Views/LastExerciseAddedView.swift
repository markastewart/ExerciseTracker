//
//  LastExerciseAddedView.swift
//  ExerciseTracker
//
//  Created by Mark A Stewart on 9/20/25.
//

import SwiftUI
import SwiftUI
import SwiftData

// MARK: - Last Entry View

struct LastExerciseAddedView: View {
        // This view now takes a single, non-optional enum. The parent view is responsible for ensuring this data exists.
    var exercise: AnyExercise
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Last Recorded Exercise")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 5) {
                    // Use a switch statement on the enum to display the correct data.
                switch exercise {
                    case .cardio(let cardio):
                        HStack {
                            Text("Exercise: \(cardio.exerciseType)")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Date: \(DateFormatter.shortDate.string(from: cardio.timestamp))")
                        }
                        HStack {
                            Text("Duration: \(Int(cardio.duration)) min")
                            Text("Distance: \(cardio.distance, specifier: "%.2f") mi")
                        }
                        
                        HStack {
                            Text("Calories: \(cardio.calories)")
                            Text("Incline: \(cardio.incline, specifier: "%.1f")")
                        }
                    case .strength(let strength):
                            // Display Strength properties
                        Text(strength.exerciseType)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Date: \(DateFormatter.shortDate.string(from: strength.timestamp))")
                        
                        HStack {
                            Text("Sets: \(strength.sets)")
                            Text("Reps: \(strength.reps)")
                            Text("Weight: \(strength.weight) lbs")
                        }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .frame(height: 100)
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
}
