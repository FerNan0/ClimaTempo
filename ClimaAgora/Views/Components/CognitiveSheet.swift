import SwiftUI
import ClimaUI

// MARK: - CognitiveSheet
//
// Overlay do motor de adaptação cognitiva — o diferencial do app/TCC.
// Explica o algoritmo em linguagem simples, mostra a carga cognitiva atual
// e as métricas da sessão, e permite simular sinais de atrito (demo/QA).

struct CognitiveSheet: View {
    @ObservedObject private var engine = AdaptiveEngine.shared
    @Environment(\.dismiss) private var dismiss

    private var load: Int { min(10, Int(engine.currentLoad.rounded())) }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: ClimaSpacing.md) {
                // Cabeçalho
                HStack(spacing: ClimaSpacing.sm) {
                    Text("🧠").font(.system(size: 26))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Motor de Adaptação")
                            .font(.system(size: 20, weight: .heavy, design: .rounded))
                            .foregroundStyle(ClimaColor.textPrimary)
                        Text("O app percebe e ajuda sozinho")
                            .font(.system(size: 13)).foregroundStyle(ClimaColor.textTertiary)
                    }
                    Spacer()
                }

                // Explicação em linguagem simples
                Text("O app observa como você usa a tela — toques repetidos, erros, hesitação — e estima a sua carga cognitiva numa janela recente. Ao passar de um limiar, ele sugere simplificar; num limiar maior, adapta sozinho (sempre reversível). Tudo acontece no aparelho.")
                    .font(.system(size: 14))
                    .foregroundStyle(ClimaColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                // Barra de carga cognitiva
                ClimaGlassCard {
                    VStack(alignment: .leading, spacing: ClimaSpacing.sm) {
                        HStack {
                            Text("Carga cognitiva agora")
                                .font(.system(size: 13, weight: .semibold)).foregroundStyle(ClimaColor.textSecondary)
                            Spacer()
                            Text("\(load)/10")
                                .font(.system(size: 15, weight: .heavy, design: .monospaced))
                                .foregroundStyle(ClimaColor.cognitiveLoad(load))
                        }
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule().fill(ClimaColor.textTertiary.opacity(0.18)).frame(height: 8)
                                Capsule().fill(ClimaColor.cognitiveLoad(load))
                                    .frame(width: geo.size.width * CGFloat(load) / 10, height: 8)
                                    .animation(.easeInOut(duration: 0.3), value: load)
                            }
                        }
                        .frame(height: 8)
                    }
                }

                // Métricas totais da sessão
                let m = engine.telemetry.metrics
                let totalSignals = m.repeatedTaps + m.retries + m.errors + m.hesitations + m.backNavigations
                HStack(spacing: ClimaSpacing.sm) {
                    ClimaSummaryTile(value: "\(totalSignals)", label: "Sinais de atrito")
                    ClimaSummaryTile(value: "\(m.suggestionsAccepted)", label: "Sugestões aceitas")
                    ClimaSummaryTile(value: "\(m.autoAdaptations)", label: "Adaptações automáticas")
                }

                // Ações
                VStack(spacing: ClimaSpacing.sm) {
                    ClimaButton("Simular sinais de atrito", icon: "wand.and.sparkles") {
                        HapticManager.shared.trigger(.medium)
                        engine.simulateFriction()
                    }
                    ClimaButton("Fechar", variant: .secondary) { dismiss() }
                }
                .padding(.top, ClimaSpacing.xs)
            }
            .padding(ClimaSpacing.lg)
        }
        .background(ClimaGradient.surface.ignoresSafeArea())
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
