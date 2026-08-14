import Foundation

// MARK: - FetchOfficialAlertsUseCase (Request + Interface + Impl)

struct FetchOfficialAlertsRequest {
    let latitude: Double
    let longitude: Double
}

protocol FetchOfficialAlertsUseCaseProtocol {
    func execute(_ request: FetchOfficialAlertsRequest) async throws -> [OfficialAlert]
}

final class FetchOfficialAlertsUseCase: FetchOfficialAlertsUseCaseProtocol {
    private let repository: AlertsRepositoryProtocol

    init(repository: AlertsRepositoryProtocol) {
        self.repository = repository
    }

    func execute(_ request: FetchOfficialAlertsRequest) async throws -> [OfficialAlert] {
        try await repository.fetchActiveAlerts(latitude: request.latitude, longitude: request.longitude)
    }
}
