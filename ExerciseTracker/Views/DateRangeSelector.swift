//
//  DateRangeSelector.swift
//  ExerciseTracker
//
//  Created by Mark A Stewart on 9/24/25.
//

import SwiftUI
import SwiftData

/// Re-usable date range picker with presets + optional custom range
struct DateRangeSelector: View {
    enum RangeChoice: String, CaseIterable, Identifiable {
        case week   = "Last 7 Days"
        case month  = "Last Month"
        case six    = "Last 6 Months"
        case year   = "Last Year"
        case custom = "Custom"
        var id: String { rawValue }
    }

    @Binding var startDate: Date
    @Binding var endDate: Date
    @Binding var choice: RangeChoice

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Date Range")
                    .font(.headline)
                Menu {
                    ForEach(RangeChoice.allCases) { option in
                        Button(option.rawValue) {
                            setDates(for: option)
                            choice = option
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(choice.rawValue)
                        Image(systemName: "chevron.down")
                            .font(.subheadline)
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
                }
            }
            
            if choice == .custom {
                HStack {
                    DatePicker("From", selection: $startDate, in: ...endDate, displayedComponents: .date)
                    DatePicker("To", selection: $endDate, in: startDate...Date.now, displayedComponents: .date)
                }
                .font(.headline)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear {
            if choice != .custom {
                setDates(for: choice)
            }
        }
            // Handle manual selection change (e.g., user switches from .month to .week
        .onChange(of: choice) { _, newRange in
            if newRange != .custom {
                setDates(for: newRange)
            }
        }
            // Handle external updates (e.g., new exercise). Dates are "refreshed" to the current time if a relative range is selected. By watching Date.now, ensure range (like "Last 7 Days") is always pinned to now.
        .onChange(of: Date.now) {
            if choice != .custom {
                setDates(for: choice)
            }
        }
    }

    private func setDates(for range: RangeChoice) {
        let now = Date.now
        switch range {
        case .week:
            startDate = Calendar.current.date(byAdding: .day, value: -6, to: now)!
            endDate   = now
        case .month:
            startDate = Calendar.current.date(byAdding: .month, value: -1, to: now)!
            endDate   = now
        case .six:
            startDate = Calendar.current.date(byAdding: .month, value: -6, to: now)!
            endDate   = now
        case .year:
            startDate = Calendar.current.date(byAdding: .year, value: -1, to: now)!
            endDate   = now
        case .custom:
            break
        }
    }
}


#Preview {
//    DateRangeSelector()
}
