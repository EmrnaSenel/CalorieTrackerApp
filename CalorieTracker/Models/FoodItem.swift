import Foundation

struct FoodItem: Identifiable {
    let id: String
    let name: String
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    let servingSize: Double
    let servingUnit: String
    let category: String
} 