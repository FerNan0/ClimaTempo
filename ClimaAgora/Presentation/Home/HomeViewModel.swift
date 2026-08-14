import Foundation
import SwiftUI

// MARK: - TemperatureUnit

enum TemperatureUnit: String {
    case celsius    = "°C"
    case fahrenheit = "°F"
}

// MARK: - HomeViewModel
//
// ViewModel da tela de entrada (padrão do guia: State + RouteEvent).
// - Depende SÓ de interfaces de use case (nunca de classe concreta nem de API).
// - Publica `state` (ciclo de vida da tela) e `route` (evento de navegação).
// - NÃO navega: só emite o evento; quem escuta e chama o Router é a View.

@MainActor
final class HomeViewModel: ObservableObject {

    // MARK: - State (ciclo de vida da tela)

    enum State: Equatable {
        case idle
        case loading
        case loaded
        case failed(String)
    }

    // MARK: - RouteEvent (intenções de navegação)

    enum Route: Identifiable, Equatable {
        case search
        case settings
        case activity
        case share

        var id: Int { hashValue }
    }

    // MARK: - Estado publicado

    @Published private(set) var state: State = .idle
    @Published var route: Route?

    @Published private(set) var weather: Weather?
    @Published private(set) var forecast: [DailyForecast] = []
    @Published private(set) var hourly: [HourlyForecast] = []
    @Published private(set) var airQuality: AirQuality?
    @Published var forecastPeriod: ForecastPeriod = .sevenDays
    @Published private(set) var clothingSuggestion: String?
    @Published private(set) var activitySuggestion: String?
    /// Conselho em linguagem simples para o modo simples full-screen (on-device).
    @Published private(set) var simplifiedAdvice: SimplifiedAdvice?
    @Published private(set) var isLoadingIA = false
    @Published private(set) var isFavorite = false

    /// Dias visíveis conforme o período selecionado (limitado ao disponível na API).
    var visibleForecast: [DailyForecast] {
        Array(forecast.prefix(forecastPeriod.days))
    }

    /// Resumo agregado do período visível (média máx/mín, dias de chuva).
    var forecastSummary: ForecastSummary {
        ForecastSummary.from(visibleForecast)
    }

    /// Avisos de risco do tempo (determinístico, on-device). Vazio = sem risco.
    var weatherRisks: [WeatherRisk] {
        guard let weather else { return [] }
        return WeatherRiskAssessor.assess(weather: weather, forecast: forecast)
    }

    @Published var cityName = "São Paulo"
    @Published var temperatureUnit: TemperatureUnit = .celsius

    // MARK: - Dependências (interfaces injetadas pelo Router)

    private let fetchWeatherUseCase: FetchWeatherUseCaseProtocol
    private let fetchForecastUseCase: FetchForecastUseCaseProtocol
    private let fetchHourlyUseCase: FetchHourlyForecastUseCaseProtocol
    private let fetchAirQualityUseCase: FetchAirQualityUseCaseProtocol
    private let fetchAIUseCase: FetchAIRecommendationsUseCaseProtocol
    private let manageFavoritesUseCase: ManageFavoritesUseCaseProtocol

    init(
        fetchWeatherUseCase: FetchWeatherUseCaseProtocol,
        fetchForecastUseCase: FetchForecastUseCaseProtocol,
        fetchHourlyUseCase: FetchHourlyForecastUseCaseProtocol,
        fetchAirQualityUseCase: FetchAirQualityUseCaseProtocol,
        fetchAIUseCase: FetchAIRecommendationsUseCaseProtocol,
        manageFavoritesUseCase: ManageFavoritesUseCaseProtocol
    ) {
        self.fetchWeatherUseCase     = fetchWeatherUseCase
        self.fetchForecastUseCase    = fetchForecastUseCase
        self.fetchHourlyUseCase      = fetchHourlyUseCase
        self.fetchAirQualityUseCase  = fetchAirQualityUseCase
        self.fetchAIUseCase          = fetchAIUseCase
        self.manageFavoritesUseCase  = manageFavoritesUseCase
    }

    // MARK: - Ciclo de vida

    /// Ponto de entrada (padrão do guia: `start`).
    func start() {
        loadWeather(for: cityName)
    }

    func loadWeather(for city: String) {
        cityName = city
        state = .loading

        Task {
            async let weatherTask  = fetchWeatherUseCase.execute(.init(city: city))
            async let forecastTask = fetchForecastUseCase.execute(.init(city: city))
            async let hourlyTask   = fetchHourlyUseCase.execute(.init(city: city))

            do {
                let result = try await weatherTask
                weather = result
                isFavorite = manageFavoritesUseCase.isFavorite(city)
                SearchHistoryManager.shared.addSearch(city)
                forecast = (try? await forecastTask) ?? []
                hourly   = (try? await hourlyTask) ?? []
                // Qualidade do ar depende das coordenadas do clima recém-obtido.
                if result.latitude != 0 || result.longitude != 0 {
                    airQuality = try? await fetchAirQualityUseCase.execute(
                        .init(latitude: result.latitude, longitude: result.longitude)
                    )
                }
                state = .loaded
                // Sinal de SUCESSO para o motor de adaptação (interação fluente
                // reduz a carga cognitiva estimada).
                AdaptiveEngine.shared.registerTaskCompleted(on: "Home")
                fetchAISuggestions(for: result)
            } catch {
                // Loga o erro REAL no console (HTTP 401 = chave inválida, 404 = cidade, etc.)
                print("❌ [HomeViewModel] Falha ao buscar clima para \(city): \(error)")
                state = .failed("Não foi possível obter o clima")
                // Sinal de ERRO para o motor de adaptação.
                AdaptiveEngine.shared.registerError(on: "Home")
            }
        }
    }

    // MARK: - Eventos de navegação (apenas setam o route)

    func didTapSearch()   { route = .search }
    func didTapSettings() { route = .settings }
    func didTapShare()    { route = .share }
    func didTapSeeMore()  { route = .activity }

    // MARK: - Ações da tela

    func toggleFavorite() {
        manageFavoritesUseCase.toggle(cityName)
        isFavorite.toggle()
    }

    func refreshActivitySuggestion() {
        guard let weather else { return }
        isLoadingIA = true
        Task {
            activitySuggestion = await fetchAIUseCase.suggestActivity(weather: weather)
            isLoadingIA = false
        }
    }

    // MARK: - Helpers de apresentação

    func convertTemperature(_ celsius: Double) -> Double {
        switch temperatureUnit {
        case .celsius:    return celsius
        case .fahrenheit: return (celsius * 9 / 5) + 32
        }
    }

    func getBackgroundGradient() -> [Color] { WeatherAppearance.backgroundGradient(for: weather) }
    func getWeatherIcon() -> String { WeatherAppearance.icon(for: weather) }

    // MARK: - Privado

    private func fetchAISuggestions(for weather: Weather) {
        isLoadingIA = true
        Task {
            async let clothing = fetchAIUseCase.suggestClothing(weather: weather)
            async let activity = fetchAIUseCase.suggestActivity(weather: weather)
            async let advice   = fetchAIUseCase.generateSimplifiedAdvice(weather: weather)
            clothingSuggestion = await clothing
            activitySuggestion = await activity
            // Conselho simples on-device; se indisponível, usa o fallback determinístico.
            simplifiedAdvice = await advice ?? SimplifiedAdvice.fallback(for: weather)
            isLoadingIA = false
        }
    }
}
