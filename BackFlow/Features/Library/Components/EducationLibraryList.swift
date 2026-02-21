import SwiftUI

struct EducationLibraryList: View {
    let cards: [EducationCard]
    let onCardSelected: (EducationCard) -> Void
    
    var body: some View {
        List {
            ForEach(cards, id: \.cardId) { card in
                Button(action: { onCardSelected(card) }) {
                    VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
                        Text(card.title)
                            .font(Theme.Typography.headline)
                            .foregroundStyle(Theme.Colors.textPrimary)
                        
                        Text(card.summary)
                            .font(Theme.Typography.subheadline)
                            .foregroundStyle(Theme.Colors.textSecondary)
                            .lineLimit(2)
                    }
                    .padding(.vertical, Theme.Spacing.xxSmall)
                }
                .buttonStyle(.plain)
            }
        }
        .listStyle(.insetGrouped)
    }
}