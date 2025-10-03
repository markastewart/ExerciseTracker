//
//  LastExerciseAddedView.swift
//  ExerciseTracker
//
//  Created by Mark A Stewart on 9/20/25.
//

import SwiftUI
import SwiftData

struct LastExerciseAddedView: View {
    @State private var viewModel = LastExerciseAddedViewModel()
    
        // @Query properties trigger the refresh when data changes
    @Query private var allStrength: [StrengthExercise]
    @Query private var allCardio: [CardioExercise]
    
    var body: some View {
        Group {
            switch viewModel.lastExercise {
                case .cardio(let cardio):
                    NavigationLink(destination: destinationView) {
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Text("Last Recorded Exercise (\(DateFormatter.shortDate.string(from: cardio.exerciseDate)))")
                                    .font(.headline)
                                Spacer()
                                    // Edit icon to indicate it's tappable
                                Image(systemName: "pencil.circle.fill")
                                    .foregroundColor(.blue)
                            }
                            .padding(.bottom, 4)
                            
                            VStack(alignment: .leading) {
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
                        .buttonStyle(PlainButtonStyle())
                        .foregroundColor(.primary)
                    }
                    
                case .strength(let strength):
                    NavigationLink(destination: destinationView) {
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Text("Last Recorded Exercise - \(DateFormatter.shortDate.string(from: strength.exerciseDate))")
                                    .font(.headline)
                                Spacer()
                                Image(systemName: "pencil.circle.fill")
                                    .foregroundColor(.blue)
                            }
                            .padding(.bottom, 4)
                            
                            VStack(alignment: .leading) {
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
                        .buttonStyle(PlainButtonStyle())
                        .foregroundColor(.primary)
                    }
                    
                default: // No data case
                    Text("No exercises recorded yet. Tap '+' to begin!")
            }
        }
        .padding(.vertical)
        .padding(.horizontal, 15) // Use consistent horizontal padding
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
        .onChange(of: allCardio.count + allStrength.count) {
            viewModel.refreshLastExercise()
        }
    }
    
        /// Helper property to determine the correct destination view and pass the model for editing.
    @ViewBuilder
    private var destinationView: some View {
        switch viewModel.lastExercise {
            case .cardio(let cardio):
                    // Pass existing CardioExercise model for editing
                ExerciseEntryView(exerciseMode: .cardio, editingCardio: cardio)
            case .strength(let strength):
                    // Pass existing StrengthExercise model for editing
                ExerciseEntryView(exerciseMode: .strength, editingStrength: strength)
            default:
                    // This case ideally never reached if the view is being tapped,
                Text("No exercise data to edit.")
        }
    }
}
