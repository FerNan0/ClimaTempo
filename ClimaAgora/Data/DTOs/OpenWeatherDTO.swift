import Foundation

// MARK: - DTOs da API OpenWeather
// Structs de decodificação — nunca saem da camada Data.

struct OpenWeatherResponse: Decodable {
    let name: String
    let main: OpenWeatherMain
    let weather: [OpenWeatherInfo]
    let wind: OpenWeatherWind
    let clouds: OpenWeatherClouds
    let visibility: Int
    let sys: OpenWeatherSys
}

struct OpenWeatherMain: Decodable {
    let temp: Double
    let feels_like: Double
    let humidity: Int
}

struct OpenWeatherInfo: Decodable {
    let main: String
    let description: String
}

struct OpenWeatherWind: Decodable {
    let speed: Double
}

struct OpenWeatherClouds: Decodable {
    let all: Int
}

struct OpenWeatherSys: Decodable {
    let sunrise: Int
    let sunset: Int
}

struct OpenWeatherForecastResponse: Decodable {
    let list: [OpenWeatherForecastItem]
}

struct OpenWeatherForecastItem: Decodable {
    let dt: Int
    let main: OpenWeatherMain
    let weather: [OpenWeatherInfo]
    let wind: OpenWeatherWind
    let clouds: OpenWeatherClouds
    let pop: Double
}

struct OpenWeatherUVResponse: Decodable {
    let value: Double?
}

struct OpenWeatherGeocodingResult: Decodable {
    let name: String
    let state: String?
    let country: String
    let lat: Double
    let lon: Double
}
