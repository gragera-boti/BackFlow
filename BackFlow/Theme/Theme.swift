import SwiftUI

// MARK: - Design Tokens

enum Theme {
    // MARK: - Colors
    enum Colors {
        static let primary = Color.blue
        static let secondary = Color.green
        static let accent = Color.purple
        static let warning = Color.orange
        static let error = Color.red
        static let success = Color.green
        
        static let textPrimary = Color.primary
        static let textSecondary = Color.secondary
        static let background = Color(.systemBackground)
        static let cardBackground = Color(.secondarySystemBackground)
    }
    
    // MARK: - Typography
    enum Typography {
        static let largeTitle = Font.largeTitle.weight(.bold)
        static let title = Font.title.weight(.semibold)
        static let title2 = Font.title2.weight(.semibold)
        static let title3 = Font.title3.weight(.medium)
        static let headline = Font.headline
        static let body = Font.body
        static let callout = Font.callout
        static let subheadline = Font.subheadline
        static let footnote = Font.footnote
        static let caption = Font.caption
    }
    
    // MARK: - Spacing
    enum Spacing {
        static let xxSmall: CGFloat = 4
        static let xSmall: CGFloat = 8
        static let small: CGFloat = 12
        static let medium: CGFloat = 16
        static let large: CGFloat = 20
        static let xLarge: CGFloat = 24
        static let xxLarge: CGFloat = 32
    }
    
    // MARK: - Corner Radius
    enum CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xLarge: CGFloat = 20
    }
    
    // MARK: - Shadows
    enum Shadows {
        static let card = Shadow(
            color: Color.black.opacity(0.1),
            radius: 8,
            x: 0,
            y: 2
        )
        
        static let button = Shadow(
            color: Color.black.opacity(0.15),
            radius: 4,
            x: 0,
            y: 2
        )
    }
    
    struct Shadow {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }
}
