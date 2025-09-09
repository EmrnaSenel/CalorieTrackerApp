//
//  AddActivityView.swift
//  CalorieTracker
//
//  Created by Emrina Şenel.
//

import SwiftUI
import SwiftData

struct AddActivityView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: FoodAnalysisViewModel
    @State private var selectedActivity = ActivityType.walking
    @State private var duration = 30
    @State private var showingError = false
    @State private var errorMessage = ""
    
    enum ActivityType: String, CaseIterable {
        case walking = "Walking"
        case running = "Running"
        case cycling = "Cycling"
        case swimming = "Swimming"
        case hiking = "Hiking"
        case weightlifting = "Weight Lifting"
        case yoga = "Yoga"
        case dance = "Dance"
        case football = "Football"
        case basketball = "Basketball"
        case pilates = "Pilates"
        
        var caloriesPerMinute: Double {
            switch self {
            case .walking: return 4.0
            case .running: return 10.0
            case .cycling: return 8.0
            case .swimming: return 7.0
            case .hiking: return 6.0
            case .weightlifting: return 5.0
            case .yoga: return 3.0
            case .dance: return 5.5
            case .football: return 8.5
            case .basketball: return 8.0
            case .pilates: return 3.5
            }
        }
        
        var icon: String {
            switch self {
            case .walking: return "figure.walk"
            case .running: return "figure.run"
            case .cycling: return "figure.outdoor.cycle"
            case .swimming: return "figure.pool.swim"
            case .hiking: return "figure.hiking"
            case .weightlifting: return "figure.strengthtraining.traditional"
            case .yoga: return "figure.mind.and.body"
            case .dance: return "figure.dance"
            case .football: return "figure.american.football"
            case .basketball: return "figure.basketball"
            case .pilates: return "figure.core.training"
            }
        }
    }
    
    init() {
        let context = try! ModelContainer(for: Meal.self).mainContext
        _viewModel = StateObject(wrappedValue: FoodAnalysisViewModel(modelContext: context))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Activity Details")) {
                    Picker("Activity Type", selection: $selectedActivity) {
                        ForEach(ActivityType.allCases, id: \.self) { activity in
                            Label(activity.rawValue, systemImage: activity.icon)
                                .tag(activity)
                        }
                    }
                    
                    Stepper("Duration: \(duration) minutes", value: $duration, in: 1...300)
                }
                
                Section(header: Text("Calories Burned")) {
                    HStack {
                        Text("Estimated Calories")
                        Spacer()
                        Text("\(calculateCaloriesBurned()) kcal")
                            .foregroundColor(.green)
                    }
                }
            }
            .navigationTitle("Add Activity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveActivity()
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
    
    private func calculateCaloriesBurned() -> Int {
        Int(selectedActivity.caloriesPerMinute * Double(duration))
    }
    
    private func saveActivity() {
        let meal = Meal(
            name: selectedActivity.rawValue,
            calories: calculateCaloriesBurned(),
            protein: 0,
            carbohydrates: 0,
            fat: 0,
            isActivity: true,
            duration: duration
        )
        
        do {
            modelContext.insert(meal)
            try modelContext.save()
            print("Activity saved successfully")
            dismiss()
        } catch {
            print("Error saving activity: \(error)")
            errorMessage = "Failed to save activity: \(error.localizedDescription)"
            showingError = true
        }
    }
}

#Preview {
    AddActivityView()
        .modelContainer(for: Meal.self)
} 
