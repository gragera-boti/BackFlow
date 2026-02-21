import SwiftUI

struct StopAndSeekCareView: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.red)
            
            Text("Please Seek Medical Care")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Based on your responses, we recommend consulting a healthcare provider.")
                    .font(.body)
                
                Text("You indicated symptoms that may require medical evaluation:")
                    .font(.body)
                    .fontWeight(.medium)
                
                VStack(alignment: .leading, spacing: 8) {
                    BulletPoint(text: "Contact your doctor or healthcare provider")
                    BulletPoint(text: "For severe or worsening symptoms, seek urgent care")
                    BulletPoint(text: "For emergencies, call emergency services")
                }
            }
            .padding()
            .background(Color.orange.opacity(0.1))
            .cornerRadius(12)
            
            Text("This app is designed to support self-management of stable low back pain. It cannot replace professional medical assessment.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            Button(action: {
                // User acknowledges but plan remains paused
                // In a real app, you might want to exit or show limited functionality
            }) {
                Text("I Understand")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

struct BulletPoint: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .font(.body)
            Text(text)
                .font(.body)
        }
    }
}

#Preview {
    StopAndSeekCareView()
}
