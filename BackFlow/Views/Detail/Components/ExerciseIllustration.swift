import SwiftUI

struct ExerciseIllustration: View {
    let assetName: String
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.blue.opacity(0.1))
                .frame(height: 250)
            
            VStack {
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue)
                Text("Illustration: \(assetName)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityLabel("Exercise illustration")
    }
}

#Preview {
    ExerciseIllustration(assetName: "cat-cow.svg")
}
