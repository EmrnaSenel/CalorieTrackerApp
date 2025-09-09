import SwiftUI

struct WeightSelectionView: View {
    @State private var selectedWeight = 70
    @State private var showingIdealWeightSelection = false
    
    private let weights = Array(30...200)
    
    // Get the height from the previous view
    @AppStorage("userHeight") private var userHeight: Double = 170
    
    var bmi: Double {
        let heightInMeters = userHeight / 100
        return Double(selectedWeight) / (heightInMeters * heightInMeters)
    }
    
    var bmiCategory: String {
        switch bmi {
        case ..<18.5:
            return "Underweight"
        case 18.5..<25:
            return "Normal weight"
        case 25..<30:
            return "Overweight"
        default:
            return "Obese"
        }
    }
    
    var bmiColor: Color {
        switch bmi {
        case ..<18.5:
            return .blue
        case 18.5..<25:
            return .green
        case 25..<30:
            return .orange
        default:
            return .red
        }
    }
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Your Weight")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 40)
            
            Text("Select your weight in kilograms")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Weight Picker
            ZStack {
                // Background highlight
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.blue.opacity(0.1))
                    .frame(height: 60)
                
                // Weight Picker
                Picker("Weight", selection: $selectedWeight) {
                    ForEach(weights, id: \.self) { weight in
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
            
            // Selected Weight Display
            Text("\(selectedWeight) kg")
                .font(.title3)
                .foregroundColor(.blue)
                .padding(.top, 20)
            
            // Weight in pounds
            Text("(\(Int(Double(selectedWeight) * 2.20462)) lbs)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            // BMI Information
            VStack(spacing: 10) {
                Text("Your BMI")
                    .font(.headline)
                
                Text(String(format: "%.1f", bmi))
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(bmiColor)
                
                Text(bmiCategory)
                    .font(.title3)
                    .foregroundColor(bmiColor)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(.systemGray6))
            )
            .padding(.horizontal)
            
            // Continue Button
            Button(action: {
                // Save weight to UserDefaults
                UserDefaults.standard.set(selectedWeight, forKey: "userWeight")
                withAnimation {
                    showingIdealWeightSelection = true
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
        .fullScreenCover(isPresented: $showingIdealWeightSelection) {
            IdealWeightSelectionView()
        }
    }
}

#Preview {
    WeightSelectionView()
} 