//
//  FoodAnalysisViewModel.swift
//  CalorieTracker
//
//  Created by Emrina Şenel.
//

import Foundation
import Vision
import UIKit
import SwiftData
import Combine
import SwiftUI

@MainActor
class FoodAnalysisViewModel: ObservableObject {
    @Published var isAnalyzing = false
    @Published var error: Error?
    @Published var foodAnalysis: FoodAnalysis?
    @Published var isLoading = false
    @Published var foodImageData: Data?
    @Published var testResults: String?
    @Published var recognizedFoodItem: String?
    
    private let modelContext: ModelContext
    private let usdaAPI: USDAFoodDatabase
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.usdaAPI = USDAFoodDatabase(apiKey: APIConfig.usdaAPIKey)
    }
    
    func analyzeFoodImage(_ image: UIImage) async throws -> FoodAnalysis {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw FoodAnalysisError.imageProcessingFailed
        }
        
        let base64String = imageData.base64EncodedString()
        
        // Create URL request for Roboflow API
        guard let url = URL(string: "https://serverless.roboflow.com/food-detection-jqc5f/1?api_key=FB6nQXnG1jfaP1wGPoEp") else {
            throw FoodAnalysisError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = base64String.data(using: .utf8)
        
        // Make API request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw FoodAnalysisError.apiError
        }
        
        // Parse response
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let predictions = json["predictions"] as? [[String: Any]] else {
            throw FoodAnalysisError.invalidResponse
        }
        
        // Get the highest confidence prediction
        guard let bestPrediction = predictions.max(by: { 
            ($0["confidence"] as? Double ?? 0) < ($1["confidence"] as? Double ?? 0)
        }) else {
            throw FoodAnalysisError.noFoodDetected
        }
        
        guard let detectedFood = bestPrediction["class"] as? String,
              let confidence = bestPrediction["confidence"] as? Double,
              confidence > 0.3 else {
            throw FoodAnalysisError.noFoodDetected
        }
        
        print("Detected food: \(detectedFood) with confidence: \(confidence)")
        
        // Try to get nutritional information for the detected food
        do {
            let analysis = try await analyzeFood(detectedFood)
            return analysis
        } catch {
            print("Error getting nutritional info: \(error.localizedDescription)")
            throw FoodAnalysisError.nutritionalInfoNotFound
        }
    }
    
    func saveMeal(name: String, calories: Double, protein: Double, carbs: Double, fat: Double) {
        let meal = Meal(
            name: name,
            calories: Int(calories),
            protein: protein,
            carbohydrates: carbs,
            fat: fat
        )
        modelContext.insert(meal)
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving meal: \(error)")
        }
    }
    
    // Test function to verify API integration
    func testUSDAAPI() async throws -> [USDAFood] {
        return try await usdaAPI.searchFood(query: "ice cream")
    }
    
    private func isImageDark(_ image: UIImage) -> Bool {
        guard let cgImage = image.cgImage else { return false }
        
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        let bitsPerComponent = 8
        var rawData = [UInt8](repeating: 0, count: width * height * bytesPerPixel)
        
        guard let context = CGContext(
            data: &rawData,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return false }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        var totalBrightness: Double = 0
        let pixelCount = width * height
        
        for i in stride(from: 0, to: rawData.count, by: 4) {
            let r = Double(rawData[i])
            let g = Double(rawData[i + 1])
            let b = Double(rawData[i + 2])
            
            // Calculate brightness using the formula: (0.299*R + 0.587*G + 0.114*B)
            let brightness = (0.299 * r + 0.587 * g + 0.114 * b) / 255.0
            totalBrightness += brightness
        }
        
        let averageBrightness = totalBrightness / Double(pixelCount)
        return averageBrightness < 0.5 // Consider image dark if average brightness is less than 50%
    }
    
    private func isImageBlurry(_ image: UIImage) -> Bool {
        guard let cgImage = image.cgImage else { return false }
        
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        let bitsPerComponent = 8
        var rawData = [UInt8](repeating: 0, count: width * height * bytesPerPixel)
        
        guard let context = CGContext(
            data: &rawData,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return false }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        // Calculate the Laplacian variance to detect blur
        var laplacianSum: Double = 0
        let pixelCount = width * height
        
        for y in 1..<height-1 {
            for x in 1..<width-1 {
                let idx = (y * width + x) * bytesPerPixel
                let idxUp = ((y-1) * width + x) * bytesPerPixel
                let idxDown = ((y+1) * width + x) * bytesPerPixel
                let idxLeft = (y * width + (x-1)) * bytesPerPixel
                let idxRight = (y * width + (x+1)) * bytesPerPixel
                
                let center = Double(rawData[idx])
                let up = Double(rawData[idxUp])
                let down = Double(rawData[idxDown])
                let left = Double(rawData[idxLeft])
                let right = Double(rawData[idxRight])
                
                let laplacian = abs(4 * center - up - down - left - right)
                laplacianSum += laplacian
            }
        }
        
        let laplacianVariance = laplacianSum / Double(pixelCount)
        return laplacianVariance < 100 // Consider image blurry if Laplacian variance is less than 100
    }
    
    func analyzeFood(_ foodName: String) async throws -> FoodAnalysis {
        isLoading = true
        error = nil
        
        defer {
            isLoading = false
        }
        
        do {
            // First try to search with the exact food name
            var foods = try await usdaAPI.searchFood(query: foodName)
            print("\n=== USDA API Search Results ===")
            print("Search query: '\(foodName)'")
            print("Number of results: \(foods.count)")
            
            // If no results found, try with common variations
            if foods.isEmpty {
                let variations = getFoodVariations(for: foodName)
                print("\nTrying variations: \(variations)")
                for variation in variations {
                    foods = try await usdaAPI.searchFood(query: variation)
                    if !foods.isEmpty { break }
                }
            }
            
            if let firstFood = foods.first {
                print("\n=== Selected Food Item ===")
                print("Description: \(firstFood.description)")
                print("FDC ID: \(firstFood.fdcId)")
                
                // Get specific nutrient values
                let rawCalories = firstFood.foodNutrients.first(where: { $0.nutrientName == "Energy" })?.value ?? 0
                let rawProtein = firstFood.foodNutrients.first(where: { $0.nutrientName == "Protein" })?.value ?? 0
                let rawCarbs = firstFood.foodNutrients.first(where: { $0.nutrientName == "Carbohydrate, by difference" })?.value ?? 0
                let rawFat = firstFood.foodNutrients.first(where: { $0.nutrientName == "Total lipid (fat)" })?.value ?? 0
                
                // Convert USDA values (per 100g) to typical serving sizes
                let servingSize = getServingSize(for: foodName)
                let multiplier = servingSize / 100.0
                
                let adjustedCalories = rawCalories * multiplier
                let adjustedProtein = rawProtein * multiplier
                let adjustedCarbs = rawCarbs * multiplier
                let adjustedFat = rawFat * multiplier
                
                // Print the values that will be displayed in the UI
                print("\n=== USDA Values Displayed in App ===")
                print("Food: \(firstFood.description)")
                print("Calories: \(Int(adjustedCalories)) kcal")
                print("Protein: \(String(format: "%.1f", adjustedProtein)) g")
                print("Carbs: \(String(format: "%.1f", adjustedCarbs)) g")
                print("Fat: \(String(format: "%.1f", adjustedFat)) g")
                
                return FoodAnalysis(
                    name: firstFood.description,
                    calories: adjustedCalories,
                    protein: adjustedProtein,
                    carbs: adjustedCarbs,
                    fat: adjustedFat
                )
            } else {
                print("\nNo USDA results found")
                throw FoodAnalysisError.nutritionalInfoNotFound
            }
        } catch {
            print("\nUSDA API error: \(error.localizedDescription)")
            throw error
        }
    }
    
    private func getFoodVariations(for foodName: String) -> [String] {
        let lowercasedFood = foodName.lowercased()
        var variations: [String] = []
        
        // Common food type variations
        if lowercasedFood.contains("burger") {
            variations = ["hamburger", "cheeseburger", "beef burger", "fast food burger"]
        } else if lowercasedFood.contains("pizza") {
            variations = ["cheese pizza", "pepperoni pizza", "pizza slice"]
        } else if lowercasedFood.contains("sandwich") {
            variations = ["turkey sandwich", "chicken sandwich", "club sandwich"]
        } else if lowercasedFood.contains("salad") {
            variations = ["garden salad", "caesar salad", "green salad"]
        } else if lowercasedFood.contains("chicken") {
            variations = ["chicken breast", "roasted chicken", "grilled chicken"]
        } else if lowercasedFood.contains("pasta") {
            variations = ["spaghetti", "fettuccine", "penne pasta"]
        }
        
        // Add the original food name as the first variation
        variations.insert(foodName, at: 0)
        return variations
    }
    
    private func getServingSize(for foodName: String) -> Double {
        let lowercasedFood = foodName.lowercased()
        
        // Typical serving sizes in grams for common foods
        let servingSizes: [String: Double] = [
            // Fast Food
            "burger": 170.0,      // Standard hamburger patty + bun
            "cheeseburger": 170.0, // Standard cheeseburger
            "big mac": 219.0,     // McDonald's Big Mac
            "whopper": 270.0,     // Burger King Whopper
            
            // Pizza
            "pizza": 170.0,       // One slice of pizza
            "pepperoni pizza": 170.0,
            
            // Sandwiches
            "sandwich": 200.0,    // Standard sandwich
            "sub": 250.0,         // 6-inch sub
            "club sandwich": 300.0,
            
            // Fries and Sides
            "fries": 117.0,       // Medium fries
            "onion rings": 150.0,
            "nuggets": 100.0,     // 4-piece serving
            
            // Other Fast Food
            "taco": 170.0,        // Regular taco
            "burrito": 300.0,     // Regular burrito
            "hot dog": 150.0,     // Regular hot dog with bun
        ]
        
        // Try to find a match in the serving sizes
        for (key, size) in servingSizes {
            if lowercasedFood.contains(key) {
                return size
            }
        }
        
        // Default serving sizes based on food type
        if lowercasedFood.contains("burger") || lowercasedFood.contains("hamburger") {
            return 170.0  // Standard hamburger
        } else if lowercasedFood.contains("pizza") {
            return 170.0  // One slice
        } else if lowercasedFood.contains("sandwich") || lowercasedFood.contains("sub") {
            return 200.0  // Standard sandwich
        } else if lowercasedFood.contains("fries") || lowercasedFood.contains("chips") {
            return 117.0  // Medium fries
        } else if lowercasedFood.contains("taco") || lowercasedFood.contains("burrito") {
            return 235.0  // Average Mexican fast food
        } else if lowercasedFood.contains("hot dog") || lowercasedFood.contains("sausage") {
            return 150.0  // Regular hot dog
        }
        
        return 100.0  // Default to 100g if no match found
    }
    
    private func getDefaultValues(for foodName: String) -> (calories: Double, protein: Double, carbs: Double, fat: Double) {
        // Updated common food items with accurate nutritional values per serving
        let foodValues: [String: (calories: Double, protein: Double, carbs: Double, fat: Double)] = [
            // Fast Food
            "burger": (550.0, 25.0, 45.0, 30.0),  // Standard hamburger
            "cheeseburger": (550.0, 25.0, 45.0, 30.0),  // Standard cheeseburger
            "big mac": (550.0, 25.0, 45.0, 30.0),  // McDonald's Big Mac
            "whopper": (660.0, 28.0, 49.0, 40.0),  // Burger King Whopper
            
            // Pizza
            "pizza": (300.0, 12.0, 35.0, 15.0),  // Regular cheese pizza slice
            "pepperoni pizza": (350.0, 15.0, 35.0, 20.0),  // Pepperoni pizza slice
            
            // Sandwiches
            "sandwich": (350.0, 15.0, 40.0, 15.0),  // Average sandwich
            "sub": (400.0, 20.0, 45.0, 18.0),  // Sub sandwich
            "club sandwich": (550.0, 35.0, 45.0, 25.0),  // Club sandwich
            
            // Fries and Sides
            "fries": (365.0, 4.0, 48.0, 17.0),  // Medium fries
            "onion rings": (411.0, 5.0, 45.0, 24.0),  // Onion rings
            "nuggets": (250.0, 14.0, 15.0, 15.0),  // Chicken nuggets
            
            // Other Fast Food
            "taco": (170.0, 8.0, 13.0, 9.0),  // Regular taco
            "burrito": (500.0, 20.0, 60.0, 20.0),  // Regular burrito
            "hot dog": (290.0, 10.0, 18.0, 18.0),  // Regular hot dog
        ]
        
        // Try to find a match in the food values
        let lowercasedFood = foodName.lowercased()
        for (key, values) in foodValues {
            if lowercasedFood.contains(key) {
                return values
            }
        }
        
        // If no match is found, return a default value based on food type
        if lowercasedFood.contains("burger") || lowercasedFood.contains("hamburger") {
            return (550.0, 25.0, 45.0, 30.0)  // Standard hamburger
        } else if lowercasedFood.contains("pizza") {
            return (300.0, 12.0, 35.0, 15.0)  // Regular cheese pizza slice
        } else if lowercasedFood.contains("sandwich") || lowercasedFood.contains("sub") {
            return (350.0, 15.0, 40.0, 15.0)  // Average sandwich
        } else if lowercasedFood.contains("fries") || lowercasedFood.contains("chips") {
            return (365.0, 4.0, 48.0, 17.0)  // Medium fries
        } else if lowercasedFood.contains("taco") || lowercasedFood.contains("burrito") {
            return (335.0, 14.0, 36.5, 14.5)  // Average Mexican fast food
        } else if lowercasedFood.contains("hot dog") || lowercasedFood.contains("sausage") {
            return (290.0, 10.0, 18.0, 18.0)  // Regular hot dog
        }
        
        // Default values if no match is found
        return (500.0, 20.0, 45.0, 25.0)  // Generic fast food default
    }
    
    func analyzeFood(image: UIImage?, name: String, notes: String) async throws -> Meal {
        isAnalyzing = true
        error = nil
        
        defer {
            isAnalyzing = false
        }
        
        // Try to find the food in USDA database
        do {
            let foods = try await usdaAPI.searchFood(query: name)
            if let food = foods.first {
                let meal = Meal(
                    name: name,
                    calories: Int(food.foodNutrients.first(where: { $0.nutrientName == "Energy" })?.value ?? 0),
                    protein: food.foodNutrients.first(where: { $0.nutrientName == "Protein" })?.value ?? 0,
                    carbohydrates: food.foodNutrients.first(where: { $0.nutrientName == "Carbohydrate, by difference" })?.value ?? 0,
                    fat: food.foodNutrients.first(where: { $0.nutrientName == "Total lipid (fat)" })?.value ?? 0,
                    notes: notes,
                    isActivity: false
                )
                
                // Convert image to data if available
                if let image = image {
                    meal.imageData = image.jpegData(compressionQuality: 0.8)
                }
                
                modelContext.insert(meal)
                try modelContext.save()
                return meal
            }
        } catch {
            print("USDA API error: \(error.localizedDescription)")
        }
        
        // If API call fails or no match found, use default values
        let defaultValues = getDefaultValues(for: name)
        let meal = Meal(
            name: name,
            calories: Int(defaultValues.calories),
            protein: defaultValues.protein,
            carbohydrates: defaultValues.carbs,
            fat: defaultValues.fat,
            notes: notes,
            isActivity: false
        )
        
        if let image = image {
            meal.imageData = image.jpegData(compressionQuality: 0.8)
        }
        
        modelContext.insert(meal)
        try modelContext.save()
        return meal
    }
    
    func addActivity(name: String, duration: Int, notes: String) async throws -> Meal {
        let calories = calculateCaloriesBurned(activity: name, duration: duration)
        
        let meal = Meal(
            name: name,
            calories: calories,
            protein: 0,
            carbohydrates: 0,
            fat: 0,
            notes: notes,
            isActivity: true,
            duration: duration
        )
        
        modelContext.insert(meal)
        try modelContext.save()
        return meal
    }
    
    func calculateCaloriesBurned(activity: String, duration: Int) -> Int {
        // Base calories burned per minute for different activities
        let caloriesPerMinute: [String: Double] = [
            "Running": 10.0,
            "Walking": 4.0,
            "Cycling": 8.0,
            "Swimming": 7.0,
            "Yoga": 3.0,
            "Weight Lifting": 5.0
        ]
        
        // Get the base rate for the activity, default to 5 if unknown
        let baseRate = caloriesPerMinute[activity] ?? 5.0
        
        // Calculate total calories burned
        return Int(baseRate * Double(duration))
    }
}

struct NutritionInfo {
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
}

enum AnalysisError: Error {
    case invalidImage
    case noResults
    case analysisFailed
}

enum FoodAnalysisError: Error {
    case imageProcessingFailed
    case invalidURL
    case apiError
    case invalidResponse
    case noFoodDetected
    case nutritionalInfoNotFound
} 
