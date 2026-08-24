//
//  RepositoryMocks.swift
//  ClimaAgoraTests
//
//  Test doubles das interfaces de REPOSITÓRIO (uma camada abaixo dos use
//  cases). Existem para testar use cases isoladamente — sem rede real.
//

import Foundation
@testable import ClimaAgora

final class MockWeatherRepository: WeatherRepositoryProtocol {
    var weatherResult: Result<Weather, Error> = .success(.preview)
    var forecastResult: [DailyForecast] = []
    var hourlyResult: [HourlyForecast] = []
    var airQualityResult: AirQuality = .preview
    var searchResult: [String] = []
    private(set) var receivedSearchQuery: String?

    func fetchWeather(for city: String) async throws -> Weather { try weatherResult.get() }
    func fetchForecast(for city: String) async throws -> [DailyForecast] { forecastResult }
    func fetchHourly(for city: String) async throws -> [HourlyForecast] { hourlyResult }
    func fetchAirQuality(latitude: Double, longitude: Double) async throws -> AirQuality { airQualityResult }
    func searchCities(query: String) async throws -> [String] {
        receivedSearchQuery = query
        return searchResult
    }
}

final class MockFavoritesRepository: FavoritesRepositoryProtocol {
    private var favorites: Set<String> = []

    func isFavorite(_ city: String) -> Bool { favorites.contains(city) }
    func addFavorite(_ city: String) { favorites.insert(city) }
    func removeFavorite(_ city: String) { favorites.remove(city) }
    func getAllFavorites() -> [String] { Array(favorites) }
}
