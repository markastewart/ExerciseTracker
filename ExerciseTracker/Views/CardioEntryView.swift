//
//  CardioEntryView.swift
//  ExerciseTracker
//
//  Created by Mark A Stewart on 9/6/25.
//

import SwiftUI

    // MARK: - Cardio Entry View

struct CardioEntryView: View {
    @Environment(\.dismiss) var dismiss
    @State private var viewModel: CardioEntryViewModel
    @State private var showingDeleteAlert = false
    
        // Custom initializer to accept the exercise model for editing or nil for a new entry
    init(editingExercise: CardioExercise? = nil) {
        _viewModel = State(initialValue: CardioEntryViewModel(editingExercise: editingExercise))
    }
    
    private var isEditing: Bool {
        viewModel.editingExercise != nil
    }
    
    var body: some View {
        Form {
            DatePickerView(initialDate: $viewModel.exerciseDate)
            
            Picker("Exercise Type", selection: $viewModel.exerciseType) {
                ForEach(viewModel.cardioTypes, id: \.self) { type in
                    Text(type)
                }
            }
                // Only load last entry data when the user changes the type IF they are creating a new entry
            .onChange(of: viewModel.exerciseType) {
                if !isEditing {
                    viewModel.loadLastCardioEntry()
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
                    Text("Calories")
                    Spacer()
                    TextField("0", value: $viewModel.calories, formatter: NumberFormatter())
                        .keyboardType(.decimalPad)
                }
                HStack {
                    Text("Incline (%)")
                    Spacer()
                    TextField("0", value: $viewModel.incline, formatter: NumberFormatter.decimal(1))
                        .keyboardType(.decimalPad)
                }
            }
        }
            // Update navigation title based on editing state
        .navigationTitle(isEditing ? "Edit Cardio Entry" : "Add Cardio Exercise")
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
                        // Call the unified save/update function
                    viewModel.saveOrUpdateCardio()
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
                viewModel.deleteCardio()
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
    CardioEntryView()
}
