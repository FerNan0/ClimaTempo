import Foundation

// MARK: - Decisão de Adaptação (saída do motor)
//
// Resultado puro da avaliação da carga cognitiva. Não executa nada por si só —
// apenas descreve o que o app DEVERIA fazer. Quem aplica é a camada de serviço
// (AdaptiveEngine), o que mantém a decisão testável isoladamente.

/// O que o motor recomenda fazer diante do comportamento observado.
enum AdaptationDecision: Equatable {

    /// Nada a fazer — a interação está fluindo dentro do esperado.
    case noChange

    /// Carga elevada: SUGERE simplificar, mas pede permissão ao usuário.
    /// Preserva a agência (Shneiderman, 2022 — Human-Centered AI: alta
    /// automação COM alto controle humano). A IA atua "na periferia".
    case suggestSimplified(reason: String)

    /// Carga muito elevada: aplica a simplificação automaticamente.
    /// Só ocorre se o usuário tiver optado por adaptação automática plena.
    /// Sempre reversível e sinalizado de forma transparente.
    case autoSimplify(reason: String)

    /// Conveniência para a UI/telemetria saber se houve alguma recomendação.
    var isActionable: Bool {
        switch self {
        case .noChange:        return false
        case .suggestSimplified, .autoSimplify: return true
        }
    }

    /// Texto de transparência exibido ao usuário / registrado no log.
    var reason: String? {
        switch self {
        case .noChange:                     return nil
        case .suggestSimplified(let r):     return r
        case .autoSimplify(let r):          return r
        }
    }
}
