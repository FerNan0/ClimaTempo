import SwiftUI

// MARK: - ClimaStatTile
//
// Métrica compacta: ícone + valor + rótulo. Usado na linha de stats
// (umidade / vento / UV) da tela principal.

public struct ClimaStatTile: View {

    private let icon: String
    private let value: String
    private let label: String
    private let tint: Color

    public init(icon: String, value: String, label: String, tint: Color = ClimaColor.accent) {
        self.icon = icon
        self.value = value
        self.label = label
        self.tint = tint
    }

    public var body: some View {
        VStack(spacing: ClimaSpacing.xs + 2) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(tint)
            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(ClimaColor.textPrimary)
            Text(label)
                .font(ClimaFont.label)
                .fontWeight(.regular)
                .foregroundColor(ClimaColor.textTertiary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ClimaCard {
        HStack(spacing: 0) {
            ClimaStatTile(icon: "drop.fill", value: "65%", label: "Umidade", tint: .cyan)
            Divider().frame(height: 36)
            ClimaStatTile(icon: "wind", value: "12 km/h", label: "Vento", tint: .mint)
            Divider().frame(height: 36)
            ClimaStatTile(icon: "sun.max.fill", value: "7", label: "UV", tint: .orange)
        }
    }
    .padding()
    .background(ClimaGradient.surface)
}
