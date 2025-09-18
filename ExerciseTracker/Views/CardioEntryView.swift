//
//  CardioEntryView.swift
//  ExerciseTracker
//
//  Created by Mark A Stewart on 9/6/25.
//

import SwiftUI
import SwiftData

struct CardioEntryView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = CardioEntryViewModel()
    
    var body: some View {
        Form {
            DatePickerView(initialDate: $viewModel.timestamp)
            
            Picker("Exercise Type", selection: $viewModel.exerciseType) {
                ForEach(viewModel.cardioTypes, id: \.self) { type in
                    Text(type)
                }
            }
            
            Section("Details") {
                HStack {
                    Text("Duration (min)")
                    Spacer()
                    TextField("0", value: $viewModel.duration, formatter: NumberFormatter())
                        .keyboardType(.decimalPad)
                }
                HStack {
                    Text("Distance (miles)")
                    Spacer()
                    TextField("0", value: $viewModel.distance, formatter: NumberFormatter.decimal(2))
                        .keyboardType(.decimalPad)
                }
                HStack {
                    Text("Calories") // Updated from Calories Burned
                    Spacer()
                    TextField("0", value: $viewModel.calories, formatter: NumberFormatter())
                        .keyboardType(.decimalPad)
                }
                HStack {
                    Text("Incline (%)") // New field
                    Spacer()
                    TextField("0", value: $viewModel.incline, formatter: NumberFormatter.decimal(1))
                        .keyboardType(.decimalPad)
                }
            }
        }
        .navigationTitle("Add Cardio Exercise")
        .navigationBarBackButtonHidden()
        .onAppear {
            viewModel.fetchSortedCardioTypes()
        }
        .onChange(of: viewModel.exerciseType) {
            viewModel.fetchLastCardioEntry()
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("< Cancel", action: { dismiss() })
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    viewModel.saveCardio()
                    dismiss()
                }
            }
        }.font(.headline)
    }
}

#Preview {
    CardioEntryView()
}
