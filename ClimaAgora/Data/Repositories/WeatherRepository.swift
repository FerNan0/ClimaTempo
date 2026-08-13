import Foundation

// MARK: - Implementação concreta do WeatherRepositoryProtocol

final class WeatherRepository: WeatherRepositoryProtocol {
    private let client: NetworkClient
    private let apiKey: String
    private let baseURL = "https://api.openweathermap.org/data/2.5"
    private let geoURL  = "https://api.openweathermap.org/geo/1.0"

    init(client: NetworkClient, apiKey: String = Secrets.openWeatherMapKey) {
        self.client = client
        self.apiKey = apiKey
    }

    // MARK: - Clima atual

    func fetchWeather(for city: String) async throws -> Weather {
        let encoded = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city
        let url = "\(baseURL)/weather?q=\(encoded)&appid=\(apiKey)&units=metric&lang=pt_br"
        let dto: OpenWeatherResponse = try await client.get(url)
        return WeatherMapper.map(dto)
    }

    // MARK: - Previsão 5 dias

    func fetchForecast(for city: String) async throws -> [DailyForecast] {
        let encoded = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city
        let url = "\(baseURL)/forecast?q=\(encoded)&appid=\(apiKey)&units=metric&lang=pt_br&cnt=40"
        let dto: OpenWeatherForecastResponse = try await client.get(url)
        return ForecastMapper.map(dto)
    }

    // MARK: - Próximas horas (deriva da mesma previsão de 3h)

    func fetchHourly(for city: String) async throws -> [HourlyForecast] {
        let encoded = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city
        let url = "\(baseURL)/forecast?q=\(encoded)&appid=\(apiKey)&units=metric&lang=pt_br&cnt=8"
        let dto: OpenWeatherForecastResponse = try await client.get(url)
        return HourlyMapper.map(dto)
    }

    // MARK: - Qualidade do ar (Air Pollution API, por lat/lon)

    func fetchAirQuality(latitude: Double, longitude: Double) async throws -> AirQuality {
        let url = "\(baseURL)/air_pollution?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)"
        let dto: OpenWeatherAirPollutionResponse = try await client.get(url)
        guard let aq = AirQualityMapper.map(dto) else {
            throw NetworkError.decodingError(NetworkError.invalidURL)
        }
        return aq
    }

    // MARK: - Geocodificação (busca de cidades)

    func searchCities(query: String) async throws -> [String] {
        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return []
        }
        let url = "\(geoURL)/direct?q=\(encoded)&limit=10&appid=\(apiKey)"
        let dtos: [OpenWeatherGeocodingResult] = try await client.get(url, timeoutInterval: 8.0)
        return CityMapper.displayNames(dtos)
    }
}
