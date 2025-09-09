//
//  FoodPhotoAnalysisView.swift
//  CalorieTracker
//
//  Created by Emrina Şenel.
//

import SwiftUI
import PhotosUI
import Vision
import SwiftData
import AVFoundation
import UIKit

enum ImageSourceType {
    case camera
    case photoLibrary
}

struct FoodPhotoAnalysisView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: FoodAnalysisViewModel
    
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var imageSourceType: ImageSourceType = .photoLibrary
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var isCameraAvailable = false
    
    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: FoodAnalysisViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(radius: 4)
                            .padding(.horizontal)
                    }
                    
                    if viewModel.isAnalyzing {
                        VStack(spacing: 12) {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("Analyzing image...")
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    } else if let analysis = viewModel.foodAnalysis {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Analysis Results")
                                .font(.headline)
                                .padding(.bottom, 4)
                            
                            Group {
                                NutrientRow(title: "Name", value: analysis.name)
                                NutrientRow(title: "Calories", value: "\(Int(analysis.calories)) kcal")
                                NutrientRow(title: "Protein", value: String(format: "%.1fg", analysis.protein))
                                NutrientRow(title: "Carbs", value: String(format: "%.1fg", analysis.carbs))
                                NutrientRow(title: "Fat", value: String(format: "%.1fg", analysis.fat))
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(radius: 2)
                        .padding(.horizontal)
                    }
                    
                    VStack(spacing: 16) {
                        Button(action: {
                            imageSourceType = .photoLibrary
                            showingImagePicker = true
                        }) {
                            Label("Choose from Library", systemImage: "photo.on.rectangle")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        if isCameraAvailable {
                            Button(action: {
                                imageSourceType = .camera
                                showingImagePicker = true
                            }) {
                                Label("Take Photo", systemImage: "camera")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Food Analysis")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
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
                            try await viewModel.analyzeFoodImage(image)
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
            .onAppear {
                checkCameraAvailability()
            }
        }
    }
    
    private func checkCameraAvailability() {
        isCameraAvailable = UIImagePickerController.isSourceTypeAvailable(.camera)
    }
}

struct NutrientRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .bold()
        }
    }
}

#Preview {
    FoodPhotoAnalysisView(modelContext: try! ModelContainer(for: UserProfile.self, Meal.self, WeightEntry.self).mainContext)
} 

