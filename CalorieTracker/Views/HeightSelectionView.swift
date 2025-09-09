import SwiftUI

struct HeightSelectionView: View {
    @State private var selectedHeight = 170
    @State private var showingWeightSelection = false
    
    private let heights = Array(100...200)
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Your Height")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 40)
            
            Text("Select your height in centimeters")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Height Picker
            ZStack {
                // Background highlight
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.blue.opacity(0.1))
                    .frame(height: 60)
                
                // Height Picker
                Picker("Height", selection: $selectedHeight) {
                    ForEach(heights, id: \.self) { height in
                        Text("\(height) cm")
                            .font(.title2)
                            .fontWeight(.medium)
                            .tag(height)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 150)
            }
            .padding(.horizontal)
            
            // Selected Height Display
            Text("\(selectedHeight) cm")
                .font(.title3)
                .foregroundColor(.blue)
                .padding(.top, 20)
            
            // Height in feet and inches
            Text("(\(formatHeightInFeetAndInches(selectedHeight)))")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            // Continue Button
            Button(action: {
                // Save height to UserDefaults
                UserDefaults.standard.set(selectedHeight, forKey: "userHeight")
                withAnimation {
                    showingWeightSelection = true
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
        .fullScreenCover(isPresented: $showingWeightSelection) {
            WeightSelectionView()
        }
    }
    
    private func formatHeightInFeetAndInches(_ centimeters: Int) -> String {
        let totalInches = Double(centimeters) / 2.54
        let feet = Int(totalInches / 12)
        let inches = Int(totalInches.truncatingRemainder(dividingBy: 12))
        return "\(feet)' \(inches)\""
    }
}

#Preview {
    HeightSelectionView()
} 