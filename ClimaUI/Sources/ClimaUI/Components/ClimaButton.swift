import SwiftUI

// MARK: - ClimaButton
//
// Botão do Design System. Variantes (primary/secondary/ghost), tamanhos
// e estados (normal/disabled/loading). Lê `isEnabled` do ambiente para o
// estado desabilitado — use `.disabled(true)` normalmente.

public struct ClimaButton: View {

    public enum Variant {
        case primary    // preenchido (gradiente de marca)
        case secondary  // superfície translúcida
        case ghost      // só texto
    }

    public enum Size {
        case small, medium, large

        var verticalPadding: CGFloat {
            switch self {
            case .small:  return 7
            case .medium: return 11
            case .large:  return 14
            }
        }
        var font: Font {
            switch self {
            case .small:  return .system(size: 13, weight: .semibold, design: .rounded)
            case .medium: return .system(size: 15, weight: .semibold, design: .rounded)
            case .large:  return .system(size: 16, weight: .semibold, design: .rounded)
            }
        }
    }

    @Environment(\.isEnabled) private var isEnabled

    private let title: String
    private let icon: String?
    private let variant: Variant
    private let size: Size
    private let isLoading: Bool
    private let action: () -> Void

    public init(
        _ title: String,
        icon: String? = nil,
        variant: Variant = .primary,
        size: Size = .medium,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.variant = variant
        self.size = size
        self.isLoading = isLoading
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: ClimaSpacing.sm) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(foreground)
                } else if let icon {
                    Image(systemName: icon).font(.system(size: 13, weight: .semibold))
                }
                Text(title).font(size.font)
            }
            .foregroundColor(foreground)
            .frame(maxWidth: .infinity)
            .padding(.vertical, size.verticalPadding)
            .padding(.horizontal, ClimaSpacing.md)
            .background(background)
            .clipShape(Capsule())
            .climaShadow(variant == .primary ? .card : .subtle)
            .opacity(isEnabled ? 1 : 0.45)
        }
        .disabled(isLoading)
    }

    // MARK: - Estilo por variante

    private var foreground: Color {
        switch variant {
        case .primary:             return .white
        case .secondary, .ghost:   return ClimaColor.accent
        }
    }

    @ViewBuilder
    private var background: some View {
        switch variant {
        case .primary:   ClimaGradient.brand
        case .secondary: ClimaColor.surface
        case .ghost:     Color.clear
        }
    }
}

#Preview {
    VStack(spacing: ClimaSpacing.md) {
        ClimaButton("Primário", icon: "sparkles") {}
        ClimaButton("Secundário", variant: .secondary) {}
        ClimaButton("Ghost", variant: .ghost) {}
        ClimaButton("Carregando", isLoading: true) {}
        ClimaButton("Desabilitado") {}.disabled(true)
    }
    .padding()
    .background(ClimaGradient.surface)
}
