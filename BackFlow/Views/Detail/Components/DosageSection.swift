import SwiftUI

struct DosageSection: View {
    let reps: Int?
    let holdSec: Int?
    let sets: Int
    let notes: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recommended Dosage")
                .font(.headline)
            
            HStack {
                if let reps = reps {
                    DosageCard(label: "Reps", value: "\(reps)")
                }
                if let hold = holdSec {
                    DosageCard(label: "Hold", value: "\(hold)s")
                }
                DosageCard(label: "Sets", value: "\(sets)")
            }
            
            if !notes.isEmpty {
                Text(notes)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct DosageCard: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(value) \(label)")
    }
}

#Preview {
    DosageSection(
        reps: 8,
        holdSec: nil,
        sets: 2,
        notes: "Slow and controlled"
    )
    .padding()
}
