import SwiftUI
import SwiftData

struct EducationDetailView: View {
    let card: EducationCard
    @Query private var references: [Reference]
    
    var cardReferences: [Reference] {
        references.filter { card.refs.contains($0.key) }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(card.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(card.summary)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .padding()
                
                Divider()
                
                // Detail content (markdown-ish)
                VStack(alignment: .leading, spacing: 16) {
                    Text(card.detailMarkdown)
                        .font(.body)
                }
                .padding()
                
                Divider()
                
                // References
                if !cardReferences.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("References")
                            .font(.headline)
                        
                        ForEach(cardReferences, id: \.key) { reference in
                            ReferenceView(reference: reference)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ReferenceView: View {
    let reference: Reference
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(reference.title)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Text("\(reference.authors) (\(reference.year))")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            if !reference.journal.isEmpty {
                Text(reference.journal)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .italic()
            }
            
            if !reference.url.isEmpty {
                Link("View Source", destination: URL(string: reference.url)!)
                    .font(.caption)
                    .foregroundStyle(.blue)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
}

#Preview {
    NavigationStack {
        EducationDetailView(card: EducationCard(
            cardId: "pain-science-1",
            title: "Understanding Back Pain",
            summary: "Most low back pain is non-specific and recovers with time and movement.",
            detailMarkdown: "Back pain is extremely common and usually not dangerous. Research shows that staying active and gradually increasing movement helps recovery more than rest.\n\nKey points:\n• Pain doesn't always equal tissue damage\n• Movement is medicine\n• Recovery is normal",
            refs: []
        ))
    }
    .modelContainer(for: [Reference.self], inMemory: true)
}
