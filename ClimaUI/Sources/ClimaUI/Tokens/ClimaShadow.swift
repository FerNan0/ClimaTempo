import SwiftUI

// MARK: - ClimaShadow (elevações)

public struct ClimaShadow {
    public let color: Color
    public let radius: CGFloat
    public let x: CGFloat
    public let y: CGFloat

    public init(color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
        self.color = color
        self.radius = radius
        self.x = x
        self.y = y
    }

    /// Elevação padrão de card.
    public static let card = ClimaShadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    /// Elevação sutil (chips, divisórias).
    public static let subtle = ClimaShadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
}

public extension View {
    /// Aplica uma elevação do Design System.
    func climaShadow(_ shadow: ClimaShadow = .card) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
}
