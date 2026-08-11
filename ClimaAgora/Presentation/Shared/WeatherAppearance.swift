import SwiftUI

// MARK: - Utilitários de aparência (gradiente + ícone)
// Extraído do WeatherViewModel para manter ViewModels sem dependência de SwiftUI.

enum WeatherAppearance {
    static func backgroundGradient(for weather: Weather?) -> [Color] {
        guard let weather else {
            return [
                Color(red: 0.75, green: 0.85, blue: 1.0),
                Color(red: 0.85, green: 0.88, blue: 1.0),
                Color(red: 0.92, green: 0.90, blue: 1.0)
            ]
        }

        let condition = weather.condition.lowercased()
        let isNight = Date() < weather.sunrise || Date() > weather.sunset

        if isNight {
            return [
                Color(red: 0.15, green: 0.18, blue: 0.35),
                Color(red: 0.22, green: 0.25, blue: 0.48),
                Color(red: 0.30, green: 0.32, blue: 0.55)
            ]
        }

        switch condition {
        case "clear", "sunny":
            return [Color(red: 0.60, green: 0.80, blue: 1.0),
                    Color(red: 0.72, green: 0.87, blue: 1.0),
                    Color(red: 0.85, green: 0.92, blue: 1.0)]
        case "cloudy", "overcast", "clouds":
            return [Color(red: 0.72, green: 0.78, blue: 0.88),
                    Color(red: 0.80, green: 0.84, blue: 0.92),
                    Color(red: 0.88, green: 0.90, blue: 0.95)]
        case "rain", "drizzle", "rainy":
            return [Color(red: 0.55, green: 0.65, blue: 0.80),
                    Color(red: 0.68, green: 0.75, blue: 0.88),
                    Color(red: 0.78, green: 0.82, blue: 0.92)]
        case "snow":
            return [Color(red: 0.80, green: 0.88, blue: 0.95),
                    Color(red: 0.88, green: 0.92, blue: 0.98),
                    Color(red: 0.94, green: 0.96, blue: 1.0)]
        case "thunderstorm", "thunder":
            return [Color(red: 0.40, green: 0.42, blue: 0.58),
                    Color(red: 0.52, green: 0.52, blue: 0.68),
                    Color(red: 0.65, green: 0.62, blue: 0.75)]
        default:
            return [Color(red: 0.65, green: 0.80, blue: 0.98),
                    Color(red: 0.78, green: 0.88, blue: 1.0),
                    Color(red: 0.88, green: 0.92, blue: 1.0)]
        }
    }

    static func icon(for weather: Weather?) -> String {
        guard let weather else { return "questionmark.circle.fill" }
        switch weather.condition.lowercased() {
        case "clear", "sunny":             return "sun.max.fill"
        case "cloudy", "overcast", "clouds": return "cloud.fill"
        case "rain", "drizzle", "rainy":   return "cloud.rain.fill"
        case "snow":                        return "snow"
        case "thunderstorm", "thunder":    return "cloud.bolt.fill"
        default:                           return "cloud.fill"
        }
    }
}
