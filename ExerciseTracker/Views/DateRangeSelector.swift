//
//  DateRangeSelector.swift
//  ExerciseTracker
//
//  Created by Mark A Stewart on 9/24/25.
//

import SwiftUI

    /// Re-usable date range picker with presets + optional custom range
struct DateRangeSelector: View {
    @ObservedObject var dateRangeService: DateRangeService
    @State private var customStartDate: Date = .now
    @State private var customEndDate: Date = .now

    var body: some View {
        VStack(alignment: .leading) {
             HStack {
                 Text("Date Range").font(.headline)
                 Menu {
                     ForEach(TimePeriod.allCases) { option in
                         Button(option.displayName) {
                             dateRangeService.selectedPeriod = option
                         }
                     }
                 } label: {
                     HStack(spacing: 4) {
                         Text(dateRangeService.selectedPeriod.displayName)
                         Image(systemName: "chevron.down").font(.subheadline)
                     }
                     .padding(.vertical, 6)
                     .padding(.horizontal, 10)
                     .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
                 }
             }

             if dateRangeService.selectedPeriod == .custom {
                 HStack {
                     DatePicker("From",
                                selection: $dateRangeService.customStartDate,
                                displayedComponents: .date)

                     DatePicker("To",
                                selection: $dateRangeService.customEndDate,
                                displayedComponents: .date)
                 }
                 .padding(.horizontal)
                 .padding(.vertical, 5)
                 .font(.subheadline)
                 .onChange(of: dateRangeService.customStartDate) { _, _ in
                     dateRangeService.setCustomDateRange(start: dateRangeService.customStartDate, end: dateRangeService.customEndDate)
                 }
                 .onChange(of: dateRangeService.customEndDate) { _, _ in
                     dateRangeService.setCustomDateRange(start: dateRangeService.customStartDate, end: dateRangeService.customEndDate)
                 }
             }
         }
         .frame(maxWidth: .infinity, alignment: .leading)
     }
}

#Preview {
//    DateRangeSelector()
}
