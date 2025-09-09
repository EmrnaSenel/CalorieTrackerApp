//
//  AddFoodView.swift
//  CalorieTracker
//
//  Created by Emrina Şenel.
//

import SwiftUI
import SwiftData
import PhotosUI
import AVFoundation

struct AddFoodView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: FoodAnalysisViewModel
    
    @State private var foodName = ""
    @State private var calories: Double = 0
    @State private var protein: Double = 0
    @State private var carbs: Double = 0
    @State private var fat: Double = 0
    @State private var notes = ""
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var imageSourceType: ImageSourceType = .photoLibrary
    @State private var isAnalyzing = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: FoodAnalysisViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Food Details")) {
                    TextField("Food Name", text: $foodName)
                        .onChange(of: foodName) { _, newValue in
                            if !newValue.isEmpty {
                                Task {
                                    do {
                                        let analysis = try await viewModel.analyzeFood(newValue)
                                        calories = analysis.calories
                                        protein = analysis.protein
                                        carbs = analysis.carbs
                                        fat = analysis.fat
                                    } catch {
                                        errorMessage = error.localizedDescription
                                        showingError = true
                                    }
                                }
                            }
                        }
                    
                    if let analysis = viewModel.foodAnalysis {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Suggested Values:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Text("Calories:")
                                Text("\(Int(analysis.calories))")
                                    .bold()
                            }
                            
                            HStack {
                                Text("Protein:")
                                Text(String(format: "%.1fg", analysis.protein))
                                    .bold()
                            }
                            
                            HStack {
                                Text("Carbs:")
                                Text(String(format: "%.1fg", analysis.carbs))
                                    .bold()
                            }
                            
                            HStack {
                                Text("Fat:")
                                Text(String(format: "%.1fg", analysis.fat))
                                    .bold()
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                Section(header: Text("Nutritional Information")) {
                    HStack {
                        Text("Calories")
                        Spacer()
                        TextField("0", value: $calories, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Protein (g)")
                        Spacer()
                        TextField("0", value: $protein, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Carbs (g)")
                        Spacer()
                        TextField("0", value: $carbs, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Fat (g)")
                        Spacer()
                        TextField("0", value: $fat, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section(header: Text("Photo")) {
                    HStack {
                        Button(action: {
                            imageSourceType = .photoLibrary
                            showingImagePicker = true
                        }) {
                            Label("Choose Photo", systemImage: "photo")
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            imageSourceType = .camera
                            showingImagePicker = true
                        }) {
                            Label("Take Photo", systemImage: "camera")
                        }
                    }
                    
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                
                Section(header: Text("Notes")) {
                    TextField("Add notes...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Add Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveFood()
                    }
                    .disabled(foodName.isEmpty)
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(
                    image: $selectedImage, 
                    sourceType: imageSourceType == .camera ? .camera : .photoLibrary
                )
            }
            .onChange(of: selectedImage) { _, newImage in
                if let image = newImage {
                    Task {
                        do {
                            let analysis = try await viewModel.analyzeFoodImage(image)
                            foodName = analysis.name
                            calories = analysis.calories
                            protein = analysis.protein
                            carbs = analysis.carbs
                            fat = analysis.fat
                        } catch {
                            errorMessage = error.localizedDescription
                            showingError = true
                        }
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
    
    private func saveFood() {
        let meal = Meal(
            name: foodName,
            calories: Int(calories),
            protein: protein,
            carbohydrates: carbs,
            fat: fat,
            notes: notes,
            isActivity: false
        )
        
        if let image = selectedImage {
            meal.imageData = image.jpegData(compressionQuality: 0.8)
        }
        
        modelContext.insert(meal)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            errorMessage = "Failed to save food: \(error.localizedDescription)"
            showingError = true
        }
    }
}

#Preview {
    AddFoodView(modelContext: try! ModelContainer(for: UserProfile.self, Meal.self, WeightEntry.self).mainContext)
} 
