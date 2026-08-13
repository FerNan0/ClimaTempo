import Foundation

// MARK: - Request

struct FetchAirQualityRequest {
    let latitude: Double
    let longitude: Double
}

// MARK: - Interface

protocol FetchAirQualityUseCaseProtocol {
    func execute(_ request: FetchAirQualityRequest) async throws -> AirQuality
}

// MARK: - Implementação

final class FetchAirQualityUseCase: FetchAirQualityUseCaseProtocol {
    private let repository: WeatherRepositoryProtocol

    init(repository: WeatherRepositoryProtocol) {
        self.repository = repository
    }

    func execute(_ request: FetchAirQualityRequest) async throws -> AirQuality {
        try await repository.fetchAirQuality(latitude: request.latitude, longitude: request.longitude)
    }
}
