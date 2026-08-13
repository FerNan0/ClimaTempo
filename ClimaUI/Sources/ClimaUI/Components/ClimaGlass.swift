import SwiftUI

// MARK: - ClimaGlass (superfície de vidro reutilizável)
//
// A linguagem visual do app é glassmorphism: material translúcido + borda
// clara hairline + canto arredondado. Este modificador padroniza esse fundo
// para qualquer container (cards, banners, pills), evitando repetir o mesmo
// `.background(...).overlay(...)` em cada view.

public extension View {
    /// Aplica o fundo de vidro do Design System.
    /// - Parameters:
    ///   - cornerRadius: raio do canto (padrão `ClimaRadius.lg`).
    ///   - strong: usa material/borda mais opacos (para banners e sheets).
    func climaGlass(cornerRadius: CGFloat = ClimaRadius.lg, strong: Bool = false) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        return self
            .background(
                shape.fill(strong ? AnyShapeStyle(.regularMaterial) : AnyShapeStyle(.ultraThinMaterial))
                    .climaShadow(.card)
            )
            .overlay(shape.stroke(ClimaColor.glassBorder, lineWidth: 1))
            .clipShape(shape)
    }
}

// MARK: - ClimaGlassCard (container de vidro com raio configurável)

/// Card de vidro genérico. Diferente de `ClimaCard`, permite ajustar o raio
/// (os cards novos do handoff usam 16–22px) e o preenchimento.
public struct ClimaGlassCard<Content: View>: View {
    private let content: Content
    private let padding: CGFloat
    private let cornerRadius: CGFloat

    public init(
        padding: CGFloat = ClimaSpacing.md,
        cornerRadius: CGFloat = ClimaRadius.lg,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.content = content()
    }

    public var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .climaGlass(cornerRadius: cornerRadius)
    }
}
