import SwiftUI
import ClimaUI

// MARK: - WeatherRiskCard
//
// Aviso de risco do tempo no topo da Home, pensado para acessibilidade
// cognitiva: cor de semáforo (🟢🟡🔴), emoji âncora, título curto e as duas
// perguntas que importam — "o que pode acontecer" e "o que fazer" — uma ideia
// por linha, sem jargão. Respeita os ajustes do usuário (modo simples, ícones
// grandes). Quando não há risco, tranquiliza em vez de alarmar.

struct WeatherRiskCard: View {
    let risks: [WeatherRisk]
    var simplified: Bool = false
    var largeIcons: Bool = false

    private var main: WeatherRisk { risks.first ?? .allClear }
    private var tint: Color { color(for: main.level) }

    var body: some View {
        VStack(alignment: .leading, spacing: ClimaSpacing.sm + 2) {
            header
            divider
            infoBlock(label: "O QUE PODE ACONTECER", text: main.whatCanHappen)
            infoBlock(label: "O QUE FAZER", text: main.whatToDo)
            if !simplified, risks.count > 1 { secondary }
        }
        .padding(ClimaSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: ClimaRadius.lg, style: .continuous)
                .fill(tint.opacity(0.12))
                .climaShadow(.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: ClimaRadius.lg, style: .continuous)
                .stroke(tint.opacity(0.45), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityText)
    }

    // MARK: - Cabeçalho

    private var header: some View {
        HStack(spacing: ClimaSpacing.sm + 2) {
            Text(main.emoji)
                .font(.system(size: largeIcons ? 40 : 30))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(main.title)
                    .font(.system(size: largeIcons ? 21 : 18, weight: .heavy, design: .rounded))
                    .foregroundStyle(ClimaColor.textPrimary)
                Text("\(main.level.emoji) \(main.level.label)")
                    .font(.system(size: largeIcons ? 14 : 12, weight: .bold))
                    .foregroundStyle(tint)
            }
            Spacer()
        }
    }

    private var divider: some View {
        Rectangle().fill(tint.opacity(0.25)).frame(height: 1)
    }

    // MARK: - Blocos "o que pode acontecer / o que fazer"

    private func infoBlock(label: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label)
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundStyle(ClimaColor.textTertiary)
                .tracking(0.4)
            Text(text)
                .font(.system(size: largeIcons ? 16 : 14, weight: simplified ? .semibold : .regular))
                .foregroundStyle(ClimaColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Riscos adicionais (compacto)

    private var secondary: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("TAMBÉM")
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundStyle(ClimaColor.textTertiary)
                .tracking(0.4)
            HStack(spacing: ClimaSpacing.sm) {
                ForEach(risks.dropFirst()) { risk in
                    HStack(spacing: 4) {
                        Text(risk.emoji)
                        Text(risk.title).font(.system(size: 13, weight: .semibold, design: .rounded))
                    }
                    .foregroundStyle(ClimaColor.textSecondary)
                    .padding(.horizontal, ClimaSpacing.sm)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(color(for: risk.level).opacity(0.14)))
                }
            }
        }
    }

    // MARK: - Helpers

    private func color(for level: WeatherRisk.Level) -> Color {
        switch level {
        case .safe:      return ClimaColor.safe
        case .attention: return ClimaColor.caution
        case .danger:    return ClimaColor.danger
        }
    }

    private var accessibilityText: String {
        var parts = ["\(main.level.label). \(main.title).",
                     "O que pode acontecer: \(main.whatCanHappen)",
                     "O que fazer: \(main.whatToDo)"]
        if risks.count > 1 {
            parts.append("Também: " + risks.dropFirst().map(\.title).joined(separator: ", "))
        }
        return parts.joined(separator: " ")
    }
}

// MARK: - Estado "sem risco"

extension WeatherRisk {
    /// Aviso tranquilizador quando não há nenhum risco ativo.
    static let allClear = WeatherRisk(
        hazard: .uv, level: .safe, emoji: "✅",
        title: "Tempo tranquilo",
        whatCanHappen: "Nenhum risco à vista para agora.",
        whatToDo: "Aproveite! Só confira de novo antes de sair.")
}

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            WeatherRiskCard(risks: WeatherRiskAssessor.assess(weather: Weather.preview))
            WeatherRiskCard(risks: [])
        }
        .padding()
    }
    .background(ClimaGradient.surface)
}
