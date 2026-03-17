// filepath: ClimaAgora/ViewModels/WeatherViewModel.swift
import Foundation
import SwiftUICore
import Combine

// MARK: - WeatherViewModel (MVVM)
/// ViewModel principal do app. Gerencia estado do clima, previsões,
/// sugestões de IA e favoritos. Observável por todas as Views.

class WeatherViewModel: ObservableObject {
    
    // MARK: - Published State
    
    @Published var weather: Weather?
    @Published var forecast: [DailyForecast] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var temperatureUnit: TemperatureUnit = .celsius
    @Published var cityName: String = "São Paulo"
    @Published var clothingSuggestion: String?
    @Published var activitySuggestion: String?
    @Published var weatherAlert: String?
    @Published var iaResponse: String?
    @Published var dynamicActivities: String?
    @Published var isFavorite = false
    @Published var isLoadingIA = false
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    
    init() {
        print("🟢 [WeatherViewModel] Inicializado")
    }
    
    // MARK: - Enums
    
    enum TemperatureUnit: String {
        case celsius = "°C"
        case fahrenheit = "°F"
    }
    
    // MARK: - Conversão de Temperatura
    
    func convertTemperature(_ celsius: Double) -> Double {
        switch temperatureUnit {
        case .celsius:
            return celsius
        case .fahrenheit:
            return (celsius * 9/5) + 32
        }
    }
    
    // MARK: - Buscar Clima
    
    func fetchWeather() {
        isLoading = true
        errorMessage = nil
        
        WeatherService.shared.fetchWeather(for: cityName) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let result = result {
                    self?.weather = result
                    self?.isFavorite = FavoriteCitiesManager.shared.isFavorite(self?.cityName ?? "")
                    SearchHistoryManager.shared.addSearch(self?.cityName ?? "")
                    
                    if let _ = self?.weather {
                        self?.fetchClothingSuggestion()
                        self?.fetchActivitySuggestion()
                        self?.fetchWeatherAlert()
                    }
                } else {
                    self?.errorMessage = "Não foi possível obter o clima"
                }
            }
        }
        
        WeatherService.shared.fetchForecast(for: cityName) { [weak self] result in
            DispatchQueue.main.async {
                if let result = result {
                    self?.forecast = result
                }
            }
        }
    }
    
    // MARK: - Buscar Cidades
    
    func searchCities(_ query: String, completion: @escaping ([String]) -> Void) {
        WeatherService.shared.searchCities(query: query) { results in
            DispatchQueue.main.async {
                completion(results)
            }
        }
    }
    
    func loadWeather(for city: String) {
        cityName = city
        fetchWeather()
    }
    
    // MARK: - UI Helpers
    
    func getBackgroundGradient() -> [Color] {
        guard let weather = weather else {
            return [
                Color(red: 0.75, green: 0.85, blue: 1.0),
                Color(red: 0.85, green: 0.88, blue: 1.0),
                Color(red: 0.92, green: 0.90, blue: 1.0)
            ]
        }
        
        let condition = weather.condition.lowercased()
        let now = Date()
        let isNight = now < weather.sunrise || now > weather.sunset
        
        if isNight {
            return [
                Color(red: 0.15, green: 0.18, blue: 0.35),
                Color(red: 0.22, green: 0.25, blue: 0.48),
                Color(red: 0.30, green: 0.32, blue: 0.55)
            ]
        }
        
        switch condition {
        case "clear", "sunny":
            return [
                Color(red: 0.60, green: 0.80, blue: 1.0),
                Color(red: 0.72, green: 0.87, blue: 1.0),
                Color(red: 0.85, green: 0.92, blue: 1.0)
            ]
        case "cloudy", "overcast", "clouds":
            return [
                Color(red: 0.72, green: 0.78, blue: 0.88),
                Color(red: 0.80, green: 0.84, blue: 0.92),
                Color(red: 0.88, green: 0.90, blue: 0.95)
            ]
        case "rain", "drizzle", "rainy":
            return [
                Color(red: 0.55, green: 0.65, blue: 0.80),
                Color(red: 0.68, green: 0.75, blue: 0.88),
                Color(red: 0.78, green: 0.82, blue: 0.92)
            ]
        case "snow":
            return [
                Color(red: 0.80, green: 0.88, blue: 0.95),
                Color(red: 0.88, green: 0.92, blue: 0.98),
                Color(red: 0.94, green: 0.96, blue: 1.0)
            ]
        case "thunderstorm", "thunder":
            return [
                Color(red: 0.40, green: 0.42, blue: 0.58),
                Color(red: 0.52, green: 0.52, blue: 0.68),
                Color(red: 0.65, green: 0.62, blue: 0.75)
            ]
        default:
            return [
                Color(red: 0.65, green: 0.80, blue: 0.98),
                Color(red: 0.78, green: 0.88, blue: 1.0),
                Color(red: 0.88, green: 0.92, blue: 1.0)
            ]
        }
    }
    
    func getWeatherIcon() -> String {
        guard let weather = weather else { return "questionmark.circle.fill" }
        
        let condition = weather.condition.lowercased()
        switch condition {
        case "clear", "sunny": return "sun.max.fill"
        case "cloudy", "overcast", "clouds": return "cloud.fill"
        case "rain", "drizzle", "rainy": return "cloud.rain.fill"
        case "snow": return "snow"
        case "thunderstorm", "thunder": return "cloud.bolt.fill"
        default: return "cloud.fill"
        }
    }
    
    // MARK: - Sugestões Locais (Fallback)
    
    func getSuggestedClothing() -> String {
        guard let weather = weather else { return "" }
        let temp = weather.temperature
        
        if temp < 10 { return "🧥 Muito frio! Use casaco, gorro e luvas" }
        else if temp < 15 { return "🧥 Frio. Use jaqueta e casaco" }
        else if temp < 20 { return "👕 Use suéter ou jaqueta leve" }
        else if temp < 25 { return "👕 Camiseta e calça confortável" }
        else if temp < 30 { return "👕 Roupas leves e confortáveis" }
        else { return "👕 Roupas bem leves, shorts e camiseta" }
    }
    
    func getSuggestedActivity() -> String {
        guard let weather = weather else { return "" }
        let condition = weather.condition.lowercased()
        let temp = weather.temperature
        
        if condition.contains("rain") {
            return "☔ Dia perfeito para leitura, cinema ou atividades indoor!"
        } else if condition.contains("cloud") {
            return "🚶 Bom dia para uma caminhada tranquila"
        } else if condition.contains("clear") || condition.contains("sunny") {
            if temp > 20 && temp < 30 { return "🏃 Ótimo dia para correr ou fazer exercício!" }
            else if temp > 25 { return "🏊 Perfeito para nadar ou aproveitar a piscina!" }
        }
        return "📍 Aproveite o dia ao ar livre!"
    }
    
    // MARK: - Integração com IA (OpenAI)
    
    func fetchClothingSuggestion() {
        guard let weather = weather else { return }
        isLoadingIA = true
        IAService.shared.suggestClothing(weather: weather) { [weak self] result in
            DispatchQueue.main.async {
                self?.clothingSuggestion = result
                self?.isLoadingIA = false
            }
        }
    }
    
    func fetchActivitySuggestion() {
        guard let weather = weather else { return }
        isLoadingIA = true
        IAService.shared.suggestActivity(weather: weather) { [weak self] result in
            DispatchQueue.main.async {
                self?.activitySuggestion = result
                self?.isLoadingIA = false
            }
        }
    }
    
    func fetchWeatherAlert() {
        guard let weather = weather else { return }
        isLoadingIA = true
        IAService.shared.getWeatherAlert(weather: weather) { [weak self] result in
            DispatchQueue.main.async {
                self?.weatherAlert = result
                self?.isLoadingIA = false
            }
        }
    }
    
    func fetchWeatherExplanation() {
        guard let weather = weather else { return }
        isLoadingIA = true
        IAService.shared.explainWeather(weather: weather) { [weak self] result in
            DispatchQueue.main.async {
                self?.iaResponse = result
                self?.isLoadingIA = false
            }
        }
    }
    
    func generateAIRecommendation(for city: String, weather: Weather, completion: @escaping () -> Void) {
        isLoadingIA = true
        let simplified = CognitiveAccessibilityManager.shared.isSimplifiedMode
        
        IAService.shared.generateDetailedRecommendation(city: city, weather: weather, simplified: simplified) { [weak self] result in
            DispatchQueue.main.async {
                self?.iaResponse = result ?? "Não foi possível gerar a recomendação. Tente novamente."
                self?.isLoadingIA = false
                completion()
            }
        }
    }
    
    func fetchDynamicActivities(for city: String, weather: Weather) {
        isLoadingIA = true
        let simplified = CognitiveAccessibilityManager.shared.isSimplifiedMode
        
        IAService.shared.generateDynamicActivities(city: city, weather: weather, simplified: simplified) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoadingIA = false
                self?.dynamicActivities = result ?? "Atividades não disponíveis"
            }
        }
    }
    
    // MARK: - Favoritos
    
    func toggleFavorite() {
        if isFavorite {
            FavoriteCitiesManager.shared.removeFavorite(cityName)
        } else {
            FavoriteCitiesManager.shared.addFavorite(cityName)
        }
        isFavorite.toggle()
    }
}
