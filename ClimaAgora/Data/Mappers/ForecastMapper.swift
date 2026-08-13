import Foundation

// MARK: - Mapper: OpenWeatherForecastResponse → [DailyForecast] (domínio)
//
// A API de previsão retorna pontos de 3 em 3 horas. Este mapper AGREGA os
// pontos por dia, calculando a mínima e a máxima reais do dia, a condição
// predominante e a maior probabilidade de precipitação. (Antes o mapper pegava
// apenas o primeiro ponto do dia, o que deixava tempMax == tempMin.)

enum ForecastMapper {
    static func map(_ dto: OpenWeatherForecastResponse) -> [DailyForecast] {
        let calendar = Calendar.current

        // Agrupa os pontos por dia, preservando a ordem cronológica.
        var order: [Date] = []
        var groups: [Date: [OpenWeatherForecastItem]] = [:]

        for item in dto.list {
            let date = Date(timeIntervalSince1970: TimeInterval(item.dt))
            let day = calendar.startOfDay(for: date)
            if groups[day] == nil { order.append(day) }
            groups[day, default: []].append(item)
        }

        let days: [DailyForecast] = order.compactMap { day in
            guard let items = groups[day], !items.isEmpty else { return nil }

            let temps = items.map(\.main.temp)
            let tempMax = temps.max() ?? 0
            let tempMin = temps.min() ?? 0
            let precipitation = (items.map(\.pop).max() ?? 0) * 100

            // Condição predominante = a que mais aparece no dia (desempate: meio-dia).
            let midday = items.min(by: {
                abs(hour(of: $0, calendar) - 12) < abs(hour(of: $1, calendar) - 12)
            })
            let condition = midday?.weather.first?.main ?? items.first?.weather.first?.main ?? ""
            let description = midday?.weather.first?.description ?? items.first?.weather.first?.description ?? ""

            let humidityAvg = items.map(\.main.humidity).reduce(0, +) / items.count
            let windAvg = items.map(\.wind.speed).reduce(0, +) / Double(items.count)

            return DailyForecast(
                date: day,
                tempMax: tempMax,
                tempMin: tempMin,
                condition: condition,
                description: description,
                precipitation: precipitation,
                humidity: humidityAvg,
                windSpeed: windAvg
            )
        }

        return days
    }

    private static func hour(of item: OpenWeatherForecastItem, _ calendar: Calendar) -> Int {
        calendar.component(.hour, from: Date(timeIntervalSince1970: TimeInterval(item.dt)))
    }
}

// MARK: - Mapper: OpenWeatherForecastResponse → [HourlyForecast] (próximas horas)

enum HourlyMapper {
    /// Converte os primeiros pontos (3h em 3h) na faixa de próximas horas.
    static func map(_ dto: OpenWeatherForecastResponse, limit: Int = 8) -> [HourlyForecast] {
        dto.list.prefix(limit).map { item in
            HourlyForecast(
                time: Date(timeIntervalSince1970: TimeInterval(item.dt)),
                temperature: item.main.temp,
                condition: item.weather.first?.main ?? "",
                precipitation: item.pop * 100,
                humidity: item.main.humidity
            )
        }
    }
}
