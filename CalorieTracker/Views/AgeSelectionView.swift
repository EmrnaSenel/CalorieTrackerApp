import SwiftUI

struct AgeSelectionView: View {
    @State private var selectedAge = 25
    @State private var showingHeightSelection = false
    
    private let ages = Array(10...80)
    
    var body: some View {
        VStack(spacing: 30) {
            Text("How old are you?")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 40)
            
            Text("This helps us personalize your experience")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Age Picker
            ZStack {
                // Background highlight
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.blue.opacity(0.1))
                    .frame(height: 60)
                
                // Age Picker
                Picker("Age", selection: $selectedAge) {
                    ForEach(ages, id: \.self) { age in
                        Text("\(age)")
                            .font(.title2)
                            .fontWeight(.medium)
                            .tag(age)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 150)
            }
            .padding(.horizontal)
            
            // Selected Age Display
            Text("\(selectedAge) years old")
                .font(.title3)
                .foregroundColor(.blue)
                .padding(.top, 20)
            
            Spacer()
            
            // Continue Button
            Button(action: {
                withAnimation {
                    showingHeightSelection = true
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
        .fullScreenCover(isPresented: $showingHeightSelection) {
            HeightSelectionView()
        }
    }
}

#Preview {
    AgeSelectionView()
} 