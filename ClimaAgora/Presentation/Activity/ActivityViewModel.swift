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
    private var currentLoadToken: UUID?
    private var currentRefreshToken: UUID?

    init(viewData: ActivityViewData, fetchAIUseCase: FetchAIRecommendationsUseCaseProtocol) {
        self.viewData = viewData
        self.fetchAIUseCase = fetchAIUseCase
    }

    func loadAll() {
        loadAllTask?.cancel()
        refreshTask?.cancel()
        let token = UUID()
        currentLoadToken = token
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

            let recResult = await rec
            let activitiesResult = await activities
            let structuredResult = await structured
            let clothingResult = await clothing
            let activityResult = await activity
            let alertResult = await alert
            guard !Task.isCancelled, currentLoadToken == token else { return }
            iaResponse           = recResult
            dynamicActivities    = activitiesResult
            structuredActivities = structuredResult
            clothingSuggestion   = clothingResult
            activitySuggestion   = activityResult
            weatherAlert         = alertResult
            state = .loaded
        }
    }

    func refreshActivities() {
        refreshTask?.cancel()
        let token = UUID()
        currentRefreshToken = token
        let request = AIRecommendationRequest(
            city: city,
            weather: weather,
            simplified: CognitiveAccessibilityManager.shared.isSimplifiedMode
        )
        refreshTask = Task { [weak self] in
            guard let self else { return }
            async let structured = fetchAIUseCase.generateStructuredActivities(request)
            async let text       = fetchAIUseCase.generateActivities(request)
            let structuredResult = await structured
            let textResult = await text
            guard !Task.isCancelled, currentRefreshToken == token else { return }
            structuredActivities = structuredResult
            dynamicActivities    = textResult
        }
    }

    func onDisappear() {
        loadAllTask?.cancel()
        refreshTask?.cancel()
    }
}
