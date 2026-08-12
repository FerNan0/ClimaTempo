import SwiftUI

// MARK: - ClimaTag
//
// Etiqueta/pill de status. O caso de uso central é o "semáforo de clima"
// (🟢 seguro / 🟡 atenção / 🔴 perigo) da acessibilidade do app.

public struct ClimaTag: View {

    public enum Status {
        case safe, caution, danger, neutral

        var color: Color {
            switch self {
            case .safe:    return ClimaColor.safe
            case .caution: return ClimaColor.caution
            case .danger:  return ClimaColor.danger
            case .neutral: return ClimaColor.textTertiary
            }
        }
    }

    private let text: String
    private let icon: String?
    private let status: Status

    public init(_ text: String, icon: String? = nil, status: Status = .neutral) {
        self.text = text
        self.icon = icon
        self.status = status
    }

    public var body: some View {
        HStack(spacing: ClimaSpacing.xs) {
            if let icon {
                Image(systemName: icon).font(.system(size: 11, weight: .bold))
            }
            Text(text).font(ClimaFont.label)
        }
        .foregroundColor(status.color)
        .padding(.vertical, ClimaSpacing.xs)
        .padding(.horizontal, ClimaSpacing.sm)
        .background(
            Capsule().fill(status.color.opacity(0.15))
        )
    }
}

#Preview {
    VStack(spacing: ClimaSpacing.sm) {
        ClimaTag("Bom para sair", icon: "checkmark.circle.fill", status: .safe)
        ClimaTag("Atenção ao sair", icon: "exclamationmark.triangle.fill", status: .caution)
        ClimaTag("Melhor ficar em casa", icon: "house.fill", status: .danger)
        ClimaTag("Neutro", status: .neutral)
    }
    .padding()
    .background(ClimaGradient.surface)
}
