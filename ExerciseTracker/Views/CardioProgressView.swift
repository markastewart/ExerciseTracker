//
//  CardioProgressView.swift
//  ExerciseTracker
//
//  Created by Mark A Stewart on 9/17/25.
//

import SwiftUI
import Charts
import Foundation

struct CardioProgressView: View {
    
        /// The raw exercise data passed from the parent view.
    var exercises: [CardioExercise]
    
        /// The view model handles data aggregation. Initialized once, and updated via the .onChange observer.
    @State private var viewModel = CardioProgressViewModel(exercises: [])
    
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
            
            if viewModel.aggregatedData.isEmpty {
                Text("No data for this date range.")
                    .padding()
            } else {
                Chart {
                    ForEach(viewModel.aggregatedData) { dayData in
                        LineMark(
                            x: .value("Date", dayData.date),
                            y: .value("Calories", dayData.totalCalories)
                        )
                        .foregroundStyle(by: .value("Metric", "Calories"))
                    }
                }
                .padding(.horizontal)
                
                Chart {
                    ForEach(viewModel.aggregatedData) { dayData in
                        if dayData.averagePace > 0 {
                            LineMark(
                                x: .value("Date", dayData.date),
                                y: .value("Pace", dayData.averagePace)
                            )
                            .foregroundStyle(by: .value("Metric", "Pace"))
                        }
                    }
                }
                .chartForegroundStyleScale(["Pace": .green])
                .padding(.horizontal)
            }
        }
        .frame(height: 200)
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
        .onChange(of: exercises, initial: true) { _, newExercises in
            viewModel.update(exercises: newExercises)
        }
    }
}
