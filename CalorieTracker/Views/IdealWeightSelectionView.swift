import SwiftUI

struct IdealWeightSelectionView: View {
    @State private var selectedIdealWeight = 65
    @State private var showingPreferredName = false
    
    private let idealWeights = Array(30...150)
    
    // Get the current weight from the previous view
    @AppStorage("userWeight") private var userWeight: Double = 70
    
    var weightDifference: Int {
        selectedIdealWeight - Int(userWeight)
    }
    
    var weightDifferenceText: String {
        if weightDifference > 0 {
            return "Gain \(abs(weightDifference)) kg"
        } else if weightDifference < 0 {
            return "Lose \(abs(weightDifference)) kg"
        } else {
            return "Maintain current weight"
        }
    }
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Your Ideal Weight")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 40)
            
            Text("Select your target weight in kilograms")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Ideal Weight Picker
            ZStack {
                // Background highlight
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.blue.opacity(0.1))
                    .frame(height: 60)
                
                // Weight Picker
                Picker("Ideal Weight", selection: $selectedIdealWeight) {
                    ForEach(idealWeights, id: \.self) { weight in
                        Text("\(weight) kg")
                            .font(.title2)
                            .fontWeight(.medium)
                            .tag(weight)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 150)
            }
            .padding(.horizontal)
            
            // Selected Ideal Weight Display
            Text("\(selectedIdealWeight) kg")
                .font(.title3)
                .foregroundColor(.blue)
                .padding(.top, 20)
            
            // Weight in pounds
            Text("(\(Int(Double(selectedIdealWeight) * 2.20462)) lbs)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            // Weight Difference Information
            VStack(spacing: 10) {
                Text("Weight Goal")
                    .font(.headline)
                
                Text(weightDifferenceText)
                    .font(.title3)
                    .foregroundColor(weightDifferenceColor)
                    .padding(.vertical, 5)
                
                if weightDifference != 0 {
                    Text("Current: \(Int(userWeight)) kg")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(.systemGray6))
            )
            .padding(.horizontal)
            
            // Continue Button
            Button(action: {
                // Save ideal weight to UserDefaults
                UserDefaults.standard.set(selectedIdealWeight, forKey: "idealWeight")
                withAnimation {
                    showingPreferredName = true
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
        .fullScreenCover(isPresented: $showingPreferredName) {
            PreferredNameView()
        }
    }
    
    var weightDifferenceColor: Color {
        if weightDifference > 0 {
            return .green
        } else if weightDifference < 0 {
            return .orange
        } else {
            return .blue
        }
    }
}

#Preview {
    IdealWeightSelectionView()
} 