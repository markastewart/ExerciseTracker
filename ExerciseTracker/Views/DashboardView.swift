import SwiftUI
import Charts
import SwiftData
import Foundation

struct DashboardView: View {
    @StateObject private var viewModel =  DashboardViewModel()
    @Query private var allStrength: [StrengthExercise]
    @Query private var allCardio: [CardioExercise]
    @State private var startDate = Calendar.current.date(byAdding: .day, value: -6, to: Date())!
    @State private var endDate = Date()
    @State private var showDataSyncSheet = false
    
        // Computed property ensures date range is always correct
    private var dateRange: ClosedRange<Date> {
        let normalizedStartDate = Calendar.current.startOfDay(for: startDate)
        let normalizedEndDate = Date()
        return normalizedStartDate...normalizedEndDate
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Date Range")
                            .font(.headline)
                        
                        HStack {
                            DatePicker("Start", selection: $startDate, in: ...endDate, displayedComponents: .date)
                            Spacer()
                            DatePicker("End", selection: $endDate, in: startDate...Date(), displayedComponents: .date)
                        }
                    }
                    
                        // Cardio Progress Section
                    CardioProgressView(exercises: allCardio.filter { dateRange.contains($0.exerciseDate) })
                    
                        // Strength Progress Section
                    StrengthProgressView(exercises: allStrength.filter { dateRange.contains($0.exerciseDate) })
                    
                        // Display Last Recorded Exercise if there is one.
                    if let lastExercise = viewModel.lastExercise {
                        LastExerciseAddedView(exercise: lastExercise)
                    } else {
                        Text("No exercises recorded yet.")
                            .foregroundColor(.secondary)
                            .padding()
                    }
                }
                .padding(.top, -30) // Adjusted for smaller top padding
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
                        Button("Data Sync") {
                            showDataSyncSheet.toggle()
                        }
                    } label: {
                        Label("Utility", systemImage: "gearshape")
                            .font(.caption2)
                    }
                }
            }
                // If cardio exercise or strength exercise was added - then refresh last exercise data.
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
