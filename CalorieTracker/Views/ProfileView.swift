//
//  ProfileView.swift
//  CalorieTracker
//
//  Created by Emrina Şenel.
//

import SwiftUI
import SwiftData
import Charts

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userProfile: [UserProfile]
    @Query(sort: \WeightEntry.date, order: .reverse) private var weightEntries: [WeightEntry]
    
    @State private var showingAddWeight = false
    @State private var showingEditProfile = false
    @State private var showingCreateProfile = false
    @State private var newWeight = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingMainContent = false
    
    // User Profile Data from UserDefaults
    @AppStorage("preferredName") private var name: String = ""
    @AppStorage("userGender") private var gender: String = ""
    @AppStorage("userAge") private var age: Int = 25
    @AppStorage("userHeight") private var height: Double = 170
    @AppStorage("userWeight") private var weight: Double = 70
    @AppStorage("idealWeight") private var idealWeight: Int = 65
    @AppStorage("activityLevel") private var activityLevel: String = ""
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    private var bmi: Double {
        let heightInMeters = height / 100
        return weight / (heightInMeters * heightInMeters)
    }
    
    private var bmiCategory: String {
        switch bmi {
        case ..<18.5: return "Underweight"
        case 18.5..<25: return "Normal weight"
        case 25..<30: return "Overweight"
        default: return "Obese"
        }
    }
    
    private var dailyCalorieNeeds: Int {
        // Calculate BMR using Mifflin-St Jeor Equation
        var bmr: Double
        if gender.lowercased() == "male" {
            bmr = (10 * weight) + (6.25 * height) - (5 * Double(age)) + 5
        } else {
            bmr = (10 * weight) + (6.25 * height) - (5 * Double(age)) - 161
        }
        
        // Apply activity multiplier based on ActivityLevel enum
        let activityMultiplier: Double
        if let activityLevel = ActivityLevel(rawValue: activityLevel) {
            switch activityLevel {
            case .sedentary: activityMultiplier = 1.2
            case .lightlyActive: activityMultiplier = 1.375
            case .moderatelyActive: activityMultiplier = 1.55
            case .veryActive: activityMultiplier = 1.725
            case .extraActive: activityMultiplier = 1.9
            }
        } else {
            activityMultiplier = 1.2 // Default to sedentary if invalid
        }
        
        var tdee = bmr * activityMultiplier
        
        // Adjust calories based on goal
        if let goal = Goal(rawValue: userProfile.first?.goal ?? "") {
            let weightDifference = Double(idealWeight) - weight
            let weeklyWeightChange: Double
            
            switch goal {
            case .loseWeight:
                // Weight loss goal - aim for 0.5-1kg per week
                weeklyWeightChange = max(-1.0, weightDifference / 12) // 12 weeks target
                // 1kg of fat is approximately 7700 calories
                let dailyDeficit = (weeklyWeightChange * 7700) / 7
                tdee += dailyDeficit
                
            case .gainWeight:
                // Weight gain goal - aim for 0.25-0.5kg per week
                weeklyWeightChange = min(0.5, weightDifference / 12) // 12 weeks target
                // 1kg of muscle is approximately 5500 calories
                let dailySurplus = (weeklyWeightChange * 5500) / 7
                tdee += dailySurplus
                
            case .maintainWeight:
                // No adjustment needed for maintenance
                break
            }
        }
        
        // Ensure minimum calorie intake based on gender and age
        let minimumCalories: Double
        if gender.lowercased() == "male" {
            minimumCalories = age < 18 ? 1800.0 : 1500.0
        } else {
            minimumCalories = age < 18 ? 1600.0 : 1200.0
        }
        
        if tdee < minimumCalories {
            tdee = minimumCalories
        }
        
        return Int(round(tdee))
    }
    
    private var weightGoal: String {
        let difference = idealWeight - Int(weight)
        if difference > 0 {
            return "Gain \(difference) kg"
        } else if difference < 0 {
            return "Lose \(abs(difference)) kg"
        } else {
            return "Maintain current weight"
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Profile Header
                    VStack(spacing: 10) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        
                        Text(name.isEmpty ? "User" : name)
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    .padding(.top, 20)
                    
                    // Basic Information
                    VStack(spacing: 15) {
                        InfoRow(title: "Gender", value: gender.isEmpty ? "Not set" : gender)
                        InfoRow(title: "Age", value: "\(age) years")
                        InfoRow(title: "Height", value: String(format: "%.1f cm", height))
                        InfoRow(title: "Current Weight", value: String(format: "%.1f kg", weight))
                        InfoRow(title: "Goal Weight", value: "\(idealWeight) kg")
                        InfoRow(title: "Weight Goal", value: weightGoal)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(.systemGray6))
                    )
                    .padding(.horizontal)
                    
                    // Health Metrics
                    VStack(spacing: 15) {
                        Text("Health Metrics")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        InfoRow(title: "BMI", value: String(format: "%.1f", bmi))
                        InfoRow(title: "BMI Category", value: bmiCategory)
                        InfoRow(title: "Daily Calorie Needs", value: "\(dailyCalorieNeeds) calories")
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(.systemGray6))
                    )
                    .padding(.horizontal)
                    
                    // Weight History Chart
                    if !weightEntries.isEmpty {
                        VStack(spacing: 15) {
                            Text("Weight History")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Chart {
                                ForEach(weightEntries) { entry in
                                    LineMark(
                                        x: .value("Date", entry.date),
                                        y: .value("Weight", entry.weight)
                                    )
                                    .foregroundStyle(.blue)
                                    
                                    PointMark(
                                        x: .value("Date", entry.date),
                                        y: .value("Weight", entry.weight)
                                    )
                                    .foregroundStyle(.blue)
                                }
                            }
                            .frame(height: 200)
                            .chartYScale(domain: min(weightEntries.map { $0.weight }.min() ?? 0, Double(idealWeight)) - 5...max(weightEntries.map { $0.weight }.max() ?? 0, Double(idealWeight)) + 5)
                            .chartXAxis {
                                AxisMarks(values: .stride(by: .day, count: 7)) { value in
                                    AxisGridLine()
                                    AxisValueLabel(format: .dateTime.month().day())
                                }
                            }
                            
                            if let latestEntry = weightEntries.last {
                                Text("Latest: \(String(format: "%.1f kg", latestEntry.weight))")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(.systemGray6))
                        )
                        .padding(.horizontal)
                    }
                    
                    // Edit Profile Button
                    Button(action: {
                        if userProfile.isEmpty {
                            // Create a new profile if none exists
                            let newProfile = UserProfile(
                                name: name,
                                age: age,
                                gender: gender,
                                height: height,
                                weight: weight,
                                activityLevel: ActivityLevel.moderatelyActive.rawValue,
                                goal: Goal.maintainWeight.rawValue,
                                goalWeight: Double(idealWeight)
                            )
                            modelContext.insert(newProfile)
                            try? modelContext.save()
                            showingEditProfile = true
                        } else {
                            showingEditProfile = true
                        }
                    }) {
                        Text("Edit Profile")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(15)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddWeight = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddWeight) {
                AddWeightView()
                    .environment(\.modelContext, modelContext)
            }
            .sheet(isPresented: $showingEditProfile) {
                if let profile = userProfile.first {
                    EditProfileView(profile: profile)
                }
            }
        }
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    ProfileView()
} 
