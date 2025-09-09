import SwiftUI

struct GoalSelectionView: View {
    @State private var selectedGoal: WeightGoal?
    @State private var showingUserOnboarding = false
    
    enum WeightGoal: String {
        case lose = "Lose Weight"
        case gain = "Gain Weight"
        case maintain = "Maintain Weight"
        
        var icon: String {
            switch self {
            case .lose: return "scalemass"
            case .gain: return "dumbbell"
            case .maintain: return "apple.logo"
            }
        }
        
        var color: Color {
            switch self {
            case .lose: return .blue
            case .gain: return .green
            case .maintain: return .orange
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 30) {
            Text("What's your goal?")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 40)
            
            Text("Choose your primary goal")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            VStack(spacing: 20) {
                ForEach([WeightGoal.lose, .gain, .maintain], id: \.self) { goal in
                    Button(action: {
                        withAnimation {
                            selectedGoal = goal
                        }
                    }) {
                        HStack {
                            Image(systemName: goal.icon)
                                .font(.title2)
                                .foregroundColor(goal.color)
                                .frame(width: 40)
                            
                            Text(goal.rawValue)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if selectedGoal == goal {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(goal.color)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(.systemGray6))
                        )
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            Button(action: {
                if let goal = selectedGoal {
                    // Save goal to UserDefaults
                    UserDefaults.standard.set(goal.rawValue, forKey: "userGoal")
                    withAnimation {
                        showingUserOnboarding = true
                    }
                }
            }) {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedGoal != nil ? Color.blue : Color.gray)
                    .cornerRadius(15)
            }
            .disabled(selectedGoal == nil)
            .padding(.horizontal, 40)
            .padding(.bottom, 30)
        }
        .fullScreenCover(isPresented: $showingUserOnboarding) {
            UserOnboardingView()
        }
    }
}

#Preview {
    GoalSelectionView()
} 