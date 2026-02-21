import SwiftUI

struct PrimaryCuesSection: View {
    let cues: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How to Perform")
                .font(.headline)
            
            ForEach(Array(cues.enumerated()), id: \.offset) { index, cue in
                HStack(alignment: .top, spacing: 12) {
                    Text("\(index + 1).")
                        .fontWeight(.medium)
                        .foregroundStyle(.blue)
                    Text(cue)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Step \(index + 1): \(cue)")
            }
        }
    }
}

#Preview {
    PrimaryCuesSection(cues: [
        "Start on hands and knees",
        "Arch back (cow)",
        "Round back (cat)"
    ])
    .padding()
}
