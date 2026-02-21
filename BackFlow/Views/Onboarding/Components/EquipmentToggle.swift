import SwiftUI

struct EquipmentToggle: View {
    let item: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? .blue : .gray)
                Text(item)
                    .foregroundStyle(.primary)
                Spacer()
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .accessibilityLabel("Equipment: \(item)")
        .accessibilityHint(isSelected ? "Selected. Tap to deselect" : "Not selected. Tap to select")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    VStack(spacing: 12) {
        EquipmentToggle(item: "Resistance band", isSelected: true, action: {})
        EquipmentToggle(item: "Weights", isSelected: false, action: {})
    }
    .padding()
}
