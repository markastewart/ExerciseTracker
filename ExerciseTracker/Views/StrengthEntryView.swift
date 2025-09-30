//
//  StrengthEntryView.swift
//  ExerciseTracker
//
//  Created by Mark A Stewart on 9/6/25.
//

import SwiftUI

struct StrengthEntryView: View {
    @Environment(\.dismiss) var dismiss
    @State private var viewModel: StrengthEntryViewModel
    @State private var showingDeleteAlert = false
    
    init(editingExercise: StrengthExercise? = nil) {
        _viewModel = State(initialValue: StrengthEntryViewModel(editingExercise: editingExercise))
    }
    
    private var isEditing: Bool {
        viewModel.editingExercise != nil
    }
    
    var body: some View {
        Form {
            DatePickerView(initialDate: $viewModel.exerciseDate)
            
            Picker("Exercise Type", selection: $viewModel.exerciseType) {
                ForEach(viewModel.strengthTypes, id: \.self) { type in
                    Text(type)
                }
            }
            .onChange(of: viewModel.exerciseType) {
                if !isEditing {
                    viewModel.loadLastStrengthEntry()
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
        .navigationTitle(isEditing ? "Edit Strength Entry" : "Add Strength Exercise")
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(.gray)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    viewModel.saveOrUpdateStrength()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
                // Show delete button only when editing
            if isEditing {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .alert("Delete Entry", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                viewModel.deleteStrength()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to permanently delete this strength entry?")
        }
        .font(.headline)
    }
}

#Preview {
    StrengthEntryView()
}
