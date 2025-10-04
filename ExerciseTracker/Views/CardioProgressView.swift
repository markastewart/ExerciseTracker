//
//  CardioProgressView.swift
//  ExerciseTracker
//
//  Created by Mark A Stewart on 9/17/25.
//

import SwiftUI
import Charts
import SwiftData

struct CardioProgressView: View {
    var startDate: Date
    var endDate: Date
    
    @Query private var exercises: [CardioExercise]
    @State private var viewModel:  CardioProgressViewModel
    
    init(startDate: Date, endDate: Date) {
        self.startDate = startDate
        self.endDate = endDate
        _viewModel = State(initialValue: CardioProgressViewModel(exercises: [], startDate: startDate, endDate: endDate))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Cardio Progress (\(viewModel.filteredExercises.count) entries)")
                    .font(.headline)
                
                Spacer()
                
                 NavigationLink(destination: ExerciseEntryView(exerciseMode: .cardio)) {
                     Image(systemName: "plus.circle.fill")
                 }
                
                 NavigationLink(destination: Text("Cardio Detail View")) {
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
                            y: .value("Calories", dayData.totalCalories)
                        )
                        .foregroundStyle(by: .value("Metric", "Calories"))
                    }
                }
                    // IMPORTANT: Customize the X-Axis to use the ViewModel's dynamic formatter
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
                
                Chart {
                    ForEach(viewModel.aggregatedData) { dayData in
                        LineMark(
                            x: .value("Date", dayData.aggregationStartDate),
                            y: .value("Pace", dayData.averagePace)
                        )
                        .foregroundStyle(by: .value("Metric", "Pace"))
                    }
                }
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
                .chartForegroundStyleScale(["Pace": .green])
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
        .onChange(of: exercises) {
            viewModel.update(exercises: exercises, startDate: startDate, endDate: endDate)
        }
        .onChange(of: [startDate, endDate]) {
            viewModel.update(exercises: exercises, startDate: startDate, endDate: endDate)
        }
    }
}
