import Foundation

// MARK: - SimplifiedAdvice (entidade de domínio)
//
// Conselho de clima em LINGUAGEM SIMPLES (Plain Language) para o modo simples
// full-screen. Frases curtas, uma ideia por linha, com âncora visual (emoji).
// Modelo puro — a geração (on-device via Foundation Models) vive na camada Data.

struct SimplifiedAdvice: Equatable {
    /// Como está o tempo, em uma frase curta (ex.: "Está frio lá fora. 🥶").
    let weatherPhrase: String
    /// O que fazer, em uma frase curta (ex.: "Leve um casaco. 🧥").
    let advice: String
    /// Aviso de cuidado, se houver (ex.: "Vai chover, leve guarda-chuva. ☔").
    let caution: String?

    init(weatherPhrase: String, advice: String, caution: String? = nil) {
        self.weatherPhrase = weatherPhrase
        self.advice = advice
        self.caution = caution
    }

    /// Fallback determinístico (sem IA) — usado quando o modelo on-device não
    /// está disponível. Garante que o modo simples sempre tenha um conselho claro.
    static func fallback(for weather: Weather) -> SimplifiedAdvice {
        let temp = Int(weather.temperature)
        let condition = weather.condition.lowercased()

        let phrase: String
        switch temp {
        case ..<10:  phrase = "Está muito frio lá fora. 🥶"
        case 10..<18: phrase = "Está um pouco frio. 🧥"
        case 18..<25: phrase = "A temperatura está agradável. 😊"
        case 25..<32: phrase = "Está quente. ☀️"
        default:      phrase = "Está muito quente! 🔥"
        }

        let advice: String
        if temp < 18 { advice = "Leve um casaco. 🧥" }
        else if temp >= 30 { advice = "Beba bastante água. 💧" }
        else { advice = "Bom dia para sair. 🙂" }

        var caution: String? = nil
        if condition.contains("rain") || condition.contains("drizzle") {
            caution = "Vai chover. Leve um guarda-chuva. ☔"
        } else if condition.contains("thunder") {
            caution = "Tem tempestade. Fique em lugar seguro. ⛈️"
        }

        return SimplifiedAdvice(weatherPhrase: phrase, advice: advice, caution: caution)
    }
}
