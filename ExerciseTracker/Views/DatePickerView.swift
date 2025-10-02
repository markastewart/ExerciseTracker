//
//  DatePickerView.swift
//  ExerciseTracker
//
//  Created by Mark A Stewart on 9/6/25.
//

import SwiftUI

struct DatePickerView: View {
    
    @Binding var initialDate: Date
    
    var body: some View {
        DatePicker("Date", selection: $initialDate, displayedComponents: [.date])
    }
}

#Preview {
    @Previewable @State var selectedDate = Date.now
    return DatePickerView(initialDate: $selectedDate)
}
