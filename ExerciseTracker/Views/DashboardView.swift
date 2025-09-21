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

struct DashboardContainerView: View {
    @Environment(\.modelContext) private var context

    var body: some View {
        DashboardView(viewModel: DashboardViewModel(context: context))
    }
}

struct DashboardView: View {
    @Query private var allStrength: [StrengthExercise]
    @Query private var allCardio: [CardioExercise]
    @State private var startDate = Calendar.current.date(byAdding: .day, value: -6, to: Date())!
    @State private var endDate = Date()
    @State private var showDataSyncSheet = false
    
    @StateObject private var viewModel: DashboardViewModel

    init(viewModel: DashboardViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
        // This computed property ensures the date range is always correct
    private var dateRange: ClosedRange<Date> {
        let normalizedStartDate = Calendar.current.startOfDay(for: startDate)
        let normalizedEndDate = Date()
        return normalizedStartDate...normalizedEndDate
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Lift & Run")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Date Range")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        HStack {
                            DatePicker("Start", selection: $startDate, in: ...endDate, displayedComponents: .date)
                            Spacer()
                            DatePicker("End", selection: $endDate, in: startDate...Date(), displayedComponents: .date)
                        }
                        .padding(.horizontal)
                    }
                        // Cardio Progress Section
                    CardioProgressView(exercises: allCardio.filter { dateRange.contains($0.timestamp) })
                    
                        // Strength Progress Section
                    StrengthProgressView(exercises: allStrength.filter { dateRange.contains($0.timestamp) })
                    
                        // Last Recorded Entry Section
                    if let exercise = viewModel.lastExercise {
                        switch exercise {
                        case .cardio(let c):
                            LastEntryAddedView(exerciseData: (type: "Cardio", exercise: c))
                        case .strength(let s):
                            LastEntryAddedView(exerciseData: (type: "Strength", exercise: s))
                        }
                    } else {
                        Text("No exercises recorded yet.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding()
                    }
                }
            }
            .background(Color(.systemGray6))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Button("Data Sync") {
                            showDataSyncSheet.toggle()
                        }
                    } label: {
                        Label("Utility", systemImage: "gearshape")
                    }
                }
            }
            .onChange(of: allCardio, {
                viewModel.refreshLastExercise()
            })
            .onChange(of: allStrength, {
                viewModel.refreshLastExercise()
            })
            .sheet(isPresented: $showDataSyncSheet) {
                DataSyncView()
                    .presentationDetents([.fraction(0.3)])
            }
        }
    }
}

#Preview {
//    DashboardView()
}
