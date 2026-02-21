import SwiftUI

struct CardView<Content: View>: View {
    let content: Content
    var backgroundColor: Color = Theme.Colors.cardBackground
    var cornerRadius: CGFloat = Theme.CornerRadius.large
    var padding: CGFloat = Theme.Spacing.medium
    
    init(
        backgroundColor: Color = Theme.Colors.cardBackground,
        cornerRadius: CGFloat = Theme.CornerRadius.large,
        padding: CGFloat = Theme.Spacing.medium,
        @ViewBuilder content: () -> Content
    ) {
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
    }
}
