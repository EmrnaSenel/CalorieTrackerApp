import SwiftUI

struct SignUpView: View {
    @State private var showingGoalSelection = false
    
    var body: some View {
        VStack(spacing: 30) {
            // Placeholder for Lottie animation
            Image(systemName: "hand.wave.fill")
                .font(.system(size: 100))
                .foregroundColor(.blue)
                .symbolEffect(.bounce, options: .repeating)
                .padding(.top, 40)
            
            Text("Welcome!")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Let's start your fitness journey together")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
            
            // Continue Button
            Button(action: {
                withAnimation {
                    showingGoalSelection = true
                }
            }) {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(15)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 30)
        }
        .fullScreenCover(isPresented: $showingGoalSelection) {
            GoalSelectionView()
        }
    }
}

#Preview {
    SignUpView()
} 