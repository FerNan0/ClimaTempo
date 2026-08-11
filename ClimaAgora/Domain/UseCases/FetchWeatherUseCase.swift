import Foundation

// MARK: - Request (entrada do caso de uso)

struct FetchWeatherRequest {
    let city: String
}

// MARK: - Interface (contrato — a ViewModel depende DISTO, não da classe)

protocol FetchWeatherUseCaseProtocol {
    func execute(_ request: FetchWeatherRequest) async throws -> Weather
}

// MARK: - Implementação

final class FetchWeatherUseCase: FetchWeatherUseCaseProtocol {
    private let repository: WeatherRepositoryProtocol

    init(repository: WeatherRepositoryProtocol) {
        self.repository = repository
    }

    func execute(_ request: FetchWeatherRequest) async throws -> Weather {
        try await repository.fetchWeather(for: request.city)
    }
}
