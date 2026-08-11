//
//  UseCaseMocks.swift
//  ClimaAgoraTests
//
//  Test doubles das interfaces de use case.
//  Existem PORQUE a ViewModel depende de protocolos (não de classes concretas):
//  é isso que torna a camada de apresentação testável sem rede nem IA real.
//

import Foundation
@testable import ClimaAgora

final class MockFetchWeatherUseCase: FetchWeatherUseCaseProtocol {
    var result: Result<Weather, Error> = .success(.preview)
    private(set) var receivedCity: String?

    func execute(_ request: FetchWeatherRequest) async throws -> Weather {
        receivedCity = request.city
        return try result.get()
    }
}

final class MockFetchForecastUseCase: FetchForecastUseCaseProtocol {
    var result: [DailyForecast] = []
    func execute(_ request: FetchForecastRequest) async throws -> [DailyForecast] { result }
}

final class MockFetchAIUseCase: FetchAIRecommendationsUseCaseProtocol {
    func suggestClothing(weather: Weather) async -> String? { "👕 teste" }
    func suggestActivity(weather: Weather) async -> String? { "🎯 teste" }
    func getWeatherAlert(weather: Weather) async -> String? { "OK" }
    func generateRecommendation(_ request: AIRecommendationRequest) async -> String? { "recomendação" }
    func generateActivities(_ request: AIRecommendationRequest) async -> String? { "atividades" }
}

final class MockManageFavoritesUseCase: ManageFavoritesUseCaseProtocol {
    var favorites: Set<String> = []
    func isFavorite(_ city: String) -> Bool { favorites.contains(city) }
    func toggle(_ city: String) {
        if favorites.contains(city) { favorites.remove(city) } else { favorites.insert(city) }
    }
    func getAllFavorites() -> [String] { Array(favorites) }
}
