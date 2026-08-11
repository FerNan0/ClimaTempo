import Foundation

// MARK: - AppRouting (contrato de navegação — equivale ao EntryRouting do guia)
//
// A View escuta o `route` da ViewModel e pede ao Router para montar a próxima tela.
// A ViewModel NUNCA conhece o Router; só publica o evento.

@MainActor
protocol AppRouting {
    func makeSearchViewModel(onCitySelected: @escaping (String) -> Void) -> SearchViewModel
    func makeActivityViewModel(viewData: ActivityViewData) -> ActivityViewModel
}

// MARK: - RouterManager (Composition Root — equivale ao MainRouterManager do guia)
//
// Único lugar que conhece implementações CONCRETAS.
// Monta o grafo (repositórios → use cases) uma vez e fabrica as ViewModels.
// Trocar API/persistência = mudar só as linhas de repositório aqui.

@MainActor
final class RouterManager: ObservableObject, AppRouting {

    // Repositórios (implementações concretas dos contratos do Domain)
    private let weatherRepository: WeatherRepositoryProtocol
    private let iaRepository: IARepositoryProtocol
    private let favoritesRepository: FavoritesRepositoryProtocol

    // Use cases (já como interfaces — é assim que as ViewModels os recebem)
    private let fetchWeather: FetchWeatherUseCaseProtocol
    private let fetchForecast: FetchForecastUseCaseProtocol
    private let searchCities: SearchCitiesUseCaseProtocol
    private let fetchAI: FetchAIRecommendationsUseCaseProtocol
    private let manageFavorites: ManageFavoritesUseCaseProtocol

    init() {
        let client = NetworkClient()
        weatherRepository   = WeatherRepository(client: client)
        iaRepository        = IARepository(client: client)
        favoritesRepository = FavoritesRepository()

        fetchWeather    = FetchWeatherUseCase(repository: weatherRepository)
        fetchForecast   = FetchForecastUseCase(repository: weatherRepository)
        searchCities    = SearchCitiesUseCase(repository: weatherRepository)
        fetchAI         = FetchAIRecommendationsUseCase(repository: iaRepository)
        manageFavorites = ManageFavoritesUseCase(repository: favoritesRepository)
    }

    // MARK: - Fábricas de ViewModel

    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            fetchWeatherUseCase:    fetchWeather,
            fetchForecastUseCase:   fetchForecast,
            fetchAIUseCase:         fetchAI,
            manageFavoritesUseCase: manageFavorites
        )
    }

    func makeSearchViewModel(onCitySelected: @escaping (String) -> Void) -> SearchViewModel {
        SearchViewModel(useCase: searchCities, onCitySelected: onCitySelected)
    }

    func makeActivityViewModel(viewData: ActivityViewData) -> ActivityViewModel {
        ActivityViewModel(viewData: viewData, fetchAIUseCase: fetchAI)
    }
}
