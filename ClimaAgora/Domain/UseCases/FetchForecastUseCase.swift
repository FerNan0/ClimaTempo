import Foundation

// MARK: - Request

struct FetchForecastRequest {
    let city: String
}

// MARK: - Interface

protocol FetchForecastUseCaseProtocol {
    func execute(_ request: FetchForecastRequest) async throws -> [DailyForecast]
}

// MARK: - Implementação

final class FetchForecastUseCase: FetchForecastUseCaseProtocol {
    private let repository: WeatherRepositoryProtocol

    init(repository: WeatherRepositoryProtocol) {
        self.repository = repository
    }

    func execute(_ request: FetchForecastRequest) async throws -> [DailyForecast] {
        try await repository.fetchForecast(for: request.city)
    }
}
