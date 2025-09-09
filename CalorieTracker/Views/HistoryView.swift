//
//  HistoryView.swift
//  CalorieTracker
//
//  Created by Emrina Şenel.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Meal.timestamp, order: .reverse) private var meals: [Meal]
    
    @State private var selectedDate = Date()
    @State private var showingDatePicker = false
    
    private var calendar: Calendar {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        return calendar
    }
    
    private var mealsForSelectedDate: [Meal] {
        meals.filter { calendar.isDate($0.timestamp, inSameDayAs: selectedDate) }
    }
    
    private var activitiesForSelectedDate: [Meal] {
        meals.filter { calendar.isDate($0.timestamp, inSameDayAs: selectedDate) && $0.isActivity }
    }
    
    private var foodForSelectedDate: [Meal] {
        meals.filter { calendar.isDate($0.timestamp, inSameDayAs: selectedDate) && !$0.isActivity }
    }
    
    private var totalCaloriesConsumed: Int {
        foodForSelectedDate.reduce(0) { $0 + $1.calories }
    }
    
    private var totalCaloriesBurned: Int {
        activitiesForSelectedDate.reduce(0) { $0 + $1.calories }
    }
    
    private var netCalories: Int {
        totalCaloriesConsumed - totalCaloriesBurned
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Date Selector
                    Button(action: { showingDatePicker = true }) {
                        HStack {
                            Text(selectedDate.formatted(date: .long, time: .omitted))
                                .foregroundColor(.primary)
                            Image(systemName: "calendar")
                                .foregroundColor(.blue)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                    .sheet(isPresented: $showingDatePicker) {
                        DatePicker(
                            "Select Date",
                            selection: $selectedDate,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .presentationDetents([.medium])
                    }
                    
                    // Summary Card
                    VStack(spacing: 15) {
                        Text("Daily Summary")
                            .font(.headline)
                        
                        HStack(spacing: 20) {
                            VStack {
                                Text("\(totalCaloriesConsumed)")
                                    .font(.title2)
                                    .bold()
                                Text("Consumed")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack {
                                Text("\(totalCaloriesBurned)")
                                    .font(.title2)
                                    .bold()
                                Text("Burned")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack {
                                Text("\(netCalories)")
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(netCalories >= 0 ? .blue : .red)
                                Text("Net")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    
                    // Meals Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Meals")
                            .font(.headline)
                        
                        if foodForSelectedDate.isEmpty {
                            Text("No meals recorded")
                                .foregroundColor(.secondary)
                                .padding()
                        } else {
                            ForEach(foodForSelectedDate) { meal in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(meal.name)
                                            .bold()
                                        Text(meal.timestamp.formatted(date: .omitted, time: .shortened))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("\(meal.calories) kcal")
                                        .bold()
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                    }
                    
                    // Activities Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Activities")
                            .font(.headline)
                        
                        if activitiesForSelectedDate.isEmpty {
                            Text("No activities recorded")
                                .foregroundColor(.secondary)
                                .padding()
                        } else {
                            ForEach(activitiesForSelectedDate) { activity in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(activity.name)
                                            .bold()
                                        Text(activity.timestamp.formatted(date: .omitted, time: .shortened))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("-\(activity.calories) kcal")
                                        .bold()
                                        .foregroundColor(.red)
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("History")
        }
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: [Meal.self])
} 
