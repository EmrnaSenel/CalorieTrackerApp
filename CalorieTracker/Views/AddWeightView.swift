//
//  AddWeightView.swift
//  CalorieTracker
//
//  Created by Emrina Şenel.
//

import SwiftUI
import SwiftData

struct AddWeightView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var userProfile: [UserProfile]
    
    @State private var weight = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    
    private var profile: UserProfile? {
        userProfile.first
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Current Weight")) {
                    TextField("Enter weight in kg", text: $weight)
                        .keyboardType(.decimalPad)
                }
                
                if !weight.isEmpty {
                    Section {
                        HStack {
                            Text("Weight:")
                            Spacer()
                            Text("\(weight) kg")
                                .foregroundColor(.blue)
                                .fontWeight(.medium)
                        }
                    }
                }
            }
            .navigationTitle("Add Weight")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveWeight()
                    }
                    .disabled(weight.isEmpty)
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func saveWeight() {
        // Clean the input string and handle different decimal separators
        let cleanedWeight = weight.replacingOccurrences(of: ",", with: ".")
        print("DEBUG: Original weight input: '\(weight)', cleaned: '\(cleanedWeight)'")
        
        guard let weightValue = Double(cleanedWeight), weightValue > 0 else {
            errorMessage = "Please enter a valid weight (greater than 0)"
            showingError = true
            print("DEBUG: Failed to parse weight value")
            return
        }
        
        // Validate reasonable weight range (20-500 kg)
        guard weightValue >= 20 && weightValue <= 500 else {
            errorMessage = "Please enter a weight between 20 and 500 kg"
            showingError = true
            print("DEBUG: Weight value out of range: \(weightValue)")
            return
        }
        
        print("DEBUG: Creating weight entry with value: \(weightValue)")
        
        // Create and save the weight entry
        let entry = WeightEntry(weight: weightValue)
        print("DEBUG: Created WeightEntry - ID: \(entry.id), Weight: \(entry.weight), Date: \(entry.date)")
        
        modelContext.insert(entry)
        print("DEBUG: Inserted weight entry into model context")
        
        // Update the current weight in UserDefaults
        UserDefaults.standard.set(weightValue, forKey: "userWeight")
        print("DEBUG: Updated UserDefaults with weight: \(weightValue)")
        
        // Update the profile if it exists
        if let profile = profile {
            let oldWeight = profile.weight
            profile.weight = weightValue
            print("DEBUG: Updated profile weight from \(oldWeight) to \(weightValue)")
        } else {
            print("DEBUG: No profile found to update")
        }
        
        do {
            try modelContext.save()
            print("DEBUG: Weight entry saved successfully - Weight: \(weightValue), Date: \(entry.date)")
            print("DEBUG: ModelContext save completed successfully")
            dismiss()
        } catch {
            errorMessage = "Failed to save weight: \(error.localizedDescription)"
            showingError = true
            print("DEBUG: Error saving weight entry: \(error)")
            print("DEBUG: Error details: \(error)")
        }
    }
}

#Preview {
    AddWeightView()
        .modelContainer(for: [UserProfile.self, WeightEntry.self])
} 
