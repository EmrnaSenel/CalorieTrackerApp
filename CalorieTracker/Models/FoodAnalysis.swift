import Foundation

struct FoodAnalysis {
    let name: String
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    
    var carbohydrates: Double { carbs } // Alias for compatibility
} 