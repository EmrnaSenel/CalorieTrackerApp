import SwiftUI

struct GenderSelectionView: View {
    @State private var selectedGender = ""
    @State private var showingAgeSelection = false
    
    private let genders = ["Male", "Female"]
    
    var body: some View {
        VStack(spacing: 30) {
            Text("What's your gender?")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 40)
            
            Text("Select your gender")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            // Gender Options
            VStack(spacing: 20) {
                ForEach(genders, id: \.self) { gender in
                    Button(action: {
                        withAnimation {
                            selectedGender = gender
                        }
                    }) {
                        HStack {
                            Text(gender)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if selectedGender == gender {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(gender == "Male" ? .blue : .pink)
                                    .font(.title2)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(selectedGender == gender ? (gender == "Male" ? Color.blue.opacity(0.1) : Color.pink.opacity(0.1)) : Color(.systemGray6))
                        )
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Continue Button
            Button(action: {
                // Save gender to UserDefaults
                UserDefaults.standard.set(selectedGender, forKey: "userGender")
                withAnimation {
                    showingAgeSelection = true
                }
            }) {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedGender.isEmpty ? Color.gray : (selectedGender == "Male" ? Color.blue : Color.pink))
                    .cornerRadius(15)
            }
            .disabled(selectedGender.isEmpty)
            .padding(.horizontal, 40)
            .padding(.bottom, 30)
        }
        .fullScreenCover(isPresented: $showingAgeSelection) {
            AgeSelectionView()
        }
    }
}

#Preview {
    GenderSelectionView()
} 
