import SwiftUI

struct SessionActionButtons: View {
    let isLastSet: Bool
    let isLastExercise: Bool
    let onComplete: () -> Void
    let onLogPain: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Button(action: onComplete) {
                Text(buttonText)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(12)
            }
            .accessibilityLabel(buttonText)
            
            Button(action: onLogPain) {
                Text("Log Pain During Exercise")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
            }
            .accessibilityLabel("Log pain during exercise")
        }
        .padding()
    }
    
    private var buttonText: String {
        if isLastSet && isLastExercise {
            return "Finish Session"
        } else if isLastSet {
            return "Next Exercise"
        } else {
            return "Next Set"
        }
    }
}

#Preview {
    ZStack {
        Color.black
        SessionActionButtons(
            isLastSet: false,
            isLastExercise: false,
            onComplete: {},
            onLogPain: {}
        )
    }
}
