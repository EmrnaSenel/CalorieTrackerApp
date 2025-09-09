//
//  APITestView.swift
//  CalorieTracker
//
//  Created by Emrina Şenel.
//

import SwiftUI
import SwiftData

struct APITestView: View {
    @StateObject private var viewModel: FoodAnalysisViewModel
    @State private var testResults: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: FoodAnalysisViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if isLoading {
                    ProgressView("Testing API...")
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            if let error = errorMessage {
                                Text("Error: \(error)")
                                    .foregroundColor(.red)
                                    .padding()
                            }
                            
                            if !testResults.isEmpty {
                                Text("Test Results:")
                                    .font(.headline)
                                
                                Text(testResults)
                                    .padding()
                                    .background(Color(.systemBackground))
                                    .cornerRadius(10)
                                    .shadow(radius: 2)
                            }
                        }
                        .padding()
                    }
                }
                
                Button(action: {
                    Task {
                        await runTest()
                    }
                }) {
                    Text("Test USDA API")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                .disabled(isLoading)
            }
            .navigationTitle("API Test")
        }
    }
    
    private func runTest() async {
        isLoading = true
        errorMessage = nil
        testResults = ""
        
        do {
            let foods = try await viewModel.testUSDAAPI()
            if let food = foods.first {
                testResults = """
                API Test Successful!
                
                Found: \(food.description)
                Calories: \(food.foodNutrients.first(where: { $0.nutrientName == "Energy" })?.value ?? 0)
                Protein: \(food.foodNutrients.first(where: { $0.nutrientName == "Protein" })?.value ?? 0)g
                Carbs: \(food.foodNutrients.first(where: { $0.nutrientName == "Carbohydrate, by difference" })?.value ?? 0)g
                Fat: \(food.foodNutrients.first(where: { $0.nutrientName == "Total lipid (fat)" })?.value ?? 0)g
                """
            } else {
                testResults = "API Test: No results found for 'ice cream'"
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

#Preview {
    APITestView(modelContext: try! ModelContainer(for: UserProfile.self, Meal.self, WeightEntry.self).mainContext)
} 
