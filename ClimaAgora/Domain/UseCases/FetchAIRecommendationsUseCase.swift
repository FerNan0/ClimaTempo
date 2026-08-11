import Foundation

// MARK: - Request

/// Entrada das recomendações longas (recomendação detalhada / atividades).
/// `simplified` reflete o modo de acessibilidade cognitiva ativo.
struct AIRecommendationRequest {
    let city: String
    let weather: Weather
    let simplified: Bool
}

// MARK: - Interface

/// Fachada de IA. Diferente dos demais use cases (1 execute), aqui há várias
/// operações porque todas compartilham o mesmo provider/roteamento (on-device → nuvem).
protocol FetchAIRecommendationsUseCaseProtocol {
    func suggestClothing(weather: Weather) async -> String?
    func suggestActivity(weather: Weather) async -> String?
    func getWeatherAlert(weather: Weather) async -> String?
    func generateRecommendation(_ request: AIRecommendationRequest) async -> String?
    func generateActivities(_ request: AIRecommendationRequest) async -> String?
}

// MARK: - Implementação

final class FetchAIRecommendationsUseCase: FetchAIRecommendationsUseCaseProtocol {
    private let repository: IARepositoryProtocol

    init(repository: IARepositoryProtocol) {
        self.repository = repository
    }

    func suggestClothing(weather: Weather) async -> String? {
        await repository.suggestClothing(weather: weather)
    }

    func suggestActivity(weather: Weather) async -> String? {
        await repository.suggestActivity(weather: weather)
    }

    func getWeatherAlert(weather: Weather) async -> String? {
        await repository.getWeatherAlert(weather: weather)
    }

    func generateRecommendation(_ request: AIRecommendationRequest) async -> String? {
        await repository.generateDetailedRecommendation(
            city: request.city, weather: request.weather, simplified: request.simplified
        )
    }

    func generateActivities(_ request: AIRecommendationRequest) async -> String? {
        await repository.generateDynamicActivities(
            city: request.city, weather: request.weather, simplified: request.simplified
        )
    }
}
