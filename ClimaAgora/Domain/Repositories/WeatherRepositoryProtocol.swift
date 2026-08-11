import Foundation

protocol WeatherRepositoryProtocol {
    func fetchWeather(for city: String) async throws -> Weather
    func fetchForecast(for city: String) async throws -> [DailyForecast]
    func searchCities(query: String) async throws -> [String]
}
