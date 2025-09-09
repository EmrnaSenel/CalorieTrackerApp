import Foundation
import SwiftData

@Model
final class Food {
    var name: String
    var calories: Double
    var protein: Double
    var carbs: Double
    var fat: Double
    var date: Date
    
    init(name: String, calories: Double, protein: Double, carbs: Double, fat: Double, date: Date = Date()) {
        self.name = name
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.date = date
    }
} 