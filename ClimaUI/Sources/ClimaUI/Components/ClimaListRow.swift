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
                    .font(.system(size: 16, weight: .semibold))
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(ClimaColor.textPrimary)
                Spacer()
                if showsChevron {
                    Image(systemName: "chevron.right")
                        .foregroundColor(ClimaColor.textTertiary.opacity(0.6))
                        .font(.system(size: 14, weight: .semibold))
                }
            }
            .padding(ClimaSpacing.md - 2)
            .background(
                RoundedRectangle(cornerRadius: ClimaRadius.md)
                    .fill(Color(.systemGray6).opacity(0.8))
            )
        }
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
