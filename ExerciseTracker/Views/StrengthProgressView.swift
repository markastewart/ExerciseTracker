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
    
        /// The specific date range needed by the view model to pad missing data.
    var startDate: Date
    var endDate: Date
    
        /// The view model handles data aggregation. Initialized once, and updated via the .onChange observer.
    @State private var viewModel = StrengthProgressViewModel(exercises: [], startDate: Date.now, endDate: Date.now)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Strength Progress (\(viewModel.filteredExercises.count) entries)")
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
            
            if exercises.count == 0 {
                Text("No data for this date range.")
                    .padding()
            } else {
                Chart {
                    ForEach(viewModel.aggregatedData) { dayData in
                        LineMark(
                            x: .value("Date", dayData.date),
                            y: .value("Total Weight Lifted", dayData.totalWeightLifted)
                        )
                        .foregroundStyle(by: .value("Metric", "Total Weight Lifted"))
                    }
                }
                .padding(.horizontal)
            }
        }
        .frame(height: 200)
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
        .onAppear {
            viewModel.update(exercises: exercises, startDate: startDate, endDate: endDate)
        }
        .onChange(of: exercises.count) {
            viewModel.update(exercises: exercises, startDate: startDate, endDate: endDate)
        }
        .onChange(of: [startDate, endDate]) {
            viewModel.update(exercises: exercises, startDate: startDate, endDate: endDate)
        }
    }
}
