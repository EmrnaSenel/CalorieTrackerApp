//
//  WeightEntry.swift
//  CalorieTracker
//
//  Created by Emrina Şenel.
//

import Foundation
import SwiftData

@Model
final class WeightEntry: Identifiable {
    var id: UUID
    var weight: Double
    var date: Date
    
    init(weight: Double) {
        self.id = UUID()
        self.weight = weight
        self.date = Date()
    }
    
    // Add a computed property for formatted date
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
} 
