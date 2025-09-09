import SwiftUI

struct PreferredNameView: View {
    @State private var preferredName = ""
    @State private var showingActivityLevel = false
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Your Preferred Name")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 40)
            
            Text("How would you like to be called?")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            // Name Input Field
            VStack(spacing: 15) {
                TextField("Enter your name", text: $preferredName)
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(.systemGray6))
                    )
                    .padding(.horizontal, 40)
                
                if !preferredName.isEmpty {
                    Text("Hello, \(preferredName)!")
                        .font(.title3)
                        .foregroundColor(.blue)
                        .padding(.top, 10)
                }
            }
            
            Spacer()
            
            // Continue Button
            Button(action: {
                // Save preferred name to UserDefaults
                UserDefaults.standard.set(preferredName, forKey: "preferredName")
                withAnimation {
                    showingActivityLevel = true
                }
            }) {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(preferredName.isEmpty ? Color.gray : Color.blue)
                    .cornerRadius(15)
            }
            .disabled(preferredName.isEmpty)
            .padding(.horizontal, 40)
            .padding(.bottom, 30)
        }
        .fullScreenCover(isPresented: $showingActivityLevel) {
            ActivityLevelView()
        }
    }
}

#Preview {
    PreferredNameView()
} 