import Foundation

// MARK: - Mapper: OpenWeatherForecastResponse → [DailyForecast] (domínio)

enum ForecastMapper {
    static func map(_ dto: OpenWeatherForecastResponse) -> [DailyForecast] {
        var result: [DailyForecast] = []
        var lastDayKey = ""

        for item in dto.list {
            let date = Date(timeIntervalSince1970: TimeInterval(item.dt))
            let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
            let dayKey = "\(components.year ?? 0)-\(components.month ?? 0)-\(components.day ?? 0)"

            guard dayKey != lastDayKey else { continue }

            result.append(DailyForecast(
                date: date,
                tempMax: item.main.temp,
                tempMin: item.main.temp,
                condition: item.weather.first?.main ?? "",
                description: item.weather.first?.description ?? "",
                precipitation: item.pop * 100,
                humidity: item.main.humidity,
                windSpeed: item.wind.speed
            ))
            lastDayKey = dayKey
        }

        return Array(result.prefix(5))
    }
}
