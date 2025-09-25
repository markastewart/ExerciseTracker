//
//  CardioProgressViewModel.swift
//  ExerciseTracker
//
//  Created by Mark A Stewart on 9/24/25.
//

import Foundation
import SwiftData

class CardioProgressViewModel: ObservableObject {
//    @Published var exerciseDate: Date
//    @Published var exerciseType: String
//    @Published var duration: TimeInterval
//    @Published var distance: Double
//    @Published var calories: Int
//    @Published var incline: Double
//    @Published var cardioTypes: [String] = []
//    @Published var recordedDate: Date
    
    private let dataService = ExerciseDataService.shared
    
    init() {
//        self.exerciseDate = Date()
//        self.exerciseType = ""
//        self.duration = 0.0
//        self.distance = 0.0
//        self.calories = 0
//        self.incline = 0.0
//        self.recordedDate = Date()
        
            // Init cardioTypes based on previously stored results, set exerciseType to align with most frequently recorded result and fetch its values
//        loadSortedCardioTypes()
//        exerciseType = cardioTypes.first ?? ""
//        loadLastCardioEntry()
        print("init called")
    }
}
