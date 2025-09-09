import SwiftData
import Foundation

enum ModelConfig {
    static var modelContainer: ModelContainer {
        let schema = Schema([UserProfile.self, Meal.self, WeightEntry.self, Food.self])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true,
            cloudKitDatabase: .none
        )
        
        do {
            return try ModelContainer(
                for: schema,
                migrationPlan: nil,
                configurations: [modelConfiguration]
            )
        } catch {
            // If there's an error, try with in-memory storage
            let fallbackConfig = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: true
            )
            
            do {
                return try ModelContainer(
                    for: schema,
                    configurations: [fallbackConfig]
                )
            } catch {
                fatalError("Could not initialize ModelContainer: \(error)")
            }
        }
    }
} 