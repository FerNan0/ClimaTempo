import Foundation
import Combine

// MARK: - Motor de Adaptação (facade que orquestra a adaptação automática)
//
// Une as três peças:
//   1. InteractionTelemetry — observa o comportamento (sinais).
//   2. CognitiveLoadEstimator — decide, de forma pura, se deve adaptar.
//   3. CognitiveAccessibilityManager — aplica a adaptação (modo simplificado).
//
// É a ÚNICA porta que as Views usam. Elas apenas relatam eventos
// ("houve um toque", "entrou na tela X", "deu erro") e o motor cuida do resto.
//
// Comportamento em duas etapas, preservando a agência do usuário
// (Shneiderman, 2022 — alta automação COM alto controle humano):
//   - Carga elevada  → SUGERE (banner gentil, dispensável).
//   - Carga muito alta + usuário optou por auto → APLICA sozinho, avisando.
// Toda adaptação é sempre reversível e transparente.

@MainActor
final class AdaptiveEngine: ObservableObject {

    static let shared = AdaptiveEngine()

    // MARK: - Dependências

    let telemetry: InteractionTelemetry
    private let estimator: CognitiveLoadEstimator
    private let accessibility: CognitiveAccessibilityManager

    // MARK: - Estado publicado (consumido pela UI)

    /// Sugestão pendente a ser mostrada ao usuário (nil = nada a mostrar).
    @Published private(set) var pendingSuggestion: PendingSuggestion?

    /// Aviso transparente de que a interface se adaptou sozinha (auto-simplify).
    @Published private(set) var autoAdaptationNotice: String?

    /// Score de carga cognitiva atual — exposto para depuração/demonstração.
    @Published private(set) var currentLoad: Double = 0

    struct PendingSuggestion: Equatable, Identifiable {
        let id = UUID()
        let reason: String
    }

    // MARK: - Init

    init(
        telemetry: InteractionTelemetry? = nil,
        estimator: CognitiveLoadEstimator = CognitiveLoadEstimator(),
        accessibility: CognitiveAccessibilityManager = .shared
    ) {
        // Construído dentro do init (contexto @MainActor) — evita chamar o
        // inicializador main-actor-isolated de InteractionTelemetry num
        // argumento default (contexto nonisolated).
        self.telemetry = telemetry ?? InteractionTelemetry()
        self.estimator = estimator
        self.accessibility = accessibility
    }

    // MARK: - Entradas (chamadas pelas Views)

    func registerTap(on screen: String) {
        telemetry.registerTap(on: screen)
        evaluate(on: screen)
    }

    func enterScreen(_ screen: String) {
        telemetry.enterScreen(screen)
        evaluate(on: screen)
    }

    func exitScreen(_ screen: String) {
        telemetry.exitScreen(screen)
    }

    func registerRetry(on screen: String) {
        telemetry.registerRetry(on: screen)
        evaluate(on: screen)
    }

    func registerError(on screen: String) {
        telemetry.registerError(on: screen)
        evaluate(on: screen)
    }

    func registerTaskCompleted(on screen: String) {
        telemetry.registerTaskCompleted(on: screen)
        evaluate(on: screen)
    }

    // MARK: - Respostas do usuário à sugestão

    /// O usuário aceitou simplificar.
    func acceptSuggestion() {
        accessibility.applySimplifiedProfile(source: .suggestionAccepted)
        telemetry.registerSuggestionAccepted()
        pendingSuggestion = nil
    }

    /// O usuário recusou (agora não).
    func dismissSuggestion() {
        telemetry.registerSuggestionDismissed()
        pendingSuggestion = nil
    }

    /// Reconhece o aviso de adaptação automática (fecha o aviso).
    func acknowledgeAutoNotice() {
        autoAdaptationNotice = nil
    }

    // MARK: - Núcleo: avaliar e agir

    private func evaluate(on screen: String) {
        currentLoad = estimator.score(events: telemetry.events)

        // Respeita o interruptor-mestre: se a adaptação automática está
        // desligada, o motor só observa (telemetria), nunca age.
        guard accessibility.automaticAdaptationEnabled else { return }

        let decision = estimator.decide(
            events: telemetry.events,
            alreadySimplified: accessibility.isSimplifiedMode
        )

        switch decision {
        case .noChange:
            break

        case .suggestSimplified(let reason):
            // Não empilha sugestões nem interrompe uma já visível.
            if pendingSuggestion == nil {
                pendingSuggestion = PendingSuggestion(reason: reason)
                telemetry.registerSuggestionShown()
            }

        case .autoSimplify(let reason):
            if accessibility.allowAutoApply {
                accessibility.applySimplifiedProfile(source: .automatic)
                telemetry.registerAutoAdaptation()
                autoAdaptationNotice = "\(reason) Deixei a tela mais simples pra ajudar. Você pode voltar ao normal quando quiser."
                pendingSuggestion = nil
            } else {
                // Sem permissão de auto-aplicar → rebaixa para sugestão.
                if pendingSuggestion == nil {
                    pendingSuggestion = PendingSuggestion(reason: reason)
                    telemetry.registerSuggestionShown()
                }
            }
        }
    }
}
