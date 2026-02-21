import SwiftUI

struct PainSlider: View {
    @Binding var value: Int
    
    var body: some View {
        VStack(spacing: 8) {
            Slider(value: .init(
                get: { Double(value) },
                set: { value = Int($0) }
            ), in: 0...10, step: 1)
            .accessibilityLabel("Pain level slider")
            .accessibilityValue("\(value) out of 10")
            
            HStack {
                Text("No pain")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(value)/10")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(painColor(for: value))
                Spacer()
                Text("Worst pain")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private func painColor(for value: Int) -> Color {
        switch value {
        case 0...3: return .green
        case 4...6: return .orange
        default: return .red
        }
    }
}

#Preview {
    @Previewable @State var pain = 5
    PainSlider(value: $pain)
        .padding()
}
