import Foundation

// MARK: - Mapper: OpenWeatherAirPollutionResponse → AirQuality (domínio)

enum AirQualityMapper {
    static func map(_ dto: OpenWeatherAirPollutionResponse) -> AirQuality? {
        guard let item = dto.list.first else { return nil }
        let level = AirQuality.Level(rawValue: item.main.aqi) ?? .moderate
        return AirQuality(level: level, pm25: item.components.pm2_5)
    }
}
