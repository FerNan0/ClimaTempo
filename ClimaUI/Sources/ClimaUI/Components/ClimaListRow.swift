import SwiftUI

// MARK: - ClimaListRow
//
// Linha de lista tocável com ícone à esquerda, título e chevron.
// Usada na busca de cidades e em listas de navegação.

public struct ClimaListRow: View {

    private let title: String
    private let icon: String
    private let iconColor: Color
    private let showsChevron: Bool
    private let action: () -> Void

    public init(
        _ title: String,
        icon: String = "mappin.circle.fill",
        iconColor: Color = ClimaColor.accent,
        showsChevron: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.iconColor = iconColor
        self.showsChevron = showsChevron
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: ClimaSpacing.sm + 4) {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.system(size: 16, weight: .bold))
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(iconColor.opacity(0.14)))
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(ClimaColor.textPrimary)
                Spacer()
                if showsChevron {
                    Image(systemName: "chevron.right")
                        .foregroundColor(ClimaColor.textTertiary.opacity(0.7))
                        .font(.system(size: 14, weight: .bold))
                }
            }
            .padding(.horizontal, ClimaSpacing.md - 2)
            .padding(.vertical, ClimaSpacing.sm + 2)
            .climaGlass(cornerRadius: ClimaRadius.lg)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: ClimaSpacing.sm) {
        ClimaListRow("São Paulo") {}
        ClimaListRow("Rio de Janeiro") {}
        ClimaListRow("Curitiba", icon: "star.fill", iconColor: .orange) {}
    }
    .padding()
    .background(ClimaGradient.surface)
}
