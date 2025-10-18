//
//  ExerciseEntryView.swift
//  ExerciseTracker
//
//  Created by Mark A Stewart on 10/2/25.
//

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
            
            Section("Historical Data") {
                if viewModel.mode == .cardio {
                    CardioHistoricalSection(viewModel: viewModel)
                }
                else {
                    StrengthHistoricalSection(viewModel: viewModel)
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
            Text("Duration (min):")
            Spacer()
            TextField("0", value: $viewModel.duration, formatter: NumberFormatter.decimal(1))
                .keyboardType(.decimalPad)
        }
        HStack {
            Text("Distance (miles):")
            Spacer()
            TextField("0", value: $viewModel.distance, formatter: NumberFormatter.decimal(2))
                .keyboardType(.decimalPad)
        }
        HStack {
            Text("Calories:")
            Spacer()
            TextField("0", value: $viewModel.calories, formatter: NumberFormatter())
                .keyboardType(.decimalPad)
        }
        HStack {
            Text("Incline (%):")
            Spacer()
            TextField("0", value: $viewModel.incline, formatter: NumberFormatter.decimal(1))
                .keyboardType(.decimalPad)
        }
        Text("Pace (mph): \(viewModel.calculatedPace, specifier: "%.2f")")
    }
}

struct CardioHistoricalSection: View {
    @Bindable var viewModel: ExerciseEntryViewModel
    
    var body: some View {
        Grid(alignment: .trailing, horizontalSpacing: 25, verticalSpacing: 18) {
            GridRow {
                Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
                Text("Average")
                Text("Personal Best")
            }
            
            Divider()
                .gridCellUnsizedAxes(.horizontal)
                .gridCellColumns(3)
            
            GridRow {
                Text("Pace")
                Text("\(viewModel.averagePace, specifier: "%.2f")")
                Text("\(viewModel.personalBestPace, specifier: "%.2f")")
            }
            
            Divider()
                .gridCellUnsizedAxes(.horizontal)
                .gridCellColumns(3)
            
            GridRow {
                Text("Calories")
                Text("\(viewModel.averageCalories)")
                Text("\(viewModel.personalBestCalories)")
            }
        }
        .font(.subheadline)
        .foregroundColor(.primary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
    }
}

struct StrengthHistoricalSection: View {
    @Bindable var viewModel: ExerciseEntryViewModel
    
    var body: some View {
//        Text("Average Pace: \(viewModel.averagePace, specifier: "%.2f")")
//        Text("Average Calories: \(viewModel.averageCalories)")
//        Text("Personal Best Pace: \(viewModel.personalBestPace, specifier: "%.2f")")
//        Text("Personal Best Calories: \(viewModel.personalBestCalories)")
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
            TextField("0", value: $viewModel.weight, formatter: NumberFormatter.inputDecimal(maxDigits: 1))
                .keyboardType(.decimalPad)
        }
    }
}

#Preview {
    ExerciseEntryView(exerciseMode: .cardio)
}
