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
    /// Atividades estruturadas (Guided Generation on-device). Quando presentes,
    /// a UI as renderiza sem parsing de string. `nil` → usa `dynamicActivities`.
    @Published private(set) var structuredActivities: [StructuredActivity]?
    @Published private(set) var clothingSuggestion: String?
    @Published private(set) var activitySuggestion: String?
    @Published private(set) var weatherAlert: String?

    let viewData: ActivityViewData
    var city: String { viewData.city }
    var weather: Weather { viewData.weather }

    private let fetchAIUseCase: FetchAIRecommendationsUseCaseProtocol
    private var loadAllTask: Task<Void, Never>?
    private var refreshTask: Task<Void, Never>?

    init(viewData: ActivityViewData, fetchAIUseCase: FetchAIRecommendationsUseCaseProtocol) {
        self.viewData = viewData
        self.fetchAIUseCase = fetchAIUseCase
    }

    func loadAll() {
        loadAllTask?.cancel()
        refreshTask?.cancel()
        state = .loading
        let request = AIRecommendationRequest(
            city: city,
            weather: weather,
            simplified: CognitiveAccessibilityManager.shared.isSimplifiedMode
        )

        loadAllTask = Task { [weak self] in
            guard let self else { return }
            async let rec        = fetchAIUseCase.generateRecommendation(request)
            async let activities = fetchAIUseCase.generateActivities(request)
            async let structured = fetchAIUseCase.generateStructuredActivities(request)
            async let clothing   = fetchAIUseCase.suggestClothing(weather: weather)
            async let activity   = fetchAIUseCase.suggestActivity(weather: weather)
            async let alert      = fetchAIUseCase.getWeatherAlert(weather: weather)

            guard !Task.isCancelled else { return }
            iaResponse           = await rec
            dynamicActivities    = await activities
            structuredActivities = await structured
            clothingSuggestion   = await clothing
            activitySuggestion   = await activity
            weatherAlert         = await alert
            guard !Task.isCancelled else { return }
            state = .loaded
        }
    }

    func refreshActivities() {
        refreshTask?.cancel()
        let request = AIRecommendationRequest(
            city: city,
            weather: weather,
            simplified: CognitiveAccessibilityManager.shared.isSimplifiedMode
        )
        refreshTask = Task { [weak self] in
            guard let self else { return }
            async let structured = fetchAIUseCase.generateStructuredActivities(request)
            async let text       = fetchAIUseCase.generateActivities(request)
            structuredActivities = await structured
            dynamicActivities    = await text
        }
    }

    func onDisappear() {
        loadAllTask?.cancel()
        refreshTask?.cancel()
    }
}
