import Foundation

protocol IARepositoryProtocol {
    func suggestClothing(weather: Weather) async -> String?
    func suggestActivity(weather: Weather) async -> String?
    func getWeatherAlert(weather: Weather) async -> String?
    func explainWeather(weather: Weather) async -> String?
    func generateDetailedRecommendation(city: String, weather: Weather, simplified: Bool) async -> String?
    func generateDynamicActivities(city: String, weather: Weather, simplified: Bool) async -> String?
}
