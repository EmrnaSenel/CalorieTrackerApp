//
//  HealthManager.swift
//  CalorieTracker
//
//  Created by Emrina Şenel.
//

import Foundation
import HealthKit

class HealthManager {
    
    static var shared = HealthManager()
    
    let healthStore = HKHealthStore()
    
    private init () {
        let calories = HKQuantityType(.activeEnergyBurned)
        let exercise = HKQuantityType(.appleExerciseTime)
        let stand = HKQuantityType(.appleStandTime)
        
        let healthTypes: Set = [calories, exercise, stand]
        Task {
            do {
                try await healthStore.requestAuthorization(toShare: [], read: healthTypes)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
