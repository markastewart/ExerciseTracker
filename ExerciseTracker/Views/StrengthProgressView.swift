//
//  StrengthProgressView.swift
//  ExerciseTracker
//
//  Created by Mark A Stewart on 9/17/25.
//

import SwiftUI
import Charts
import Foundation

struct StrengthProgressView: View {
    
        /// The raw exercise data passed from the parent view.
    var exercises: [StrengthExercise]
    
        /// The view model handles data aggregation. Initialized once, and updated via the .onChange observer.
    @State private var viewModel = StrengthProgressViewModel(exercises: [])
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Strength Progress (\(exercises.count) entries)")
                    .font(.headline)
                
                Spacer()
                
                NavigationLink(destination: StrengthEntryView()) {
                    Image(systemName: "plus.circle.fill")
                }
                
                NavigationLink(destination: Text("Strength Detail View")) {
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
                            y: .value("Total Weight Lifted (pounds)", dayData.totalWeightLifted)
                        )
                        .foregroundStyle(by: .value("Metric", "Total Weight Lifted (pounds)"))
                    }
                }
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
