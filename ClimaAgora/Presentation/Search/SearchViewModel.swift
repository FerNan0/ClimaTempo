import Foundation

// MARK: - SearchViewModel
//
// Tela de busca no padrão v2 do handoff: além de buscar cidades, apresenta
// atalhos de descoberta — Recentes, Favoritas (com o clima atual) e uma lista
// curada "Quero visitar". Depende só de interfaces de use case.
// "Selecionar cidade" é a ação de rota desta tela (callback p/ a Home).

@MainActor
final class SearchViewModel: ObservableObject {

    // MARK: - Favorita com clima

    /// Cidade favorita + clima atual (carregado sob demanda; `temperature` fica
    /// `nil` enquanto a rede não responde).
    struct FavoriteWeather: Identifiable, Equatable {
        let id = UUID()
        let city: String
        var temperature: Int?
        var condition: String?
    }

    enum State: Equatable {
        case idle
        case loading
        case loaded
    }

    // MARK: - Estado publicado

    @Published private(set) var state: State = .idle
    @Published private(set) var searchResults: [String] = []
    @Published private(set) var recents: [String] = []
    @Published private(set) var favorites: [FavoriteWeather] = []

    /// Lista curada de destinos inspiracionais ("🧭 Quero visitar").
    /// Estática de propósito: é descoberta, não personalização.
    let wishlist = ["Gramado", "Fernando de Noronha", "Salvador", "Jericoacoara", "Bonito"]

    // MARK: - Dependências (interfaces injetadas pelo Router)

    private let searchUseCase: SearchCitiesUseCaseProtocol
    private let fetchWeatherUseCase: FetchWeatherUseCaseProtocol
    private let manageFavoritesUseCase: ManageFavoritesUseCaseProtocol
    private let onCitySelected: (String) -> Void
    private var favoritesTask: Task<Void, Never>?
    private var searchTask: Task<Void, Never>?
    private var currentSearchToken: UUID?

    init(
        searchUseCase: SearchCitiesUseCaseProtocol,
        fetchWeatherUseCase: FetchWeatherUseCaseProtocol,
        manageFavoritesUseCase: ManageFavoritesUseCaseProtocol,
        onCitySelected: @escaping (String) -> Void
    ) {
        self.searchUseCase = searchUseCase
        self.fetchWeatherUseCase = fetchWeatherUseCase
        self.manageFavoritesUseCase = manageFavoritesUseCase
        self.onCitySelected = onCitySelected
    }

    // MARK: - Ciclo de vida

    /// Carrega os atalhos (recentes + favoritas) ao abrir a tela.
    func onAppear() {
        recents = Array(SearchHistoryManager.shared.getSearchHistory().prefix(8))
        loadFavorites()
    }

    func onDisappear() {
        favoritesTask?.cancel()
        searchTask?.cancel()
    }

    private func loadFavorites() {
        favoritesTask?.cancel()
        let names = manageFavoritesUseCase.getAllFavorites()
        // Placeholder imediato (nome já aparece; a temperatura chega depois).
        favorites = names.map { FavoriteWeather(city: $0, temperature: nil, condition: nil) }

        favoritesTask = Task { [weak self] in
            guard let self else { return }
            for name in names {
                guard !Task.isCancelled else { return }
                guard let weather = try? await fetchWeatherUseCase.execute(.init(city: name)) else { continue }
                guard let idx = favorites.firstIndex(where: { $0.city == name }) else { continue }
                favorites[idx].temperature = Int(weather.temperature.rounded())
                favorites[idx].condition = weather.condition
            }
        }
    }

    // MARK: - Busca

    func search(_ query: String) {
        // Atalho de UX: nem dispara a Task com menos de 3 chars.
        // A regra "mínimo 3" mora no SearchCitiesUseCase (fonte da verdade).
        guard query.count >= 3 else {
            currentSearchToken = nil
            searchTask?.cancel()
            searchResults = []
            state = .idle
            return
        }
        state = .loading
        let token = UUID()
        currentSearchToken = token
        searchTask?.cancel()
        searchTask = Task { [weak self] in
            guard let self else { return }
            let result = (try? await searchUseCase.execute(.init(query: query))) ?? []
            guard !Task.isCancelled, currentSearchToken == token else { return }
            searchResults = result
            state = .loaded
        }
    }

    func selectCity(_ city: String) {
        onCitySelected(city)
    }
}
