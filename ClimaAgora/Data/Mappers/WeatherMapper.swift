import Foundation

// MARK: - Mapper: OpenWeatherResponse → Weather (domínio)

enum WeatherMapper {
    static func map(_ dto: OpenWeatherResponse) -> Weather {
        Weather(
            city: dto.name,
            temperature: dto.main.temp,
            feelsLike: dto.main.feels_like,
            condition: dto.weather.first?.main ?? "",
            description: dto.weather.first?.description ?? "",
            humidity: dto.main.humidity,
            windSpeed: dto.wind.speed,
            cloudiness: dto.clouds.all,
            sunrise: Date(timeIntervalSince1970: TimeInterval(dto.sys.sunrise)),
            sunset: Date(timeIntervalSince1970: TimeInterval(dto.sys.sunset)),
            uvIndex: 0.0,
            visibility: dto.visibility
        )
    }
}
