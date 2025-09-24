//
//  DashboardView.swift
//  ExerciseTracker
//
//  Created by Mark A Stewart on 9/17/25.
//

import SwiftUI
import Charts
import SwiftData
import Foundation

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @Query private var allStrength: [StrengthExercise]
    @Query private var allCardio: [CardioExercise]

    @State private var startDate = Calendar.current.date(byAdding: .day, value: -6, to: Date())!
    @State private var endDate = Date()
    @State private var showDataSyncSheet = false

    // Always-normalized range for filtering
    private var dateRange: ClosedRange<Date> {
        let normalizedStart = Calendar.current.startOfDay(for: startDate)
        let normalizedEnd   = Date()
        return normalizedStart...normalizedEnd
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 15) {
                        // Range selector replaces two DatePickers
                    DateRangeSelector(startDate: $startDate, endDate: $endDate)
                        .padding(.leading, 7)
                    
                        // Cardio Progress Section
                    CardioProgressView(
                        exercises: allCardio.filter { dateRange.contains($0.exerciseDate) }
                    )
                    
                        // Strength Progress Section
                    StrengthProgressView(
                        exercises: allStrength.filter { dateRange.contains($0.exerciseDate) }
                    )
                    
                        // Last recorded exercise
                    if let lastExercise = viewModel.lastExercise {
                        LastExerciseAddedView(exercise: lastExercise)
                    } else {
                        Text("No exercises recorded yet.")
                            .foregroundColor(.secondary)
                            .padding()
                    }
                }
                .padding(.top, -10)
            }
            .padding(.horizontal)
            .font(.subheadline)
            .background(Color(.systemGray6))
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Lift & Run")
                        .font(.title)
                }
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Button("Data Sync") { showDataSyncSheet.toggle() }
                    } label: {
                        Label("Utility", systemImage: "gearshape")
                            .font(.caption2)
                    }
                }
            }
            .onChange(of: allCardio.count + allStrength.count) {
                viewModel.refreshLastExercise()
            }
            .sheet(isPresented: $showDataSyncSheet) {
                DataSyncView()
                    .presentationDetents([.fraction(0.3)])
            }
        }
    }
}
