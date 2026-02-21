import SwiftUI

struct ExerciseInfoSection: View {
    let name: String
    let difficulty: String
    let equipment: [String]
    let category: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(name)
                .font(.title)
                .fontWeight(.bold)
            
            HStack(spacing: 16) {
                InfoChip(icon: "chart.bar", text: difficulty.capitalized)
                InfoChip(icon: "dumbbell", text: equipment.joined(separator: ", "))
                InfoChip(icon: "figure.stand", text: category)
            }
        }
    }
}

struct InfoChip: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.caption)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    ExerciseInfoSection(
        name: "Cat-Cow",
        difficulty: "beginner",
        equipment: ["none"],
        category: "mobility"
    )
    .padding()
}
