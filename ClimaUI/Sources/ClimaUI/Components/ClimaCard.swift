import SwiftUI

// MARK: - ClimaCard
//
// Container padrão de superfície (material translúcido + canto + sombra).
// Envolve qualquer conteúdo: `ClimaCard { ... }`.

public struct ClimaCard<Content: View>: View {
    private let content: Content
    private let padding: CGFloat

    public init(padding: CGFloat = ClimaSpacing.md, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }

    public var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .climaGlass(cornerRadius: ClimaRadius.lg)
    }
}

#Preview {
    VStack(spacing: ClimaSpacing.md) {
        ClimaCard {
            Text("Conteúdo de um card")
                .font(ClimaFont.headline)
                .foregroundColor(ClimaColor.textPrimary)
        }
        ClimaCard {
            VStack(alignment: .leading, spacing: ClimaSpacing.sm) {
                Text("Título").font(ClimaFont.headline).foregroundColor(ClimaColor.textPrimary)
                Text("Subtítulo com texto secundário.")
                    .font(ClimaFont.callout).foregroundColor(ClimaColor.textSecondary)
            }
        }
    }
    .padding()
    .background(ClimaGradient.surface)
}
