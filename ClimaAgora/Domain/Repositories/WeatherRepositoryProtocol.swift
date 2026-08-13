import Foundation

protocol WeatherRepositoryProtocol {
    func fetchWeather(for city: String) async throws -> Weather
    func fetchForecast(for city: String) async throws -> [DailyForecast]
    func fetchHourly(for city: String) async throws -> [HourlyForecast]
    func fetchAirQuality(latitude: Double, longitude: Double) async throws -> AirQuality
    func searchCities(query: String) async throws -> [String]
}
