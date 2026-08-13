import SwiftUI

// MARK: - ClimaPill (cápsula selecionável)
//
// Pill reutilizável para chips de cidade, seletor de período (3d/7d/10d),
// filtros de categoria, etc. Estado ativo usa o texto escuro de marca em
// fundo sólido; inativo usa vidro. Segue o design handoff v2.

public struct ClimaPill: View {

    private let title: String
    private let icon: String?
    private let isActive: Bool
    private let action: () -> Void

    public init(
        _ title: String,
        icon: String? = nil,
        isActive: Bool = false,
        action: @escaping () -> Void = {}
    ) {
        self.title = title
        self.icon = icon
        self.isActive = isActive
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: ClimaSpacing.xs + 2) {
                if let icon { Text(icon) }
                Text(title)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
            }
            .foregroundStyle(isActive ? Color.white : ClimaColor.textPrimary)
            .padding(.horizontal, ClimaSpacing.md)
            .padding(.vertical, ClimaSpacing.sm + 1)
            .background(pillBackground)
            .overlay(
                Capsule().stroke(ClimaColor.glassBorder, lineWidth: isActive ? 0 : 1)
            )
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var pillBackground: some View {
        if isActive {
            Capsule().fill(ClimaColor.textPrimary) // #23233F sólido
        } else {
            Capsule().fill(.ultraThinMaterial)
        }
    }
}

// MARK: - ClimaDashedPill (pill inspiracional "quero visitar")

/// Variante estática com borda tracejada (chips "🧭 Quero visitar").
public struct ClimaDashedPill: View {
    private let title: String
    public init(_ title: String) { self.title = title }

    public var body: some View {
        Text(title)
            .font(.system(size: 13, weight: .semibold, design: .rounded))
            .foregroundStyle(ClimaColor.textSecondary)
            .padding(.horizontal, ClimaSpacing.md)
            .padding(.vertical, ClimaSpacing.sm)
            .overlay(
                Capsule().stroke(
                    ClimaColor.textTertiary.opacity(0.6),
                    style: StrokeStyle(lineWidth: 1, dash: [4, 3])
                )
            )
    }
}
