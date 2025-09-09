//
//  UserOnboardingView.swift
//  CalorieTracker
//
//  Created by Emrina Şenel.
//

import SwiftUI
import SwiftData

struct UserOnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var name = ""
    @State private var age = ""
    @State private var height = ""
    @State private var weight = ""
    @State private var goalWeight = ""
    @State private var selectedActivityLevel = ActivityLevel.moderatelyActive
    @State private var selectedGender = Gender.male
    @State private var selectedGoal = Goal.loseWeight
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var calculatedCalories: Int?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Name", text: $name)
                        .textContentType(.name)
                        .onChange(of: name) { _, _ in calculateCalories() }
                    
                    TextField("Age", text: $age)
                        .keyboardType(.numberPad)
                        .textContentType(.none)
                        .onChange(of: age) { _, _ in calculateCalories() }
                    
                    TextField("Height (cm)", text: $height)
                        .keyboardType(.decimalPad)
                        .textContentType(.none)
                        .onChange(of: height) { _, _ in calculateCalories() }
                    
                    TextField("Current Weight (kg)", text: $weight)
                        .keyboardType(.decimalPad)
                        .textContentType(.none)
                        .onChange(of: weight) { _, _ in calculateCalories() }
                    
                    TextField("Goal Weight (kg)", text: $goalWeight)
                        .keyboardType(.decimalPad)
                        .textContentType(.none)
                        .onChange(of: goalWeight) { _, _ in calculateCalories() }
                }
                
                Section(header: Text("Activity Level")) {
                    Picker("Activity Level", selection: $selectedActivityLevel) {
                        ForEach(ActivityLevel.allCases, id: \.self) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    .onChange(of: selectedActivityLevel) { _, _ in calculateCalories() }
                }
                
                Section(header: Text("Gender")) {
                    Picker("Gender", selection: $selectedGender) {
                        ForEach(Gender.allCases, id: \.self) { gender in
                            Text(gender.rawValue).tag(gender)
                        }
                    }
                    .onChange(of: selectedGender) { _, _ in calculateCalories() }
                }
                
                Section(header: Text("Goal")) {
                    Picker("Goal", selection: $selectedGoal) {
                        ForEach(Goal.allCases, id: \.self) { goal in
                            Text(goal.rawValue).tag(goal)
                        }
                    }
                    .onChange(of: selectedGoal) { _, _ in calculateCalories() }
                }
                
                if let calories = calculatedCalories {
                    Section(header: Text("Daily Calorie Needs")) {
                        Text("\(calories) calories")
                            .font(.headline)
                        Text("Based on Mifflin-St Jeor Equation")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Create Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveUserProfile()
                    }
                    .disabled(!isFormValid)
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private var isFormValid: Bool {
        guard !name.isEmpty,
              let ageInt = Int(age), ageInt > 0,
              let heightDouble = Double(height), heightDouble > 0,
              let weightDouble = Double(weight), weightDouble > 0,
              let goalWeightDouble = Double(goalWeight), goalWeightDouble > 0 else {
            return false
        }
        return true
    }
    
    private func calculateCalories() {
        guard let ageInt = Int(age),
              let heightDouble = Double(height),
              let weightDouble = Double(weight) else {
            calculatedCalories = nil
            return
        }
        
        // Mifflin-St Jeor Equation
        var bmr: Double
        if selectedGender == .male {
            bmr = (10 * weightDouble) + (6.25 * heightDouble) - (5 * Double(ageInt)) + 5
        } else {
            bmr = (10 * weightDouble) + (6.25 * heightDouble) - (5 * Double(ageInt)) - 161
        }
        
        // Apply activity multiplier
        let activityMultiplier: Double
        switch selectedActivityLevel {
        case .sedentary:
            activityMultiplier = 1.2
        case .lightlyActive:
            activityMultiplier = 1.375
        case .moderatelyActive:
            activityMultiplier = 1.55
        case .veryActive:
            activityMultiplier = 1.725
        case .extraActive:
            activityMultiplier = 1.9
        }
        
        calculatedCalories = Int(bmr * activityMultiplier)
    }
    
    private func saveUserProfile() {
        guard let ageInt = Int(age),
              let heightDouble = Double(height),
              let weightDouble = Double(weight),
              let goalWeightDouble = Double(goalWeight) else {
            errorMessage = "Please enter valid values for all fields"
            showingError = true
            return
        }
        
        // Save to UserDefaults
        UserDefaults.standard.set(name, forKey: "preferredName")
        UserDefaults.standard.set(selectedGender.rawValue, forKey: "userGender")
        UserDefaults.standard.set(ageInt, forKey: "userAge")
        UserDefaults.standard.set(heightDouble, forKey: "userHeight")
        UserDefaults.standard.set(weightDouble, forKey: "userWeight")
        UserDefaults.standard.set(Int(goalWeightDouble), forKey: "idealWeight")
        UserDefaults.standard.set(selectedActivityLevel.rawValue, forKey: "activityLevel")
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        
        let profile = UserProfile(
            name: name,
            age: ageInt,
            gender: selectedGender.rawValue,
            height: heightDouble,
            weight: weightDouble,
            activityLevel: selectedActivityLevel.rawValue,
            goal: selectedGoal.rawValue,
            goalWeight: goalWeightDouble
        )
        
        do {
            modelContext.insert(profile)
            try modelContext.save()
            print("Profile saved successfully")
            
            // Create initial weight entry
            let weightEntry = WeightEntry(weight: weightDouble)
            modelContext.insert(weightEntry)
            try modelContext.save()
            print("Initial weight entry saved")
            
            dismiss()
        } catch {
            print("Error saving profile: \(error)")
            errorMessage = "Failed to save profile: \(error.localizedDescription)"
            showingError = true
        }
    }
}

#Preview {
    UserOnboardingView()
        .modelContainer(for: [UserProfile.self, WeightEntry.self])
} 
