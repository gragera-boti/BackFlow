import SwiftUI

struct GoalToggle: View {
    let goal: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? .blue : .gray)
                Text(goal)
                    .foregroundStyle(.primary)
                Spacer()
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .accessibilityLabel(goal)
        .accessibilityHint(isSelected ? "Selected. Tap to deselect" : "Not selected. Tap to select")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    VStack(spacing: 12) {
        GoalToggle(goal: "Reduce flare-ups", isSelected: true, action: {})
        GoalToggle(goal: "Move more comfortably", isSelected: false, action: {})
    }
    .padding()
}
