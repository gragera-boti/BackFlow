import SwiftUI

struct FunctionTaskRow: View {
    let task: FunctionTask
    @Binding var difficulty: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(task.name)
                .font(.body)
            
            Slider(value: .init(
                get: { Double(difficulty) },
                set: { difficulty = Int($0) }
            ), in: 0...10, step: 1)
            .accessibilityLabel("Difficulty for \(task.name)")
            .accessibilityValue("\(difficulty) out of 10")
            
            HStack {
                Text("Easy")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(difficulty)")
                    .font(.caption)
                    .fontWeight(.medium)
                Spacer()
                Text("Impossible")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    @Previewable @State var difficulty = 5
    FunctionTaskRow(
        task: FunctionTask(name: "Sit for 30 minutes", difficulty: 5),
        difficulty: $difficulty
    )
    .padding()
}
