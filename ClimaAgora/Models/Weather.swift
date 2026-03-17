import Foundation

// MARK: - Estrutura de Clima Atual
struct Weather: Decodable, Identifiable, Equatable {
    let id = UUID()
    let city: String
    let temperature: Double
    let feelsLike: Double
    let condition: String
    let description: String
    let humidity: Int
    let windSpeed: Double
    let cloudiness: Int
    let sunrise: Date
    let sunset: Date
    let uvIndex: Double
    let visibility: Int
    
    // Implementar Equatable manualmente por causa do UUID
    static func == (lhs: Weather, rhs: Weather) -> Bool {
        return lhs.city == rhs.city &&
               lhs.temperature == rhs.temperature &&
               lhs.condition == rhs.condition
    }
    
    // Preview para SwiftUI
    static let preview = Weather(
        city: "São Paulo",
        temperature: 25.0,
        feelsLike: 26.0,
        condition: "Ensolarado",
        description: "Céu limpo",
        humidity: 65,
        windSpeed: 12.5,
        cloudiness: 10,
        sunrise: Date().addingTimeInterval(-21600), // 6 horas atrás
        sunset: Date().addingTimeInterval(21600),   // 6 horas depois
        uvIndex: 7.5,
        visibility: 10000
    )
}

// MARK: - Estrutura de Previsão (5 dias)
struct DailyForecast: Decodable, Identifiable {
    let id = UUID()
    let date: Date
    let tempMax: Double
    let tempMin: Double
    let condition: String
    let description: String
    let precipitation: Double
    let humidity: Int
    let windSpeed: Double
}

// MARK: - Estrutura de Previsão por Hora
struct HourlyForecast: Decodable, Identifiable {
    let id = UUID()
    let time: Date
    let temperature: Double
    let condition: String
    let precipitation: Double
    let humidity: Int
}

// MARK: - Respostas das APIs
struct OpenWeatherResponse: Decodable {
    let name: String
    let main: Main
    let weather: [WeatherInfo]
    let wind: Wind
    let clouds: Clouds
    let visibility: Int
    let sys: Sys
}

struct Main: Decodable {
    let temp: Double
    let feels_like: Double
    let humidity: Int
}

struct WeatherInfo: Decodable {
    let main: String
    let description: String
}

struct Wind: Decodable {
    let speed: Double
}

struct Clouds: Decodable {
    let all: Int
}

struct Sys: Decodable {
    let sunrise: Int
    let sunset: Int
}

// MARK: - Resposta de Previsão
struct ForecastResponse: Decodable {
    let list: [ForecastItem]
}

struct ForecastItem: Decodable {
    let dt: Int
    let main: Main
    let weather: [WeatherInfo]
    let wind: Wind
    let clouds: Clouds
    let pop: Double
}

// MARK: - Resposta de UV Index
struct UVIndexResponse: Decodable {
    let value: Double?
    
    enum CodingKeys: String, CodingKey {
        case value
    }
}

// MARK: - Resultado de Geocodificação (Busca de Cidades)
struct GeocodingResult: Decodable {
    let name: String
    let state: String?
    let country: String
    let lat: Double
    let lon: Double
    
    enum CodingKeys: String, CodingKey {
        case name
        case state
        case country
        case lat
        case lon
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.state = try container.decodeIfPresent(String.self, forKey: .state)
        self.country = try container.decode(String.self, forKey: .country)
        self.lat = try container.decode(Double.self, forKey: .lat)
        self.lon = try container.decode(Double.self, forKey: .lon)
    }
}
