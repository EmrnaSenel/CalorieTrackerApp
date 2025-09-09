import SwiftUI

struct ActivityLevelView: View {
    @State private var selectedLevel: ActivityLevel = .notActive
    @State private var showingProfile = false
    
    enum ActivityLevel: String, CaseIterable {
        case notActive = "Not that active"
        case occasionallyActive = "Active once in a while"
        case regularlyActive = "Active most days"
        case athlete = "An Athlete"
        
        var batteryLevel: Int {
            switch self {
            case .notActive: return 1
            case .occasionallyActive: return 2
            case .regularlyActive: return 3
            case .athlete: return 4
            }
        }
        
        var color: Color {
            switch self {
            case .notActive: return .red
            case .occasionallyActive: return .orange
            case .regularlyActive: return .green
            case .athlete: return .blue
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 30) {
            Text("What's your activity level?")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 40)
            
            Text("Select the option that best describes your daily activity")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
            
            // Activity Level Options
            VStack(spacing: 20) {
                ForEach(ActivityLevel.allCases, id: \.self) { level in
                    Button(action: {
                        withAnimation {
                            selectedLevel = level
                        }
                    }) {
                        HStack {
                            // Battery Icon
                            ZStack(alignment: .leading) {
                                // Battery Outline
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(level.color, lineWidth: 2)
                                    .frame(width: 40, height: 20)
                                
                                // Battery Fill
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(level.color)
                                    .frame(width: CGFloat(level.batteryLevel) * 8, height: 16)
                                    .padding(.leading, 2)
                            }
                            
                            Text(level.rawValue)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if selectedLevel == level {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(level.color)
                                    .font(.title2)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(selectedLevel == level ? level.color.opacity(0.1) : Color(.systemGray6))
                        )
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Continue Button
            Button(action: {
                // Save activity level to UserDefaults
                UserDefaults.standard.set(selectedLevel.rawValue, forKey: "activityLevel")
                withAnimation {
                    showingProfile = true
                }
            }) {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedLevel.color)
                    .cornerRadius(15)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 30)
        }
        .fullScreenCover(isPresented: $showingProfile) {
            ProfileView()
        }
    }
}

#Preview {
    ActivityLevelView()
} 