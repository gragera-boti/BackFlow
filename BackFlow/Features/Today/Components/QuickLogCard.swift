import SwiftUI

struct QuickLogCard: View {
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            CardView(backgroundColor: Theme.Colors.warning.opacity(0.1)) {
                HStack {
                    VStack(alignment: .leading, spacing: Theme.Spacing.xxSmall) {
                        Text("Quick Log")
                            .font(Theme.Typography.headline)
                        Text("Track symptoms anytime")
                            .font(Theme.Typography.subheadline)
                            .foregroundStyle(Theme.Colors.textSecondary)
                    }
                    Spacer()
                    Image(systemName: "note.text.badge.plus")
                        .font(.largeTitle)
                        .foregroundStyle(Theme.Colors.warning)
                }
            }
        }
        .buttonStyle(.plain)
    }
}
