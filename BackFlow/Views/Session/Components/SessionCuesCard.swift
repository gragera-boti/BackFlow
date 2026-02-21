import SwiftUI

struct SessionCuesCard: View {
    let cues: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(Array(cues.enumerated()), id: \.offset) { index, cue in
                HStack(alignment: .top, spacing: 12) {
                    Text("\(index + 1)")
                        .font(.headline)
                        .foregroundStyle(.blue)
                        .frame(width: 24)
                    Text(cue)
                        .font(.body)
                        .foregroundStyle(.white)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Step \(index + 1): \(cue)")
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    ZStack {
        Color.black
        SessionCuesCard(cues: [
            "Start on hands and knees",
            "Arch back (cow)",
            "Round back (cat)"
        ])
        .padding()
    }
}
