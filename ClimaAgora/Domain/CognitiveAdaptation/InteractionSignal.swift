import Foundation

// MARK: - Sinais de Interação (modelo de domínio puro)
//
// Estas estruturas representam os "sintomas comportamentais" de sobrecarga
// cognitiva que o motor de adaptação observa em tempo real.
//
// Fundamentação (Teoria da Carga Cognitiva — Sweller):
//   A memória de trabalho tem capacidade finita. A carga cognitiva ESTRANHA
//   (extraneous load) — gerada por design ruidoso, navegação imprevisível e
//   falta de instruções — não é observável diretamente, mas se MANIFESTA em
//   padrões de comportamento: hesitação, toques repetidos, erros e idas-e-voltas.
//   Estes sinais são, portanto, PROXIES mensuráveis da carga estranha.
//
// Camada de domínio: puro, sem SwiftUI, sem rede, sem persistência.
// Isso mantém a lógica de decisão testável de forma isolada (ver testes),
// evidência de validação citável no TCC.

/// Um único sinal comportamental capturado durante a interação.
struct InteractionEvent: Equatable {

    /// Tipo do sinal. Cada caso mapeia uma barreira/atrito identificado na
    /// pesquisa preliminar (Tabelas 2 e 3 do TCC).
    enum Kind: String, Equatable, CaseIterable {

        /// Toques repetidos e rápidos no mesmo alvo ("rage taps").
        /// Sinal clássico de frustração em telemetria de UX.
        case repeatedTap

        /// O usuário re-disparou uma ação (ex.: tocar "Tentar novamente",
        /// refazer a mesma busca). Indica que a primeira tentativa não fluiu.
        case retry

        /// Uma operação falhou (ex.: erro de rede, cidade não encontrada).
        case error

        /// Tempo longo entre a tela aparecer e a primeira ação com propósito.
        /// Mapeia "falta de instruções claras (passo a passo)" — 48,8% (Tabela 2).
        case hesitation

        /// Retorno a uma tela recém-visitada (loop de navegação).
        /// Mapeia "navegação complexa e imprevisível" — 58,1% (Tabela 2).
        case backNavigation

        /// Sinal de SUCESSO: uma tarefa foi concluída de forma fluente.
        /// Reduz a estimativa de carga (interação sem atrito = carga baixa).
        case taskCompleted

        /// Peso do sinal na estimativa de carga cognitiva.
        /// Valores positivos indicam atrito; negativos, alívio.
        /// Parâmetros tunáveis — documentados como calibráveis no TCC.
        var defaultWeight: Double {
            switch self {
            case .repeatedTap:    return 3.0
            case .retry:          return 2.5
            case .error:          return 3.0
            case .hesitation:     return 1.5
            case .backNavigation: return 2.0
            case .taskCompleted:  return -2.5
            }
        }

        /// Explicação em linguagem natural do sinal — usada para transparência
        /// com o usuário (por que a interface se adaptou) e nos logs de validação.
        var humanReadableCause: String {
            switch self {
            case .repeatedTap:    return "vários toques seguidos no mesmo lugar"
            case .retry:          return "a mesma ação repetida algumas vezes"
            case .error:          return "algo não funcionou de primeira"
            case .hesitation:     return "um tempo parado sem saber o que tocar"
            case .backNavigation: return "idas e voltas entre as telas"
            case .taskCompleted:  return "tarefa concluída"
            }
        }
    }

    let kind: Kind
    /// Nome lógico da tela onde o sinal ocorreu (ex.: "Home", "Busca").
    let screen: String
    let timestamp: Date

    init(kind: Kind, screen: String, timestamp: Date = Date()) {
        self.kind = kind
        self.screen = screen
        self.timestamp = timestamp
    }
}
