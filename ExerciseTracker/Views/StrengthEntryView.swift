//
//  StrengthEntryView.swift
//  ExerciseTracker
//
//  Created by Mark A Stewart on 9/6/25.
//

import SwiftUI

struct StrengthEntryView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = StrengthEntryViewModel()
    
    var body: some View {
        Form {
            DatePickerView(initialDate: $viewModel.exerciseDate)
            
            Picker("Exercise Type", selection: $viewModel.exerciseType) {
                ForEach(viewModel.strengthTypes, id: \.self) { type in
                    Text(type)
                }
            }
            
            Section("Details") {
                HStack {
                    Text("Sets")
                    Spacer()
                    TextField("0", value: $viewModel.sets, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                }
                HStack {
                    Text("Reps")
                    Spacer()
                    TextField("0", value: $viewModel.reps, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                }
                HStack {
                    Text("Weight (lb)")
                    Spacer()
                    TextField("0", value: $viewModel.weight, formatter: NumberFormatter())
                        .keyboardType(.decimalPad)
                }
            }
        }
        .navigationTitle("Add Strength Exercise")
        .navigationBarBackButtonHidden()
        .onAppear {
            viewModel.loadSortedStrengthTypes()
        }
        .onChange(of: viewModel.exerciseType) {
            viewModel.loadLastStrengthEntry()
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("< Cancel", action: { dismiss() })
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    viewModel.saveStrength()
                    dismiss()
                }
            }
        }.font(.headline)
    }
}

#Preview {
    StrengthEntryView()
}
