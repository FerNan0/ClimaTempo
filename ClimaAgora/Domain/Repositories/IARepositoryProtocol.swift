import Foundation

protocol IARepositoryProtocol {
    func suggestClothing(weather: Weather) async -> String?
    func suggestActivity(weather: Weather) async -> String?
    func getWeatherAlert(weather: Weather) async -> String?
    func explainWeather(weather: Weather) async -> String?
    func generateDetailedRecommendation(city: String, weather: Weather, simplified: Bool) async -> String?
    func generateDynamicActivities(city: String, weather: Weather, simplified: Bool) async -> String?
    /// Atividades já estruturadas (Guided Generation, on-device). `nil` = indisponível
    /// → o chamador cai no caminho de texto (`generateDynamicActivities`).
    func generateStructuredActivities(city: String, weather: Weather, simplified: Bool) async -> [StructuredActivity]?
    /// Conselho de clima em linguagem simples (Guided Generation, on-device). `nil` =
    /// indisponível → o chamador usa `SimplifiedAdvice.fallback(for:)`.
    func generateSimplifiedAdvice(weather: Weather) async -> SimplifiedAdvice?
}
