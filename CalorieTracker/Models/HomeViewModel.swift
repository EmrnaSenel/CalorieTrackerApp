//
//  HomeViewModel.swift
//  CalorieTracker
//
//  Created by Emrina Şenel on 20.04.2025.
//

import SwiftUI

class HomeViewModel: ObservableObject {
    
    @State var calories: Int = 123
    @State var active: Int = 52
    @State var stand: Int = 8
    
    var mockActivities = [
        Activity(id: 0, title: "Today Steps", subtitle: "Goal 12,000", image: "figure.walk", tintColor: .green, amount: "7000"),
        Activity(id: 1, title: "Today Steps", subtitle: "Goal 1,000", image: "figure.walk", tintColor: .red, amount: "812"),
        Activity(id: 2, title: "Today Steps", subtitle: "Goal 12,000", image: "figure.walk", tintColor: .blue, amount: "9,871"),
        Activity(id: 3, title: "Today Steps", subtitle: "Goal 50,000", image: "figure.run", tintColor: .purple, amount: "104,812")
    ]
    
    var mockWorkouts = [
        Workout(id: 0, title: "Running", image: "figure.run", tintColor: .cyan, duration: "51 mins", date: "Aug 1", calories: "512 kcal"),
        Workout(id: 1, title: "Strength Training", image: "figure.run", tintColor: .red, duration: "45 mins", date: "Aug 2", calories: "512 kcal"),
        Workout(id: 2, title: "Running", image: "figure.run", tintColor: .cyan, duration: "90 mins", date: "Aug 11", calories: "512 kcal"),
        Workout(id: 3, title: "Running", image: "figure.run", tintColor: .cyan, duration: "21 mins", date: "Aug 19", calories: "512 kcal")
        
    ]
    
}
