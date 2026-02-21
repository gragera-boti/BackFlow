import SwiftUI

struct CommonMistakesSection: View {
    let mistakes: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Common Mistakes")
                .font(.headline)
            
            ForEach(mistakes, id: \.self) { mistake in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundStyle(.orange)
                    Text(mistake)
                }
                .accessibilityLabel("Warning: \(mistake)")
            }
        }
    }
}

#Preview {
    CommonMistakesSection(mistakes: [
        "Moving too fast",
        "Not breathing properly",
        "Pushing through pain"
    ])
    .padding()
}
