import Foundation

// MARK: - ForecastPeriod (entidade de domínio)
// Faixa de dias selecionável na previsão (substitui a lista fixa de 5 dias).
// A API gratuita do OpenWeather cobre até ~5 dias; faixas maiores são limitadas
// aos dias disponíveis (uma API de previsão estendida entra aqui no futuro).

enum ForecastPeriod: Int, CaseIterable, Identifiable {
    case threeDays = 3
    case sevenDays = 7
    case tenDays = 10

    var id: Int { rawValue }

    /// Rótulo curto para o seletor (3d / 7d / 10d).
    var label: String { "\(rawValue)d" }

    /// Nº de dias pedidos por esta faixa.
    var days: Int { rawValue }
}

// MARK: - Resumo agregado de um período de previsão

struct ForecastSummary: Equatable {
    let averageMax: Double
    let averageMin: Double
    let rainyDays: Int

    /// Agrega uma lista de dias em um resumo (média de máx/mín, dias com chuva).
    static func from(_ days: [DailyForecast]) -> ForecastSummary {
        guard !days.isEmpty else { return ForecastSummary(averageMax: 0, averageMin: 0, rainyDays: 0) }
        let maxAvg = days.map(\.tempMax).reduce(0, +) / Double(days.count)
        let minAvg = days.map(\.tempMin).reduce(0, +) / Double(days.count)
        let rainy = days.filter { $0.precipitation >= 30 }.count
        return ForecastSummary(averageMax: maxAvg, averageMin: minAvg, rainyDays: rainy)
    }
}
