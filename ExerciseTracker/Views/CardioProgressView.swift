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
    @ObservedObject var dateRangeService: DateRangeService
    @Query private var exercises: [CardioExercise]
    @State private var viewModel: CardioProgressViewModel
    
    init(dateRangeService: DateRangeService) {
        self._dateRangeService = ObservedObject(wrappedValue: dateRangeService)
        
        _viewModel = State(initialValue: CardioProgressViewModel(exercises: [], dateRangeService: dateRangeService))
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
                .frame(height: 100)
                .chartXAxis {
                    AxisMarks(values: viewModel.xAxisLabelDates) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel {
                            if let date = value.as(Date.self) {
                                Text(viewModel.xAxisDateFormatter.string(from: date))
                            }
                        }
                    }
                }
                .padding([.horizontal, .bottom])
                
                Chart {
                    ForEach(viewModel.aggregatedData) { dayData in
                        LineMark(
                            x: .value("Date", dayData.aggregationStartDate),
                            y: .value("Pace", dayData.averagePace)
                        )
                        .foregroundStyle(by: .value("Metric", "Pace"))
                    }
                }
                .frame(height: 100)
                .chartXAxis {
                    AxisMarks(values: viewModel.xAxisLabelDates) { value in
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
                .padding([.horizontal, .bottom])
            }
        }
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
