//
//  Meal.swift
//  CalorieTracker
//
//  Created by Emrina Şenel.
//

import Foundation
import SwiftData

@Model
final class Meal {
    var name: String
    var timestamp: Date
    var calories: Int
    var protein: Double // in grams
    var carbohydrates: Double // in grams
    var fat: Double // in grams
    var imageData: Data?
    var notes: String?
    var isActivity: Bool
    var duration: Int? // in minutes, for activities
    
    init(name: String, calories: Int, protein: Double, carbohydrates: Double, fat: Double, imageData: Data? = nil, notes: String? = nil, isActivity: Bool = false, duration: Int? = nil) {
        self.name = name
        self.timestamp = Date()
        self.calories = calories
        self.protein = protein
        self.carbohydrates = carbohydrates
        self.fat = fat
        self.imageData = imageData
        self.notes = notes
        self.isActivity = isActivity
        self.duration = duration
    }
    
    var totalMacronutrients: Double {
        return protein + carbohydrates + fat
    }
    
    var proteinPercentage: Double {
        guard totalMacronutrients > 0 else { return 0 }
        return (protein / totalMacronutrients) * 100
    }
    
    var carbsPercentage: Double {
        guard totalMacronutrients > 0 else { return 0 }
        return (carbohydrates / totalMacronutrients) * 100
    }
    
    var fatPercentage: Double {
        guard totalMacronutrients > 0 else { return 0 }
        return (fat / totalMacronutrients) * 100
    }
    
    // For activities, calories are stored as negative values
    var effectiveCalories: Int {
        return isActivity ? -calories : calories
    }
} 
