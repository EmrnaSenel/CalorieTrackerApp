import Foundation

struct USDAFoodResponse: Codable {
    let foods: [USDAFood]
}

struct USDAFood: Codable {
    let fdcId: Int
    let description: String
    let foodNutrients: [FoodNutrient]
}

struct FoodNutrient: Codable {
    let nutrientId: Int
    let nutrientName: String
    let value: Double
} 