import Foundation

// MARK: - WeatherRisk
//
// Um aviso de risco do tempo, em linguagem simples (acessibilidade cognitiva).
// Cada risco responde três perguntas que a pessoa realmente tem:
//   • o QUE é (título curto + emoji âncora)
//   • o que PODE ACONTECER (consequência concreta, sem jargão)
//   • o que FAZER (ação prática)
// É um modelo de domínio puro — quem decide os limiares é o WeatherRiskAssessor.

struct WeatherRisk: Identifiable, Equatable {

    /// Gravidade — casa com o semáforo visual 🟢🟡🔴 do app.
    enum Level: Int, Comparable {
        case safe = 0       // 🟢 tranquilo
        case attention = 1  // 🟡 atenção
        case danger = 2     // 🔴 perigo

        static func < (lhs: Level, rhs: Level) -> Bool { lhs.rawValue < rhs.rawValue }

        var label: String {
            switch self {
            case .safe:      return "Tudo tranquilo"
            case .attention: return "Atenção"
            case .danger:    return "Perigo"
            }
        }
        var emoji: String {
            switch self {
            case .safe: return "🟢"; case .attention: return "🟡"; case .danger: return "🔴"
            }
        }
    }

    /// Tipo de ameaça — usado como identidade estável (não há dois riscos do
    /// mesmo tipo na mesma avaliação) e para ordenação/testes.
    enum Hazard: String { case wind, storm, rain, heat, cold, uv, fog }

    let hazard: Hazard
    let level: Level
    let emoji: String
    let title: String          // "Ventania"
    let whatCanHappen: String  // "Pode derrubar galhos e objetos soltos."
    let whatToDo: String       // "Evite a praia e áreas abertas."

    var id: Hazard { hazard }
}
