import SwiftUI

// MARK: - ClimaToggleRow
//
// Linha de configuração com ícone colorido + título + subtítulo + Toggle.
// Estilo dos toggles de acessibilidade do app.

public struct ClimaToggleRow: View {

    private let icon: String
    private let iconColor: Color
    private let title: String
    private let subtitle: String
    @Binding private var isOn: Bool

    public init(
        icon: String,
        iconColor: Color = ClimaColor.accent,
        title: String,
        subtitle: String,
        isOn: Binding<Bool>
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.subtitle = subtitle
        self._isOn = isOn
    }

    public var body: some View {
        HStack(spacing: ClimaSpacing.sm + 4) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(iconColor)
                .frame(width: 28, height: 28)
                .background(iconColor.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 7))

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(ClimaColor.textPrimary)
                Text(subtitle)
                    .font(ClimaFont.label)
                    .fontWeight(.regular)
                    .foregroundColor(ClimaColor.textSecondary)
                    .lineLimit(2)
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(ClimaColor.accent)
                .scaleEffect(0.85)
        }
        .padding(.horizontal, ClimaSpacing.md)
        .padding(.vertical, ClimaSpacing.sm + 2)
    }
}

#Preview {
    struct Demo: View {
        @State private var a = true
        @State private var b = false
        var body: some View {
            ClimaCard(padding: ClimaSpacing.sm) {
                VStack(spacing: 0) {
                    ClimaToggleRow(icon: "textformat.abc", iconColor: .green,
                                   title: "Linguagem Simplificada",
                                   subtitle: "Textos mais curtos e fáceis", isOn: $a)
                    ClimaToggleRow(icon: "plus.magnifyingglass", iconColor: .orange,
                                   title: "Ícones Grandes",
                                   subtitle: "Aumenta ícones e áreas de toque", isOn: $b)
                }
            }
            .padding()
            .background(ClimaGradient.surface)
        }
    }
    return Demo()
}
