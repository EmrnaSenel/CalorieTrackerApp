//
//  ContentView.swift
//  CalorieTracker
//
//  Created by Emrina Şenel.
//

import SwiftUI
import SwiftData
import Charts

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var meals: [Meal]
    @Query private var userProfiles: [UserProfile]
    @Query private var weightEntries: [WeightEntry]
    
    @State private var showingAddFood = false
    @State private var showingAddActivity = false
    @State private var showingAddWeight = false
    @State private var showingProfile = false
    @State private var showingAPITest = false
    @State private var selectedTab = 0
    @State private var mealToDelete: Meal?
    @State private var showingDeleteAlert = false
    @State private var showingFoodAnalysis = false
    
    private var todayMeals: [Meal] {
        meals.filter { Calendar.current.isDateInToday($0.timestamp) && !$0.isActivity }
    }
    
    private var todayActivities: [Meal] {
        meals.filter { Calendar.current.isDateInToday($0.timestamp) && $0.isActivity }
    }
    
    private var totalCaloriesConsumed: Int {
        todayMeals.reduce(0) { $0 + $1.calories }
    }
    
    private var totalCaloriesBurned: Int {
        todayActivities.reduce(0) { $0 + $1.calories }
    }
    
    private var netCalories: Int {
        totalCaloriesConsumed - totalCaloriesBurned
    }
    
    private var targetCalories: Int {
        userProfiles.first?.dailyCalorieGoal ?? 2000
    }
    
    private var targetBurnCalories: Int {
        userProfiles.first?.dailyCalorieBurnGoal ?? 300
    }
    
    private var calorieProgress: Double {
        min(Double(totalCaloriesConsumed) / Double(targetCalories), 1.0)
    }
    
    private var burnProgress: Double {
        min(Double(totalCaloriesBurned) / Double(targetBurnCalories), 1.0)
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            mainView
                .tabItem {
                    Label("Today", systemImage: "calendar")
                }
                .tag(0)
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock")
                }
                .tag(1)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
                .tag(2)
        }
        .sheet(isPresented: $showingAddFood) {
            AddFoodView(modelContext: modelContext)
        }
        .sheet(isPresented: $showingAddActivity) {
            AddActivityView()
        }
        .sheet(isPresented: $showingAddWeight) {
            AddWeightView()
        }
        .sheet(isPresented: $showingFoodAnalysis) {
            FoodPhotoAnalysisView(modelContext: modelContext)
        }
        .sheet(isPresented: $showingAPITest) {
            APITestView(modelContext: modelContext)
        }
        .alert("Delete Entry", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {
                mealToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let meal = mealToDelete {
                    deleteMeal(meal)
                }
                mealToDelete = nil
            }
        } message: {
            if let meal = mealToDelete {
                Text("Are you sure you want to delete this \(meal.isActivity ? "activity" : "meal")?")
            }
        }
    }
    
    private var mainView: some View {
        NavigationView {
            List {
                // Calorie Progress Circles
                Section {
                    HStack(spacing: 20) {
                        Spacer()
                        // Calories Consumed Circle
                        VStack {
                            ZStack {
                                Circle()
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                                    .frame(width: 150, height: 150)
                                
                                Circle()
                                    .trim(from: 0, to: calorieProgress)
                                    .stroke(
                                        LinearGradient(
                                            colors: [.blue, .blue.opacity(0.5)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                                    )
                                    .frame(width: 150, height: 150)
                                    .rotationEffect(.degrees(-90))
                                
                                VStack {
                                    Text("\(totalCaloriesConsumed)")
                                        .font(.system(size: 30, weight: .bold))
                                    Text("of \(targetCalories)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            Text("Calories")
                                .font(.headline)
                        }
                        
                        // Calories Burned Circle
                        VStack {
                            ZStack {
                                Circle()
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                                    .frame(width: 150, height: 150)
                                
                                Circle()
                                    .trim(from: 0, to: burnProgress)
                                    .stroke(
                                        LinearGradient(
                                            colors: [.green, .green.opacity(0.5)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                                    )
                                    .frame(width: 150, height: 150)
                                    .rotationEffect(.degrees(-90))
                                
                                VStack {
                                    Text("\(totalCaloriesBurned)")
                                        .font(.system(size: 30, weight: .bold))
                                    Text("of \(targetBurnCalories)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            Text("Activity")
                                .font(.headline)
                        }
                        Spacer()
                    }
                    .padding()
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
                
                // Add Food and Activity Buttons
                Section {
                    Button(action: { showingAddFood = true }) {
                        HStack {
                            Image(systemName: "fork.knife")
                            Text("Add Food")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                
                Section {
                    Button(action: { showingAddActivity = true }) {
                        HStack {
                            Image(systemName: "figure.run")
                            Text("Add Activity")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                
                // Today's Meals
                Section(header: Text("Today's Meals")) {
                    if todayMeals.isEmpty {
                        Text("No meals logged today")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    } else {
                        ForEach(todayMeals) { meal in
                            MealRow(meal: meal)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        mealToDelete = meal
                                        showingDeleteAlert = true
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
                
                // Today's Activities
                Section(header: Text("Today's Activities")) {
                    if todayActivities.isEmpty {
                        Text("No activities logged today")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(todayActivities) { meal in
                            HStack {
                                Image(systemName: getActivitySymbol(for: meal.name))
                                    .foregroundColor(.blue)
                                VStack(alignment: .leading) {
                                    Text(meal.name)
                                        .font(.headline)
                                    if let duration = meal.duration {
                                        Text("\(duration) minutes")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }
                                Spacer()
                                Text("-\(meal.calories) kcal")
                                    .foregroundColor(.red)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    mealToDelete = meal
                                    showingDeleteAlert = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Today")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showingAddWeight = true }) {
                            Label("Add Weight", systemImage: "scalemass")
                        }
                        Button(action: { showingAPITest = true }) {
                            Label("Test API", systemImage: "network")
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
        }
    }
    
    private func getActivitySymbol(for activity: String) -> String {
        let lowercasedActivity = activity.lowercased()
        
        if lowercasedActivity.contains("run") {
            return "figure.run"
        } else if lowercasedActivity.contains("walk") {
            return "figure.walk"
        } else if lowercasedActivity.contains("swim") {
            return "figure.pool.swim"
        } else if lowercasedActivity.contains("cycle") || lowercasedActivity.contains("bike") {
            return "figure.outdoor.cycle"
        } else if lowercasedActivity.contains("yoga") {
            return "figure.mind.and.body"
        } else if lowercasedActivity.contains("weight") || lowercasedActivity.contains("lift") {
            return "figure.strengthtraining.traditional"
        } else if lowercasedActivity.contains("dance") {
            return "figure.dance"
        } else if lowercasedActivity.contains("hike") {
            return "figure.hiking"
        } else if lowercasedActivity.contains("jump") {
            return "figure.jump"
        } else if lowercasedActivity.contains("climb") {
            return "figure.climbing"
        } else if lowercasedActivity.contains("box") {
            return "figure.boxing"
        } else if lowercasedActivity.contains("golf") {
            return "figure.golf"
        } else if lowercasedActivity.contains("ski") {
            return "figure.skiing.downhill"
        } else if lowercasedActivity.contains("snowboard") {
            return "figure.snowboarding"
        } else if lowercasedActivity.contains("surf") {
            return "figure.surfing"
        } else if lowercasedActivity.contains("tennis") {
            return "figure.tennis"
        } else if lowercasedActivity.contains("basketball") {
            return "figure.basketball"
        } else if lowercasedActivity.contains("soccer") || lowercasedActivity.contains("football") {
            return "figure.soccer"
        } else if lowercasedActivity.contains("baseball") {
            return "figure.baseball"
        } else if lowercasedActivity.contains("volleyball") {
            return "figure.volleyball"
        } else if lowercasedActivity.contains("gymnastics") {
            return "figure.gymnastics"
        } else if lowercasedActivity.contains("martial") || lowercasedActivity.contains("karate") {
            return "figure.martial.arts"
        } else if lowercasedActivity.contains("rowing") {
            return "figure.rowing"
        } else if lowercasedActivity.contains("skate") {
            return "figure.skating"
        } else {
            return "figure.mixed.cardio"
        }
    }
    
    private func deleteMeal(_ meal: Meal) {
        withAnimation {
            modelContext.delete(meal)
            try? modelContext.save()
        }
    }
}

struct MealRow: View {
    let meal: Meal
    
    var body: some View {
        HStack {
            if let imageData = meal.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image(systemName: meal.isActivity ? "figure.run" : "fork.knife")
                    .font(.title)
                    .frame(width: 60, height: 60)
                    .background(Color(.systemGray5))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            VStack(alignment: .leading) {
                Text(meal.name)
                    .font(.headline)
                if meal.isActivity {
                    Text("\(meal.duration ?? 0) minutes")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Text("\(meal.calories) cal")
                .font(.subheadline)
                .foregroundColor(meal.isActivity ? .green : .blue)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [UserProfile.self, Meal.self, WeightEntry.self])
} 

