import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var currentPage = 0
    
    private let pages = [
        OnboardingPage(
            title: "Welcome to CalorieTracker",
            description: "Track your meals and activities to achieve your health goals",
            imageName: "fork.knife"
        ),
        OnboardingPage(
            title: "Food Recognition",
            description: "Take photos of your meals to get nutritional information",
            imageName: "camera"
        ),
        OnboardingPage(
            title: "Activity Tracking",
            description: "Log your exercises and track calories burned",
            imageName: "figure.run"
        ),
        OnboardingPage(
            title: "Daily Summary",
            description: "View your daily calorie intake and burn",
            imageName: "chart.bar"
        )
    ]
    
    var body: some View {
        if hasSeenOnboarding {
            SignUpView()
        } else {
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    VStack(spacing: 20) {
                        Image(systemName: pages[index].imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .foregroundColor(.blue)
                        
                        Text(pages[index].title)
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text(pages[index].description)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        if index == pages.count - 1 {
                            Button(action: {
                                withAnimation {
                                    hasSeenOnboarding = true
                                }
                            }) {
                                Text("Get Started")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(15)
                            }
                            .padding(.horizontal, 40)
                            .padding(.top, 20)
                        }
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        }
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let imageName: String
}

#Preview {
    OnboardingView()
} 