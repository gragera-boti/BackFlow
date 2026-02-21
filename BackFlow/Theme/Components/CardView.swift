import SwiftUI

struct CardView<Content: View>: View {
    let content: Content
    var backgroundColor: Color = Theme.Colors.cardBackground
    var cornerRadius: CGFloat = Theme.CornerRadius.large
    var padding: CGFloat = Theme.Spacing.medium
    var useGlassMorphism: Bool = true
    
    init(
        backgroundColor: Color = Theme.Colors.cardBackground,
        cornerRadius: CGFloat = Theme.CornerRadius.large,
        padding: CGFloat = Theme.Spacing.medium,
        useGlassMorphism: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.useGlassMorphism = useGlassMorphism
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(glassBackground)
            .cornerRadius(cornerRadius)
            .shadow(
                color: Theme.Shadows.card.color,
                radius: Theme.Shadows.card.radius,
                x: Theme.Shadows.card.x,
                y: Theme.Shadows.card.y
            )
    }
    
    @ViewBuilder
    private var glassBackground: some View {
        if useGlassMorphism {
            ZStack {
                backgroundColor
                    .opacity(0.6)
                
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        backgroundColor.opacity(0.05)
                    )
            }
        } else {
            backgroundColor
        }
    }
}
