//
//  CalorieTrackerApp.swift
//  CalorieTracker
//
//  Created by Emrina Şenel.
//

import SwiftUI
import SwiftData

@main
struct CalorieTrackerApp: App {
    let modelContainer: ModelContainer
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    init() {
        self.modelContainer = ModelConfig.modelContainer
    }
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                ContentView()
                    .modelContainer(modelContainer)
            } else {
                OnboardingView()
                    .modelContainer(modelContainer)
            }
        }
    }
}
