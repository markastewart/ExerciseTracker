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
        VStack(alignment: .leading, spacing: 5) {
                // Use a switch statement on the enum to display the correct data.
            switch exercise {
                case .cardio(let cardio):
                    VStack {
                        HStack {
                            Text("Last Recorded Exercise - \(DateFormatter.shortDate.string(from: cardio.exerciseDate))")
                                .font(.headline)
                            Spacer()
                        }
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
                        .padding(.leading,5)
                    }
                case .strength(let strength):
                    VStack {
                        HStack {
                            Text("Last Recorded Exercise - \(DateFormatter.shortDate.string(from: strength.exerciseDate))")
                                .font(.headline)
                            Spacer()
                        }
                        
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
        .padding(.vertical)
        .padding(.leading, 5)
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}
