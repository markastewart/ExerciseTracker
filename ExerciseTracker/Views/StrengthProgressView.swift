//
//  StrengthProgressView.swift
//  ExerciseTracker
//
//  Created by Mark A Stewart on 9/17/25.
//

import SwiftUI
import SwiftData
import Charts
import Foundation

    /// The view model handles data aggregation. Initialized once, and updated via the .onChange observer.
struct StrengthProgressView: View {
    @Bindable var dateRangeService: DateRangeService
    @Query private var exercises: [StrengthExercise]
    @State private var viewModel: StrengthProgressViewModel
    
    init(dateRangeService: DateRangeService) {
        self._dateRangeService = Bindable(dateRangeService)
        
        _viewModel = State(initialValue: StrengthProgressViewModel(exercises: [], dateRangeService: dateRangeService))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Strength Progress (\(viewModel.filteredExercises.count) entries)")
                    .font(.headline)
                
                Spacer()
                
                NavigationLink(destination: ExerciseEntryView(exerciseMode: .strength)) {
                    Image(systemName: "plus.circle.fill")
                }
                
                NavigationLink(destination: Text("Strength Detail View")) {
                    Image(systemName: "list.bullet")
                }
            }
            .padding([.horizontal, .top])
            
            if viewModel.filteredExercises.isEmpty {
                Text("No data for this date range.")
                    .padding()
            } else {
                Chart {
                    ForEach(viewModel.aggregatedData) { dayData in
                        LineMark(
                            x: .value("Date", dayData.aggregationStartDate),
                            y: .value("Total Weight Lifted", dayData.totalWeightLifted)
                        )
                        .foregroundStyle(by: .value("Metric", "Total Weight Lifted"))
                    }
                }
                    // Customize the X-Axis to use the ViewModel's dynamic formatter
                .chartXAxis {
                    AxisMarks(values: .automatic) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel {
                            if let date = value.as(Date.self) {
                                Text(viewModel.xAxisDateFormatter.string(from: date))
                            }
                        }
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
            viewModel.update(exercises: exercises)
        }
        .onChange(of: exercises) {
            viewModel.update(exercises: exercises)
        }
    }
}
