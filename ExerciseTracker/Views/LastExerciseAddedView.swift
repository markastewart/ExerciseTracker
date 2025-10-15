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
    @Query(sort: [SortDescriptor<StrengthExercise>(\.recordedDate, order: .reverse)])
    private var allStrength: [StrengthExercise]
    @Query(sort: [SortDescriptor<CardioExercise>(\.recordedDate, order: .reverse)])
    private var allCardio: [CardioExercise]
    
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
                                    Text("Pace: \(viewModel.pace, specifier: "%.2f") mi/hr")
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
                        .font(.caption)
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
                                    Text("Weight: \(strength.weight, specifier: "%.1f") lbs")
                                    Spacer()
                                }
                                Text("Total Weight: \(viewModel.totalWeight, specifier: "%.1f") lbs")
                            }
                            .padding(.leading, 5)
                        }
                        .font(.caption)
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
        .onAppear {
            viewModel.refreshLastExercise(allCardio: allCardio, allStrength: allStrength)
        }
            // Data change trigger (Edit, Add, Delete). Watch live arrays - when an object property changes, this triggers.
        .onChange(of: allCardio) { oldCardio, newCardio in
            viewModel.refreshLastExercise(allCardio: newCardio, allStrength: allStrength)
        }
        .onChange(of: allStrength) { oldStrength, newStrength in
            viewModel.refreshLastExercise(allCardio: allCardio, allStrength: newStrength)
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
