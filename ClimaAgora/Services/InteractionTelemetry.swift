import Foundation

// MARK: - Telemetria de Interação (on-device, privacy-by-design)
//
// Registra os sinais comportamentais e mantém MÉTRICAS AGREGADAS de validação.
//
// PRIVACIDADE (endereça a limitação ética central do TCC):
//   - Nada trafega para servidores externos. Tudo fica em UserDefaults local.
//   - Não se guarda CONTEÚDO (o que o usuário digitou/leu), apenas CONTADORES
//     de padrões de interação. Não há dado pessoal identificável.
//   - Alinhado à LGPD por minimização de dados e processamento local.
//
// Além de alimentar o motor de adaptação, esta classe produz os DADOS
// EMPÍRICOS para a próxima fase da pesquisa (prometida na seção de Limitações
// do TCC): quantas adaptações foram disparadas, aceitas, e por quê.

@MainActor
final class InteractionTelemetry: ObservableObject {

    // MARK: - Buffer de eventos (janela recente para o estimador)

    /// Eventos recentes usados pelo estimador. Podado para não crescer sem limite.
    @Published private(set) var events: [InteractionEvent] = []

    /// Métricas acumuladas para exportação/validação (persistidas localmente).
    @Published private(set) var metrics: ValidationMetrics

    // MARK: - Estado interno para derivação de padrões

    private var recentTapTimestamps: [Date] = []
    private var screenEnteredAt: [String: Date] = [:]
    private var awaitingFirstAction: Set<String> = []
    private var navigationHistory: [String] = []

    // Parâmetros de derivação (calibráveis)
    private let rageTapWindow: TimeInterval = 1.5   // s
    private let rageTapCount = 3                     // toques
    private let hesitationThreshold: TimeInterval = 6.0 // s
    private let backNavLookback = 3                  // telas
    private let maxBufferedEvents = 120

    private let storageKey = "cognitiveAdaptation_validationMetrics"

    init() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode(ValidationMetrics.self, from: data) {
            self.metrics = decoded
        } else {
            self.metrics = ValidationMetrics()
        }
    }

    // MARK: - Registro direto de sinais

    /// Registra um sinal já classificado e atualiza as métricas.
    func record(_ kind: InteractionEvent.Kind, screen: String) {
        let event = InteractionEvent(kind: kind, screen: screen)
        events.append(event)
        trim()
        metrics.count(kind)
        persist()
    }

    // MARK: - Derivação de padrões a partir de sinais brutos

    /// Deve ser chamado a cada toque relevante. Deriva:
    ///  - "rage tap" (toques repetidos e rápidos)
    ///  - fim da hesitação (primeira ação após tempo longo parado)
    func registerTap(on screen: String) {
        let now = Date()
        metrics.totalTaps += 1

        // Hesitação: primeira ação demorou demais nesta tela?
        if awaitingFirstAction.contains(screen),
           let enteredAt = screenEnteredAt[screen],
           now.timeIntervalSince(enteredAt) > hesitationThreshold {
            record(.hesitation, screen: screen)
        }
        awaitingFirstAction.remove(screen)

        // Rage tap: N toques dentro de uma janela curta.
        recentTapTimestamps.append(now)
        recentTapTimestamps = recentTapTimestamps.filter {
            now.timeIntervalSince($0) <= rageTapWindow
        }
        if recentTapTimestamps.count >= rageTapCount {
            record(.repeatedTap, screen: screen)
            recentTapTimestamps.removeAll() // evita disparos em cascata
        }
    }

    /// Deve ser chamado quando uma tela aparece. Deriva loop de navegação.
    func enterScreen(_ screen: String) {
        let now = Date()
        screenEnteredAt[screen] = now
        awaitingFirstAction.insert(screen)

        // Loop de navegação: voltei a uma tela que visitei há pouco?
        if navigationHistory.suffix(backNavLookback).contains(screen) {
            record(.backNavigation, screen: screen)
        }
        navigationHistory.append(screen)
        if navigationHistory.count > 20 { navigationHistory.removeFirst() }
    }

    /// Deve ser chamado quando uma tela desaparece.
    func exitScreen(_ screen: String) {
        awaitingFirstAction.remove(screen)
    }

    /// Uma ação foi re-tentada (ex.: botão "Tentar novamente", refazer busca).
    func registerRetry(on screen: String) { record(.retry, screen: screen) }

    /// Uma operação falhou.
    func registerError(on screen: String) { record(.error, screen: screen) }

    /// Uma tarefa foi concluída com sucesso (sinal de alívio).
    func registerTaskCompleted(on screen: String) { record(.taskCompleted, screen: screen) }

    // MARK: - Contabilização de decisões (para validação)

    func registerSuggestionShown()   { metrics.suggestionsShown += 1;   persist() }
    func registerSuggestionAccepted() { metrics.suggestionsAccepted += 1; persist() }
    func registerSuggestionDismissed() { metrics.suggestionsDismissed += 1; persist() }
    func registerAutoAdaptation()     { metrics.autoAdaptations += 1;    persist() }

    // MARK: - Exportação

    /// Resumo legível para colar no TCC / apresentar à banca.
    func exportSummary() -> String { metrics.humanReadableSummary() }

    /// Zera as métricas acumuladas (útil para iniciar uma nova sessão de teste).
    func resetMetrics() {
        metrics = ValidationMetrics()
        events.removeAll()
        persist()
    }

    // MARK: - Privado

    private func trim() {
        if events.count > maxBufferedEvents {
            events.removeFirst(events.count - maxBufferedEvents)
        }
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(metrics) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}

// MARK: - Métricas de Validação

/// Contadores agregados e anônimos. Nenhum conteúdo pessoal — só padrões.
struct ValidationMetrics: Codable, Equatable {
    var totalTaps: Int = 0
    var repeatedTaps: Int = 0
    var retries: Int = 0
    var errors: Int = 0
    var hesitations: Int = 0
    var backNavigations: Int = 0
    var tasksCompleted: Int = 0

    var suggestionsShown: Int = 0
    var suggestionsAccepted: Int = 0
    var suggestionsDismissed: Int = 0
    var autoAdaptations: Int = 0

    mutating func count(_ kind: InteractionEvent.Kind) {
        switch kind {
        case .repeatedTap:    repeatedTaps += 1
        case .retry:          retries += 1
        case .error:          errors += 1
        case .hesitation:     hesitations += 1
        case .backNavigation: backNavigations += 1
        case .taskCompleted:  tasksCompleted += 1
        }
    }

    /// Total de adaptações efetivamente entregues (sugestões aceitas + automáticas).
    var totalAdaptations: Int { suggestionsAccepted + autoAdaptations }

    /// Taxa de aceitação das sugestões (0...1). `nil` se nenhuma foi mostrada.
    var acceptanceRate: Double? {
        guard suggestionsShown > 0 else { return nil }
        return Double(suggestionsAccepted) / Double(suggestionsShown)
    }

    func humanReadableSummary() -> String {
        var lines: [String] = []
        lines.append("— Métricas de adaptação cognitiva (sessão local) —")
        lines.append("Toques totais: \(totalTaps)")
        lines.append("Sinais de atrito detectados:")
        lines.append("  • Toques repetidos: \(repeatedTaps)")
        lines.append("  • Re-tentativas: \(retries)")
        lines.append("  • Erros: \(errors)")
        lines.append("  • Hesitações: \(hesitations)")
        lines.append("  • Loops de navegação: \(backNavigations)")
        lines.append("Tarefas concluídas: \(tasksCompleted)")
        lines.append("Adaptações:")
        lines.append("  • Sugestões mostradas: \(suggestionsShown)")
        lines.append("  • Sugestões aceitas: \(suggestionsAccepted)")
        lines.append("  • Sugestões recusadas: \(suggestionsDismissed)")
        lines.append("  • Adaptações automáticas: \(autoAdaptations)")
        if let rate = acceptanceRate {
            lines.append(String(format: "  • Taxa de aceitação: %.0f%%", rate * 100))
        }
        return lines.joined(separator: "\n")
    }
}
