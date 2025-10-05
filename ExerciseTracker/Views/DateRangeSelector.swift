//
//  DateRangeSelector.swift
//  ExerciseTracker
//
//  Created by Mark A Stewart on 9/24/25.
//

import SwiftUI

    /// Re-usable date range picker with presets + optional custom range
struct DateRangeSelector: View {
    @Binding var dateRangeService: DateRangeService

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Date Range")
                    .font(.headline)
                Menu {
                    ForEach(TimePeriod.allCases) { option in
                        Button(option.displayName) {
                            dateRangeService.selectedPeriod = option
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(dateRangeService.selectedPeriod.displayName)
                        Image(systemName: "chevron.down")
                            .font(.subheadline)
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
                }
            }
                // DatePickers bind directly to the DataRangeService custom date properties. The didSet logic in the DataRangeService will handle recalculation.
            if dateRangeService.selectedPeriod == .custom {
                HStack {
                     DatePicker("From", selection: $dateRangeService.customStartDate, in: ...dateRangeService.customEndDate, displayedComponents: .date)
                         .onChange(of: dateRangeService.customStartDate) { _, _ in
                             dateRangeService.setCustomDateRange(start: dateRangeService.customStartDate, end: dateRangeService.customEndDate)
                         }
                    
                    DatePicker("To", selection: $dateRangeService.customEndDate, in: dateRangeService.customStartDate...Date.now, displayedComponents: .date)
                 }
                .padding(.horizontal)
                .padding(.vertical, 5)
                .font(.subheadline)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension DateFormatter {
    static let monthDayYear: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "MMM dd, yyyy" // e.g. Oct 05, 2025
        return df
    }()
}

#Preview {
//    DateRangeSelector()
}
