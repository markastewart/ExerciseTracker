//
//  LastExerciseAddedView.swift
//  ExerciseTracker
//
//  Created by Mark A Stewart on 9/20/25.
//

import SwiftUI
import SwiftData

    // MARK: - Last Entry View

struct LastEntryAddedView: View {
    var exerciseData: (type: String, exercise: any SwiftData.PersistentModel)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Last Recorded Exercise")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 5) {
                if let cardio = exerciseData.exercise as? CardioExercise {
                        // Display Cardio properties
                    HStack {
                        Text("Date: \(DateFormatter.shortDate.string(from: cardio.timestamp))")
                        Text("Exercise: \(cardio.exerciseType)")
                    }
                    HStack {
                        Text("Duration: \(Int(cardio.duration)) min")
                        Text("Distance: \(cardio.distance, specifier: "%.2f") mi")
                    }
                    HStack {
                        Text("Calories: \(cardio.calories)")
                        Text("Incline: \(cardio.incline, specifier: "%.1f")")
                    }
                } else if let strength = exerciseData.exercise as? StrengthExercise {
                        // Display Strength properties
                    HStack {
                        Text("Date: \(DateFormatter.shortDate.string(from: strength.timestamp))")
                        Text("Exercise: \(strength.exerciseType)")
                    }
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

#Preview {
    //LastEntryAddedView(.constant)
}
