import Foundation

// MARK: - OfficialAlert
//
// Aviso METEOROLÓGICO OFICIAL (INMET / Defesa Civil), já traduzido para o
// formato acessível do app: "o que pode acontecer" + "o que fazer", com nível
// de semáforo. Diferente do WeatherRisk (derivado on-device), este vem de uma
// fonte oficial — por isso carrega a fonte, a área e a validade do aviso.

struct OfficialAlert: Identifiable, Equatable {
    let id: String
    let source: String          // "INMET"
    let hazard: String          // "Tempestade", "Chuva", "Ventania"...
    let severityLabel: String   // "Perigo Potencial", "Perigo", "Grande Perigo"
    let level: WeatherRisk.Level // mapeado para 🟢🟡🔴
    let emoji: String
    let whatCanHappen: String    // riscos do aviso
    let whatToDo: String         // instruções do aviso
    let areaLabel: String        // ex.: "SP, RJ e +2"
    let startText: String?       // "13/08 09:15" (pré-formatado pela fonte)
    let endText: String?         // "14/08 23:59"
    let isFuture: Bool           // veio da lista "futuro" (ainda vai começar)
}
