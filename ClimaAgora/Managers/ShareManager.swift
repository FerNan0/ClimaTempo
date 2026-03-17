import SwiftUI

class ShareManager {
    static let shared = ShareManager()
    
    private init() {}
    
    // MARK: - Gerar Texto para Compartilhar
    func generateShareText(for weather: Weather) -> String {
        let temp: Int = Int(weather.temperature)
        let emoji: String = getWeatherEmoji(condition: weather.condition)
        
        return """
        🌍 ClimaAgora - Compartilhe o Clima
        
        \(emoji) \(weather.city)
        Temperatura: \(temp)°C
        Condição: \(weather.description.capitalized)
        Sensação: \(Int(weather.feelsLike))°C
        Umidade: \(weather.humidity)%
        Vento: \(String(format: "%.1f", weather.windSpeed)) km/h
        Visibilidade: \(weather.visibility / 1000) km
        
        Baixe o ClimaAgora para previsões inteligentes!
        """
    }
    
    // MARK: - Gerar Emoji do Clima
    private func getWeatherEmoji(condition: String) -> String {
        let cond = condition.lowercased()
        
        switch cond {
        case "clear", "sunny":
            return "☀️"
        case "cloudy", "overcast", "clouds":
            return "☁️"
        case "rain", "drizzle", "rainy":
            return "🌧️"
        case "snow":
            return "❄️"
        case "thunderstorm", "thunder":
            return "⛈️"
        default:
            return "🌤️"
        }
    }
    
    // MARK: - Criar URL para Compartilhar
    func createShareURL(for weather: Weather) -> URL? {
        let text: String = generateShareText(for: weather)
        let encoded: String = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        // WhatsApp
        let whatsappURL = URL(string: "https://wa.me/?text=\(encoded)")
        
        return whatsappURL
    }
}
