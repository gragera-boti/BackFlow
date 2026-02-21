import SwiftUI

struct EducationBiteCard: View {
    let card: EducationCard
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            CardView(backgroundColor: Theme.Colors.accent.opacity(0.1)) {
                VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                    header
                    
                    Text(card.title)
                        .font(Theme.Typography.body)
                        .fontWeight(.medium)
                        .foregroundStyle(Theme.Colors.textPrimary)
                    
                    Text(card.summary)
                        .font(Theme.Typography.subheadline)
                        .foregroundStyle(Theme.Colors.textSecondary)
                        .lineLimit(2)
                }
            }
        }
        .buttonStyle(.plain)
    }
    
    private var header: some View {
        HStack {
            Text("💡 Learn")
                .font(Theme.Typography.headline)
            Spacer()
            Image(systemName: "chevron.right")
                .font(Theme.Typography.caption)
                .foregroundStyle(Theme.Colors.textSecondary)
        }
    }
}
