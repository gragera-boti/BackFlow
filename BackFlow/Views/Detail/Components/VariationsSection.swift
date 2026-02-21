import SwiftUI

struct VariationsSection: View {
    let regressions: [String]
    let progressions: [String]
    
    var body: some View {
        HStack(spacing: 16) {
            if !regressions.isEmpty {
                VariationCard(title: "Easier", items: regressions, color: .green)
            }
            
            if !progressions.isEmpty {
                VariationCard(title: "Harder", items: progressions, color: .orange)
            }
        }
    }
}

struct VariationCard: View {
    let title: String
    let items: [String]
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            
            ForEach(items, id: \.self) { item in
                Text("• \(item)")
                    .font(.caption)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title) variations: \(items.joined(separator: ", "))")
    }
}

#Preview {
    VariationsSection(
        regressions: ["Smaller range", "Use support"],
        progressions: ["Add holds", "Increase range"]
    )
    .padding()
}
