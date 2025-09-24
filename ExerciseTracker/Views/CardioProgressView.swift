//
//  CardioProgressView.swift
//  ExerciseTracker
//
//  Created by Mark A Stewart on 9/17/25.
//

import SwiftUI
import Charts

struct CardioProgressView: View {
    var exercises: [CardioExercise]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Cardio Progress (\(exercises.count) entries)")
                    .font(.headline)
                
                Spacer()
                
                NavigationLink(destination: CardioEntryView()) {
                    Image(systemName: "plus.circle.fill")
                }
                
                NavigationLink(destination: Text("Cardio Detail View")) {
                    Image(systemName: "list.bullet")
                }
            }
            .padding([.horizontal, .top])
            
            Chart {
                ForEach(exercises) { exercise in
                    LineMark(
                        x: .value("Date", exercise.exerciseDate),
                        y: .value("Calories", exercise.calories)
                    )
                    .foregroundStyle(by: .value("Metric", "Calories"))
                }
            }
            .padding(.horizontal)
            
            Chart {
                ForEach(exercises) { exercise in
                        // Make sure duration > 0 to avoid division by zero
                    if exercise.duration > 0 {
                        let pace = exercise.distance / exercise.duration * 60
                        LineMark(
                            x: .value("Date", exercise.exerciseDate),
                            y: .value("Pace", pace)
                        )
                        .foregroundStyle(by: .value("Metric", "Pace"))
                    }
                }
            }
            .chartForegroundStyleScale(["Pace": .green])
            .padding(.horizontal)
        }
        .frame(height: 200)
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}
