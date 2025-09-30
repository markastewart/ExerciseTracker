//
//  LastExerciseAddedView.swift
//  ExerciseTracker
//
//  Created by Mark A Stewart on 9/20/25.
//

import SwiftUI
import SwiftData

// MARK: - Last Entry View

struct LastExerciseAddedView: View {
        // This view takes single, non-optional enum. Parent view responsible for ensuring data exists.
    var exercise: AnyExercise
    
    var body: some View {
            // Wrap the entire displayed content in a NavigationLink to enable editing
        NavigationLink(destination: destinationView) {
            VStack(alignment: .leading, spacing: 5) {
                    // Use a switch statement on the enum to display the correct data.
                switch exercise {
                    case .cardio(let cardio):
                        VStack {
                            HStack {
                                Text("Last Recorded Exercise (\(DateFormatter.shortDate.string(from: cardio.exerciseDate)))")
                                    .font(.headline)
                                Spacer()
                                    // Added edit icon to indicate it's tappable
                                Image(systemName: "pencil.circle.fill")
                                    .foregroundColor(.blue)
                            }
                            .padding(.bottom, 4)
                            VStack {
                                HStack {
                                    Text("Exercise: \(cardio.exerciseType)")
                                    Spacer()
                                }
                                
                                HStack {
                                    Text("Duration: \(Int(cardio.duration)) min")
                                    Text("Distance: \(cardio.distance, specifier: "%.2f") mi")
                                    Spacer()
                                }
                                
                                HStack {
                                    Text("Calories: \(cardio.calories)")
                                    Text("Incline: \(cardio.incline, specifier: "%.1f")")
                                    Spacer()
                                }
                            }
                            .padding(.leading, 5)
                        }
                    case .strength(let strength):
                        VStack {
                            HStack {
                                Text("Last Recorded Exercise - \(DateFormatter.shortDate.string(from: strength.exerciseDate))")
                                    .font(.headline)
                                Spacer()
                                    // Added edit icon to indicate it's tappable
                                Image(systemName: "pencil.circle.fill")
                                    .foregroundColor(.blue)
                            }
                            .padding(.bottom, 4)
                            
                            VStack {
                                HStack {
                                    Text("Exercise: \(strength.exerciseType)")
                                    Spacer()
                                }
                                
                                HStack {
                                    Text("Sets: \(strength.sets)")
                                    Text("Reps: \(strength.reps)")
                                    Text("Weight: \(strength.weight) lbs")
                                    Spacer()
                                }
                            }
                            .padding(.leading, 5)
                        }
                }
            }
            .buttonStyle(PlainButtonStyle())
            .foregroundColor(.primary) // Ensure text color is preserved
        }
        .padding(.vertical)
        .padding(.leading, 5)
        .padding(.trailing, 10)
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
    
        /// Helper property to determine the correct destination view and pass the model for editing.
    @ViewBuilder
    private var destinationView: some View {
        switch exercise {
            case .cardio(let cardio):
                    // Pass existing CardioExercise model for editing
                CardioEntryView(editingExercise: cardio)
            case .strength(let strength):
                    // Pass the existing StrengthExercise model for editing
                StrengthEntryView(editingExercise: strength)
        }
    }
}
