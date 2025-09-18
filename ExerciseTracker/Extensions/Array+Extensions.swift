//
//  Array+Extensions.swift
//  ExerciseTracker
//
//  Created by Mark A Stewart on 9/10/25.
//

import Foundation

public extension Array where Element == String {
    /// Allows using a RawRepresentable enum case with an Int raw value as an index.
    subscript<Index: RawRepresentable>(index: Index) -> String where Index.RawValue == Int {
        return self[index.rawValue]
    }
}
