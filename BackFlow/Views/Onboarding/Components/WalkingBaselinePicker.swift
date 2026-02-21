import SwiftUI

struct WalkingBaselinePicker: View {
    @Binding var minutes: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Walking Baseline")
                .font(.headline)
            
            Text("How many minutes can you walk comfortably today?")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Stepper(value: $minutes, in: 0...120, step: 5) {
                Text("\(minutes) minutes")
                    .font(.title3)
                    .fontWeight(.medium)
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
            .accessibilityLabel("Walking baseline")
            .accessibilityValue("\(minutes) minutes")
        }
    }
}

#Preview {
    @Previewable @State var minutes = 10
    WalkingBaselinePicker(minutes: $minutes)
        .padding()
}
