//
//  UserProfile.swift
//  CalorieTracker
//
//  Created by Emrina Şenel.
//

import Foundation
import SwiftData

@Model
final class UserProfile {
    var name: String
    var age: Int
    var gender: String
    var height: Double
    var weight: Double
    var activityLevel: String
    var goal: String
    var goalWeight: Double
    var initialWeight: Double
    var dailyCalorieGoal: Int
    var dailyCalorieBurnGoal: Int
    var createdAt: Date
    
    init(name: String, age: Int, gender: String, height: Double, weight: Double, activityLevel: String, goal: String, goalWeight: Double) {
        self.name = name
        self.age = age
        self.gender = gender
        self.height = height
        self.weight = weight
        self.initialWeight = weight
        self.activityLevel = activityLevel
        self.goal = goal
        self.goalWeight = goalWeight
        self.createdAt = Date()
        self.dailyCalorieGoal = 0 // Initialize with a default value
        self.dailyCalorieBurnGoal = 0 // Initialize with a default value
        
        // Calculate goals after all properties are initialized
        self.dailyCalorieGoal = calculateDailyCalorieGoal()
        self.dailyCalorieBurnGoal = calculateDailyCalorieBurnGoal()
    }
    
    func updateDailyCalorieGoal() {
        self.dailyCalorieGoal = calculateDailyCalorieGoal()
        self.dailyCalorieBurnGoal = calculateDailyCalorieBurnGoal()
    }
    
    func calculateDailyCalorieGoal() -> Int {
        // Calculate BMR using Mifflin-St Jeor Equation
        var bmr: Double
        if gender == Gender.male.rawValue {
            bmr = (10 * weight) + (6.25 * height) - (5 * Double(age)) + 5
        } else {
            bmr = (10 * weight) + (6.25 * height) - (5 * Double(age)) - 161
        }
        print("DEBUG: BMR calculation - Weight: \(weight), Height: \(height), Age: \(age), Gender: \(gender)")
        print("DEBUG: BMR: \(bmr)")
        
        // Apply activity multiplier
        var tdee = bmr
        switch activityLevel {
        case ActivityLevel.sedentary.rawValue:
            tdee *= 1.2  // Little or no exercise
        case ActivityLevel.lightlyActive.rawValue:
            tdee *= 1.375  // Light exercise 1-3 days/week
        case ActivityLevel.moderatelyActive.rawValue:
            tdee *= 1.55  // Moderate exercise 3-5 days/week
        case ActivityLevel.veryActive.rawValue:
            tdee *= 1.725  // Hard exercise 6-7 days/week
        case ActivityLevel.extraActive.rawValue:
            tdee *= 1.9  // Very hard exercise & physical job
        default:
            tdee *= 1.2
            print("DEBUG: Unknown activity level: \(activityLevel), using sedentary multiplier")
        }
        print("DEBUG: TDEE after activity (\(activityLevel)): \(tdee)")
        
        // Calculate weight change rate based on goal
        let weightDifference = goalWeight - weight
        let weeklyWeightChange: Double
        
        switch goal {
        case Goal.loseWeight.rawValue:
            // For weight loss, aim for 0.5-1kg per week
            weeklyWeightChange = min(-0.5, max(-1.0, weightDifference / 12)) // 12 weeks target
            // 1kg of fat is approximately 7700 calories
            let dailyDeficit = (weeklyWeightChange * 7700) / 7
            tdee += dailyDeficit
            print("DEBUG: Weight loss goal - Weekly change: \(weeklyWeightChange)kg, Daily deficit: \(dailyDeficit) calories")
            
        case Goal.gainWeight.rawValue:
            // For weight gain, aim for 0.25-0.5kg per week
            weeklyWeightChange = min(0.5, max(0.25, weightDifference / 12)) // 12 weeks target
            // 1kg of muscle is approximately 5500 calories
            let dailySurplus = (weeklyWeightChange * 5500) / 7
            tdee += dailySurplus
            print("DEBUG: Weight gain goal - Weekly change: \(weeklyWeightChange)kg, Daily surplus: \(dailySurplus) calories")
            
        case Goal.maintainWeight.rawValue:
            weeklyWeightChange = 0
            print("DEBUG: Weight maintenance goal - Keeping TDEE at: \(tdee)")
            
        default:
            weeklyWeightChange = 0
            print("DEBUG: Unknown goal: \(goal), no adjustment made")
        }
        
        // Ensure minimum calorie intake based on gender and age
        let minimumCalories: Double
        if gender == Gender.male.rawValue {
            minimumCalories = age < 18 ? 1800.0 : 1500.0
        } else {
            minimumCalories = age < 18 ? 1600.0 : 1200.0
        }
        
        if tdee < minimumCalories {
            print("DEBUG: Calorie goal below minimum, adjusting from \(tdee) to \(minimumCalories)")
            tdee = minimumCalories
        }
        
        let finalCalories = Int(round(tdee))
        print("DEBUG: Final calorie goal: \(finalCalories) (Goal: \(goal), Weekly target: \(weeklyWeightChange)kg)")
        return finalCalories
    }
    
    func calculateDailyCalorieBurnGoal() -> Int {
        // Base calorie burn from daily activities (excluding exercise)
        var baseBurn: Double
        
        // Calculate base burn based on weight and activity level
        switch activityLevel {
        case ActivityLevel.sedentary.rawValue:
            baseBurn = weight * 2.0  // Very light activity
        case ActivityLevel.lightlyActive.rawValue:
            baseBurn = weight * 3.0  // Light activity
        case ActivityLevel.moderatelyActive.rawValue:
            baseBurn = weight * 4.0  // Moderate activity
        case ActivityLevel.veryActive.rawValue:
            baseBurn = weight * 5.0  // High activity
        case ActivityLevel.extraActive.rawValue:
            baseBurn = weight * 6.0  // Very high activity
        default:
            baseBurn = weight * 2.0
        }
        
        // Adjust burn goal based on user's goal
        var burnGoal: Double
        switch goal {
        case Goal.loseWeight.rawValue:
            // For weight loss, aim for higher calorie burn
            burnGoal = baseBurn * 1.5
            print("DEBUG: Weight loss burn goal - Base: \(baseBurn), Target: \(burnGoal)")
            
        case Goal.maintainWeight.rawValue:
            // For maintenance, aim for moderate calorie burn
            burnGoal = baseBurn * 1.2
            print("DEBUG: Weight maintenance burn goal - Base: \(baseBurn), Target: \(burnGoal)")
            
        case Goal.gainWeight.rawValue:
            // For weight gain, focus less on calorie burn
            burnGoal = baseBurn * 0.8
            print("DEBUG: Weight gain burn goal - Base: \(baseBurn), Target: \(burnGoal)")
            
        default:
            burnGoal = baseBurn
            print("DEBUG: Default burn goal - Base: \(baseBurn), Target: \(burnGoal)")
        }
        
        // Ensure minimum daily burn goal
        let minimumBurn = 200.0 // Minimum 200 calories burn per day
        burnGoal = max(burnGoal, minimumBurn)
        
        let finalBurnGoal = Int(round(burnGoal))
        print("DEBUG: Final daily burn goal: \(finalBurnGoal) calories")
        return finalBurnGoal
    }
}

enum ActivityLevel: String, Codable, CaseIterable {
    case sedentary = "Sedentary (little or no exercise)"
    case lightlyActive = "Lightly active (light exercise 1-3 days/week)"
    case moderatelyActive = "Moderately active (moderate exercise 3-5 days/week)"
    case veryActive = "Very active (hard exercise 6-7 days/week)"
    case extraActive = "Extra active (very hard exercise & physical job)"
}

enum Gender: String, Codable, CaseIterable {
    case male = "Male"
    case female = "Female"
} 
