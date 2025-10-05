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
    @State private var startDate = Calendar.current.date(byAdding: .day, value: -6, to: Date.now)!
    @State private var endDate = Date.now
    @State private var showDataSyncSheet = false
    @State private var dataRangeService = DateRangeService()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 15) {
                    DateRangeSelector(dateRangeService: $dataRangeService)
                        .padding(.leading, 7)
                    
                    CardioProgressView(dateRangeService: dataRangeService)
                    
                    StrengthProgressView(startDate: startDate, endDate: endDate)
                    
                    LastExerciseAddedView()
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
            .sheet(isPresented: $showDataSyncSheet) {
                DataSyncView()
                    .presentationDetents([.fraction(0.3)])
            }
        }
    }
}
