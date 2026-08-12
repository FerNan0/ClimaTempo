//
//  HomeViewModelTests.swift
//  ClimaAgoraTests
//
//  Teste de ViewModel (ação → routeEvent / state) — item do checklist do guia.
//  Usa mocks das interfaces de use case (sem rede, sem IA real).
//

import Testing
@testable import ClimaAgora

@MainActor
struct HomeViewModelTests {

    private func makeSUT(
        favorites: MockManageFavoritesUseCase = MockManageFavoritesUseCase()
    ) -> HomeViewModel {
        HomeViewModel(
            fetchWeatherUseCase:    MockFetchWeatherUseCase(),
            fetchForecastUseCase:   MockFetchForecastUseCase(),
            fetchAIUseCase:         MockFetchAIUseCase(),
            manageFavoritesUseCase: favorites
        )
    }

    // MARK: - RouteEvent

    @Test func tapSearch_emitsSearchRoute() {
        let sut = makeSUT()
        sut.didTapSearch()
        #expect(sut.route == .search)
    }

    @Test func tapSettings_emitsSettingsRoute() {
        let sut = makeSUT()
        sut.didTapSettings()
        #expect(sut.route == .settings)
    }

    @Test func tapSeeMore_emitsActivityRoute() {
        let sut = makeSUT()
        sut.didTapSeeMore()
        #expect(sut.route == .activity)
    }

    @Test func tapShare_emitsShareRoute() {
        let sut = makeSUT()
        sut.didTapShare()
        #expect(sut.route == .share)
    }

    // MARK: - State inicial

    @Test func startsInIdleState() {
        let sut = makeSUT()
        #expect(sut.state == .idle)
    }

    // MARK: - Favoritos

    @Test func toggleFavorite_flipsAndPersists() {
        let favorites = MockManageFavoritesUseCase()
        let sut = makeSUT(favorites: favorites)
        sut.cityName = "Rio de Janeiro"

        #expect(sut.isFavorite == false)

        sut.toggleFavorite()

        #expect(sut.isFavorite == true)
        #expect(favorites.isFavorite("Rio de Janeiro") == true)
    }
}
