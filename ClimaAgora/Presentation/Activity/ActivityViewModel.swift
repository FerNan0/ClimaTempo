import Foundation

// MARK: - ActivityViewData
// O "ViewData" da próxima tela (padrão do guia): dado pronto que o Router injeta.

struct ActivityViewData {
    let city: String
    let weather: Weather
}

// MARK: - ActivityViewModel
// ViewModel da "próxima tela": recebe seu ViewData no init e carrega o conteúdo.
// Depende da interface FetchAIRecommendationsUseCaseProtocol.

@MainActor
final class ActivityViewModel: ObservableObject {

    enum State: Equatable {
        case idle
        case loading
        case loaded
    }

    @Published private(set) var state: State = .idle
    @Published private(set) var iaResponse: String?
    @Published private(set) var dynamicActivities: String?
    @Published private(set) var clothingSuggestion: String?
    @Published private(set) var activitySuggestion: String?
    @Published private(set) var weatherAlert: String?

    let viewData: ActivityViewData
    var city: String { viewData.city }
    var weather: Weather { viewData.weather }

    private let fetchAIUseCase: FetchAIRecommendationsUseCaseProtocol

    init(viewData: ActivityViewData, fetchAIUseCase: FetchAIRecommendationsUseCaseProtocol) {
        self.viewData = viewData
        self.fetchAIUseCase = fetchAIUseCase
    }

    func loadAll() {
        state = .loading
        let request = AIRecommendationRequest(
            city: city,
            weather: weather,
            simplified: CognitiveAccessibilityManager.shared.isSimplifiedMode
        )

        Task {
            async let rec        = fetchAIUseCase.generateRecommendation(request)
            async let activities = fetchAIUseCase.generateActivities(request)
            async let clothing   = fetchAIUseCase.suggestClothing(weather: weather)
            async let activity   = fetchAIUseCase.suggestActivity(weather: weather)
            async let alert      = fetchAIUseCase.getWeatherAlert(weather: weather)

            iaResponse         = await rec
            dynamicActivities  = await activities
            clothingSuggestion = await clothing
            activitySuggestion = await activity
            weatherAlert       = await alert
            state = .loaded
        }
    }

    func refreshActivities() {
        let request = AIRecommendationRequest(
            city: city,
            weather: weather,
            simplified: CognitiveAccessibilityManager.shared.isSimplifiedMode
        )
        Task {
            dynamicActivities = await fetchAIUseCase.generateActivities(request)
        }
    }
}
