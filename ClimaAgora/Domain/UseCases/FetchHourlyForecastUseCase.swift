import Foundation

// MARK: - Request

struct FetchHourlyForecastRequest {
    let city: String
}

// MARK: - Interface

protocol FetchHourlyForecastUseCaseProtocol {
    func execute(_ request: FetchHourlyForecastRequest) async throws -> [HourlyForecast]
}

// MARK: - Implementação

final class FetchHourlyForecastUseCase: FetchHourlyForecastUseCaseProtocol {
    private let repository: WeatherRepositoryProtocol

    init(repository: WeatherRepositoryProtocol) {
        self.repository = repository
    }

    func execute(_ request: FetchHourlyForecastRequest) async throws -> [HourlyForecast] {
        try await repository.fetchHourly(for: request.city)
    }
}
