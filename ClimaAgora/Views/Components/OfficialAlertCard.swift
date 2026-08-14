import SwiftUI
import ClimaUI

// MARK: - OfficialAlertCard
//
// Aviso meteorológico OFICIAL (INMET), no mesmo formato acessível do card de
// risco — "o que pode acontecer" + "o que fazer" — mas com selo de fonte, a
// validade do aviso e a área coberta. Diferencia-se por carregar autoridade:
// quando a Defesa Civil/INMET emite, este card aparece no topo.

struct OfficialAlertCard: View {
    let alert: OfficialAlert
    var simplified: Bool = false
    var largeIcons: Bool = false

    private var tint: Color { alert.level.climaColor }

    var body: some View {
        VStack(alignment: .leading, spacing: ClimaSpacing.sm + 2) {
            sourceBadge
            header
            divider
            infoBlock(label: "O QUE PODE ACONTECER", text: alert.whatCanHappen)
            infoBlock(label: "O QUE FAZER", text: alert.whatToDo)
            footer
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
                .stroke(tint.opacity(0.5), lineWidth: 1.5)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityText)
    }

    // MARK: - Selo de fonte oficial

    private var sourceBadge: some View {
        HStack(spacing: 5) {
            Image(systemName: "checkmark.seal.fill").font(.system(size: 11, weight: .bold))
            Text("AVISO OFICIAL · \(alert.source)")
                .font(.system(size: 11, weight: .heavy, design: .rounded)).tracking(0.4)
        }
        .foregroundStyle(tint)
        .padding(.horizontal, ClimaSpacing.sm)
        .padding(.vertical, 3)
        .background(Capsule().fill(tint.opacity(0.16)))
    }

    // MARK: - Cabeçalho

    private var header: some View {
        HStack(spacing: ClimaSpacing.sm + 2) {
            Text(alert.emoji)
                .font(.system(size: largeIcons ? 40 : 30))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(alert.hazard)
                    .font(.system(size: largeIcons ? 21 : 18, weight: .heavy, design: .rounded))
                    .foregroundStyle(ClimaColor.textPrimary)
                Text("\(alert.level.emoji) \(alert.severityLabel)")
                    .font(.system(size: largeIcons ? 14 : 12, weight: .bold))
                    .foregroundStyle(tint)
            }
            Spacer()
        }
    }

    private var divider: some View {
        Rectangle().fill(tint.opacity(0.25)).frame(height: 1)
    }

    private func infoBlock(label: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label)
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundStyle(ClimaColor.textTertiary).tracking(0.4)
            Text(text)
                .font(.system(size: largeIcons ? 16 : 14, weight: simplified ? .semibold : .regular))
                .foregroundStyle(ClimaColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Rodapé (validade + área)

    private var footer: some View {
        HStack(spacing: ClimaSpacing.sm) {
            if let validity {
                label(icon: "clock", text: validity)
            }
            label(icon: "mappin.and.ellipse", text: alert.areaLabel)
            Spacer(minLength: 0)
        }
        .padding(.top, 2)
    }

    private func label(icon: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon).font(.system(size: 11, weight: .semibold))
            Text(text).font(.system(size: 12, weight: .semibold, design: .rounded)).lineLimit(1)
        }
        .foregroundStyle(ClimaColor.textTertiary)
    }

    /// Texto de validade: "Começa 13/08 09:15" (futuro) ou "Vale até 14/08 23:59".
    private var validity: String? {
        if alert.isFuture {
            return alert.startText.map { "Começa \($0)" }
        }
        return alert.endText.map { "Vale até \($0)" }
    }

    private var accessibilityText: String {
        var parts = ["Aviso oficial do \(alert.source). \(alert.severityLabel): \(alert.hazard).",
                     "O que pode acontecer: \(alert.whatCanHappen)",
                     "O que fazer: \(alert.whatToDo)",
                     "Área: \(alert.areaLabel)."]
        if let validity { parts.append(validity + ".") }
        return parts.joined(separator: " ")
    }
}
