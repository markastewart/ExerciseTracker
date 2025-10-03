//
//  ExerciseEntryView.swift
//  ExerciseTracker
//
//  Created by Mark A Stewart on 10/2/25.
//

import SwiftUI

import SwiftUI

struct ExerciseEntryView: View {
    @Environment(\.dismiss) var dismiss
    @State private var viewModel: ExerciseEntryViewModel
    @State private var showingDeleteAlert = false
    
        // Custom initializer to accept either a Cardio or Strength model for editing
    init(exerciseMode: ExerciseType, editingCardio: CardioExercise? = nil, editingStrength: StrengthExercise? = nil) {
        _viewModel = State(initialValue: ExerciseEntryViewModel(
            exerciseMode: exerciseMode,
            editingCardio: editingCardio,
            editingStrength: editingStrength
        ))
    }
    
    private var isEditing: Bool {
        viewModel.isEditing
    }
    
    var body: some View {
        Form {
                // Select the specific exercise type (e.g., Treadmill, Bicep Curl)
            Picker("Exercise Type", selection: $viewModel.exerciseType) {
                ForEach(viewModel.allTypes, id: \.self) { type in
                    Text(type)
                }
            }
                // Date Picker
            DatePickerView(initialDate: $viewModel.exerciseDate)
                // Only load last entry data when user changes the type when creating a new entry
                .onChange(of: viewModel.exerciseType) {
                    viewModel.loadLastEntry()
                }
            
            Section("Details") {
                if viewModel.mode == .cardio {
                    CardioDetailsSection(viewModel: viewModel)
                }
                else {
                    StrengthDetailsSection(viewModel: viewModel)
                }
            }
        }
        .navigationTitle(isEditing ? "Edit \(viewModel.mode.rawValue) Exercise" : "Add \(viewModel.mode.rawValue) Exercise")
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
                    .buttonStyle(.borderedProminent).tint(.gray)
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    viewModel.saveOrUpdateExercise()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            if isEditing {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .destructive) { showingDeleteAlert = true }
                    label: { Image(systemName: "trash").foregroundColor(.red) }
                }
            }
        }
        .alert("Delete Entry", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                viewModel.deleteExercise()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to permanently delete this entry?")
        }
        .font(.headline)
    }
}

struct CardioDetailsSection: View {
    @Bindable var viewModel: ExerciseEntryViewModel
    
    var body: some View {
        HStack {
            Text("Duration (min)")
            Spacer()
            TextField("0", value: $viewModel.duration, formatter: NumberFormatter.decimal(1))
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

struct StrengthDetailsSection: View {
    @Bindable var viewModel: ExerciseEntryViewModel
    
    var body: some View {
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

#Preview {
    ExerciseEntryView(exerciseMode: .cardio)
}
