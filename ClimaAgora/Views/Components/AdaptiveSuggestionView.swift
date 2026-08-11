import SwiftUI

// MARK: - Camada de UI da Adaptação Automática
//
// Duas responsabilidades:
//   1. AdaptiveSuggestionBanner — mostra a sugestão gentil ("quer simplificar?")
//      e o aviso transparente de adaptação automática. Sempre dispensável.
//   2. Modificadores de rastreamento — as Views "instrumentam" seus fluxos com
//      UMA linha, sem se acoplar à lógica do motor.
//
// A UI reforça o princípio de AGÊNCIA: a IA convida, nunca impõe; e quando
// adapta sozinha, avisa em linguagem clara e oferece o retorno ao normal.

// MARK: - Banner de Sugestão / Aviso

struct AdaptiveSuggestionBanner: View {
    @ObservedObject private var engine = AdaptiveEngine.shared
    @ObservedObject private var accessibility = CognitiveAccessibilityManager.shared

    var body: some View {
        VStack(spacing: 10) {
            if let suggestion = engine.pendingSuggestion {
                suggestionCard(reason: suggestion.reason)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            if let notice = engine.autoAdaptationNotice {
                autoNoticeCard(text: notice)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: engine.pendingSuggestion)
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: engine.autoAdaptationNotice)
        .padding(.horizontal, 16)
    }

    // Sugestão: pede permissão. Preserva a agência do usuário.
    private func suggestionCard(reason: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: "wand.and.sparkles")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.cyan)
                    .accessibilityHidden(true)
                Text("Quer deixar mais simples?")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.28))
                Spacer()
            }

            Text(reason + " Posso deixar a tela mais fácil de usar.")
                .font(.system(size: 13))
                .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.5))
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 10) {
                Button {
                    HapticManager.shared.trigger(.medium)
                    withAnimation { engine.acceptSuggestion() }
                } label: {
                    Text("Sim, simplificar")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.cyan))
                }
                .accessibilityHint("Ativa a linguagem simplificada e mostra só o essencial")

                Button {
                    HapticManager.shared.trigger(.light)
                    withAnimation { engine.dismissSuggestion() }
                } label: {
                    Text("Agora não")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.5))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.12)))
                }
            }
            .frame(minHeight: 44)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: Color.cyan.opacity(0.18), radius: 12, x: 0, y: 4)
        )
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.cyan.opacity(0.35), lineWidth: 1))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Sugestão: \(reason) Quer deixar a tela mais simples?")
    }

    // Aviso: a interface já se adaptou sozinha. Transparente e reversível.
    private func autoNoticeCard(text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 18))
                .foregroundColor(.green)
                .accessibilityHidden(true)

            Text(text)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.4))
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 8)

            Button {
                HapticManager.shared.trigger(.light)
                withAnimation {
                    accessibility.isSimplifiedMode = false
                    engine.acknowledgeAutoNotice()
                }
            } label: {
                Text("Voltar")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14).padding(.vertical, 8)
                    .background(RoundedRectangle(cornerRadius: 9).fill(Color.green.opacity(0.85)))
            }
            .accessibilityLabel("Voltar ao modo normal")
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
                .shadow(color: Color.green.opacity(0.12), radius: 8, x: 0, y: 3)
        )
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.green.opacity(0.3), lineWidth: 1))
    }
}

// MARK: - Modificadores de Rastreamento

private struct AdaptiveScreenModifier: ViewModifier {
    let screen: String
    private let engine = AdaptiveEngine.shared

    func body(content: Content) -> some View {
        content
            .onAppear { engine.enterScreen(screen) }
            .onDisappear { engine.exitScreen(screen) }
            // Conta os toques SEM consumi-los (roda em paralelo com os botões),
            // permitindo detectar "rage taps" e o fim de uma hesitação.
            .simultaneousGesture(
                TapGesture().onEnded { engine.registerTap(on: screen) }
            )
    }
}

extension View {
    /// Instrumenta uma tela para o motor de adaptação: registra entrada/saída
    /// (loops de navegação) e toques (rage taps, hesitação). Uma linha por tela.
    func adaptiveScreen(_ screen: String) -> some View {
        modifier(AdaptiveScreenModifier(screen: screen))
    }

    /// Ancora o banner de sugestão/aviso no topo do conteúdo desta tela.
    func adaptiveBanner(alignment: Alignment = .top) -> some View {
        overlay(alignment: alignment) {
            AdaptiveSuggestionBanner()
                .padding(.top, 8)
        }
    }
}
