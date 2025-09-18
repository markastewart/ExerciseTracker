//
//  StrengthProgressView.swift
//  ExerciseTracker
//
//  Created by Mark A Stewart on 9/17/25.
//

import SwiftUI
import Charts

struct StrengthProgressView: View {
    var exercises: [StrengthExercise]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Strength Progress (\(exercises.count) entries)")
                    .font(.headline)
                
                Spacer()
                
                NavigationLink(destination: StrengthEntryView()) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
                
                NavigationLink(destination: Text("Strength Detail View")) {
                    Image(systemName: "list.bullet")
                        .font(.title2)
                }
            }
            .padding([.horizontal, .top])
            
            Chart {
                ForEach(exercises) { exercise in
                    let volume = exercise.sets * exercise.reps * exercise.weight
                    BarMark(
                        x: .value("Date", exercise.timestamp),
                        y: .value("Volume", volume)
                    )
                    .foregroundStyle(.orange)
                }
            }
            .frame(height: 200)
            .padding(.horizontal)
        }
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
}
