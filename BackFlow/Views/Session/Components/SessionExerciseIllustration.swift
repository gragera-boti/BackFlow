import SwiftUI

struct SessionExerciseIllustration: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 300)
            
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 100))
                .foregroundStyle(.white.opacity(0.8))
        }
        .cornerRadius(16)
        .accessibilityLabel("Exercise demonstration")
    }
}

#Preview {
    ZStack {
        Color.black
        SessionExerciseIllustration()
            .padding()
    }
}
