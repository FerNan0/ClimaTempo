import Foundation

// MARK: - Estimador de Carga Cognitiva (núcleo puro do motor)
//
// Este é o CORAÇÃO da contribuição do TCC: a lógica que transforma padrões de
// comportamento em uma decisão de adaptação AUTOMÁTICA, superando a
// parametrização manual (a preferência de 62,8% dos respondentes — Tabela 3).
//
// Modelo:
//   1. Considera-se apenas uma JANELA DESLIZANTE recente de eventos (o atrito
//      antigo não deve pesar para sempre — a carga é um estado momentâneo).
//   2. Soma-se o peso de cada sinal → "score" de carga cognitiva estimada.
//      Sinais de atrito somam; sinais de sucesso (tarefa concluída) subtraem.
//   3. Compara-se o score a dois limiares:
//        - `suggestThreshold`: SUGERE simplificar (pede permissão).
//        - `autoThreshold`:    SIMPLIFICA sozinho (se o usuário permitiu).
//
// Tudo é puro e determinístico: mesma entrada → mesma saída. Isso permite a
// bateria de testes unitários citada no TCC como evidência de validação.

struct CognitiveLoadEstimator {

    // MARK: - Configuração (parâmetros calibráveis)

    /// Parâmetros do modelo. Expostos para permitir calibração e para os
    /// testes injetarem cenários controlados. Os defaults foram escolhidos
    /// de forma conservadora para evitar adaptações precipitadas (falso-positivo
    /// é pior que falso-negativo: mexer na tela sem motivo quebra a confiança).
    struct Configuration {
        /// Duração da janela deslizante considerada (segundos).
        var window: TimeInterval = 90

        /// Score a partir do qual se SUGERE a simplificação.
        var suggestThreshold: Double = 6.0

        /// Score a partir do qual se aplica a simplificação automaticamente.
        var autoThreshold: Double = 10.0

        /// Pesos por tipo de sinal. Default = `Kind.defaultWeight`.
        var weights: [InteractionEvent.Kind: Double]

        init(
            window: TimeInterval = 90,
            suggestThreshold: Double = 6.0,
            autoThreshold: Double = 10.0,
            weights: [InteractionEvent.Kind: Double]? = nil
        ) {
            self.window = window
            self.suggestThreshold = suggestThreshold
            self.autoThreshold = autoThreshold
            self.weights = weights ?? Dictionary(
                uniqueKeysWithValues: InteractionEvent.Kind.allCases.map { ($0, $0.defaultWeight) }
            )
        }
    }

    let configuration: Configuration

    init(configuration: Configuration = Configuration()) {
        self.configuration = configuration
    }

    // MARK: - Cálculo do score

    /// Estima a carga cognitiva a partir dos eventos dentro da janela.
    /// Nunca retorna valor negativo — a interface "descansa" no piso zero.
    func score(events: [InteractionEvent], now: Date = Date()) -> Double {
        let recent = eventsInWindow(events, now: now)
        let raw = recent.reduce(0.0) { partial, event in
            partial + (configuration.weights[event.kind] ?? event.kind.defaultWeight)
        }
        return max(0, raw)
    }

    // MARK: - Decisão

    /// Decide a adaptação com base no comportamento recente.
    /// - Parameter alreadySimplified: se o modo simplificado já está ativo,
    ///   não faz sentido sugerir de novo — retorna `.noChange`.
    func decide(
        events: [InteractionEvent],
        now: Date = Date(),
        alreadySimplified: Bool
    ) -> AdaptationDecision {
        guard !alreadySimplified else { return .noChange }

        let recent = eventsInWindow(events, now: now)
        let currentScore = score(events: recent, now: now)

        guard currentScore >= configuration.suggestThreshold else {
            return .noChange
        }

        let reason = explain(events: recent)

        if currentScore >= configuration.autoThreshold {
            return .autoSimplify(reason: reason)
        }
        return .suggestSimplified(reason: reason)
    }

    // MARK: - Transparência

    /// Monta uma explicação em linguagem natural para o usuário, baseada no
    /// sinal de atrito DOMINANTE na janela. Sustenta o princípio de que a
    /// automação deve ser transparente e nunca "mágica" (Shneiderman, 2022).
    func explain(events: [InteractionEvent]) -> String {
        guard let dominant = dominantFrictionKind(in: events) else {
            return "Percebi que a tela pode estar difícil agora."
        }
        return "Percebi \(dominant.humanReadableCause)."
    }

    /// Sinal de atrito que mais contribuiu para a carga na janela
    /// (ignora sinais de alívio como `.taskCompleted`).
    func dominantFrictionKind(in events: [InteractionEvent]) -> InteractionEvent.Kind? {
        var contribution: [InteractionEvent.Kind: Double] = [:]
        for event in events {
            let weight = configuration.weights[event.kind] ?? event.kind.defaultWeight
            guard weight > 0 else { continue } // só atrito
            contribution[event.kind, default: 0] += weight
        }
        return contribution.max(by: { $0.value < $1.value })?.key
    }

    // MARK: - Privado

    private func eventsInWindow(_ events: [InteractionEvent], now: Date) -> [InteractionEvent] {
        let cutoff = now.addingTimeInterval(-configuration.window)
        return events.filter { $0.timestamp >= cutoff }
    }
}
