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
    @State private var viewModel = DashboardViewModel()
    @Query private var allStrength: [StrengthExercise]
    @Query private var allCardio: [CardioExercise]

    @State private var startDate = Calendar.current.date(byAdding: .day, value: -6, to: Date.now)!
    @State private var endDate = Date.now
    @State private var showDataSyncSheet = false
    @State private var rangeChoice: DateRangeSelector.RangeChoice = .week

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 15) {
                    DateRangeSelector(startDate: $startDate, endDate: $endDate, choice: $rangeChoice)
                        .padding(.leading, 7)
                    
                    CardioProgressView(exercises: allCardio, startDate: startDate, endDate: endDate)
                    
                    StrengthProgressView(exercises: allStrength, startDate: startDate, endDate: endDate)
                    
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
                    HStack {
                        Image("LiftRunCustomIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                        Text("Lift & Run")
                            .font(.title)
                    }
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
