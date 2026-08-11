import Foundation

// MARK: - Request

struct SearchCitiesRequest {
    let query: String
}

// MARK: - Interface

protocol SearchCitiesUseCaseProtocol {
    func execute(_ request: SearchCitiesRequest) async throws -> [String]
}

// MARK: - Implementação

final class SearchCitiesUseCase: SearchCitiesUseCaseProtocol {
    private let repository: WeatherRepositoryProtocol

    init(repository: WeatherRepositoryProtocol) {
        self.repository = repository
    }

    func execute(_ request: SearchCitiesRequest) async throws -> [String] {
        // Regra de negócio (fonte da verdade): busca só a partir de 3 caracteres.
        guard request.query.count >= 3 else { return [] }
        return try await repository.searchCities(query: request.query)
    }
}
