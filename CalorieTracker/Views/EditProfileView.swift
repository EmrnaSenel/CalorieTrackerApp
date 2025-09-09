//
//  EditProfileView.swift
//  CalorieTracker
//
//  Created by Emrina Şenel.
//

import SwiftUI
import SwiftData

struct EditProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var profile: UserProfile
    
    @State private var name: String
    @State private var age: String
    @State private var gender: String
    @State private var height: String
    @State private var weight: String
    @State private var selectedActivityLevel: ActivityLevel
    @State private var selectedGoal: Goal
    @State private var goalWeight: String
    
    @State private var showingError = false
    @State private var errorMessage = ""
    
    init(profile: UserProfile) {
        self.profile = profile
        _name = State(initialValue: profile.name)
        _age = State(initialValue: String(profile.age))
        _gender = State(initialValue: profile.gender)
        _height = State(initialValue: String(format: "%.1f", profile.height))
        _weight = State(initialValue: String(format: "%.1f", profile.weight))
        _selectedActivityLevel = State(initialValue: ActivityLevel(rawValue: profile.activityLevel) ?? .moderatelyActive)
        _selectedGoal = State(initialValue: Goal(rawValue: profile.goal) ?? .maintainWeight)
        _goalWeight = State(initialValue: String(format: "%.1f", profile.goalWeight))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Name", text: $name)
                    TextField("Age", text: $age)
                        .keyboardType(.numberPad)
                    Picker("Gender", selection: $gender) {
                        ForEach(Gender.allCases, id: \.self) { gender in
                            Text(gender.rawValue).tag(gender.rawValue)
                        }
                    }
                    TextField("Height (cm)", text: $height)
                        .keyboardType(.decimalPad)
                    TextField("Current Weight (kg)", text: $weight)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Goals")) {
                    Picker("Activity Level", selection: $selectedActivityLevel) {
                        ForEach(ActivityLevel.allCases, id: \.self) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    Picker("Goal", selection: $selectedGoal) {
                        ForEach(Goal.allCases, id: \.self) { goal in
                            Text(goal.rawValue).tag(goal)
                        }
                    }
                    .onChange(of: selectedGoal) { _, newGoal in
                        print("DEBUG: Goal changed in EditProfileView to: \(newGoal.rawValue)")
                        profile.goal = newGoal.rawValue
                        profile.updateDailyCalorieGoal()
                        try? modelContext.save()
                    }
                    TextField("Goal Weight (kg)", text: $goalWeight)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveProfile()
                    }
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func saveProfile() {
        // Validate inputs
        guard !name.isEmpty else {
            errorMessage = "Please enter your name"
            showingError = true
            return
        }
        
        guard let ageValue = Int(age), ageValue > 0 else {
            errorMessage = "Please enter a valid age"
            showingError = true
            return
        }
        
        guard let heightValue = Double(height), heightValue > 0 else {
            errorMessage = "Please enter a valid height"
            showingError = true
            return
        }
        
        guard let weightValue = Double(weight), weightValue > 0 else {
            errorMessage = "Please enter a valid weight"
            showingError = true
            return
        }
        
        guard let goalWeightValue = Double(goalWeight), goalWeightValue > 0 else {
            errorMessage = "Please enter a valid goal weight"
            showingError = true
            return
        }
        
        // Update UserDefaults
        UserDefaults.standard.set(name, forKey: "preferredName")
        UserDefaults.standard.set(gender, forKey: "userGender")
        UserDefaults.standard.set(ageValue, forKey: "userAge")
        UserDefaults.standard.set(heightValue, forKey: "userHeight")
        UserDefaults.standard.set(weightValue, forKey: "userWeight")
        UserDefaults.standard.set(Int(goalWeightValue), forKey: "idealWeight")
        UserDefaults.standard.set(selectedActivityLevel.rawValue, forKey: "activityLevel")
        
        // Update SwiftData profile
        profile.name = name
        profile.age = ageValue
        profile.gender = gender
        profile.height = heightValue
        profile.weight = weightValue
        profile.activityLevel = selectedActivityLevel.rawValue
        profile.goal = selectedGoal.rawValue
        profile.goalWeight = goalWeightValue
        
        // Recalculate daily calorie goal
        profile.dailyCalorieGoal = profile.calculateDailyCalorieGoal()
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            errorMessage = "Failed to save profile: \(error.localizedDescription)"
            showingError = true
        }
    }
}

#Preview {
    EditProfileView(profile: UserProfile(
        name: "John Doe",
        age: 30,
        gender: "Male",
        height: 175,
        weight: 70,
        activityLevel: "Moderately active",
        goal: "Lose weight",
        goalWeight: 65
    ))
    .modelContainer(for: [UserProfile.self])
} 
