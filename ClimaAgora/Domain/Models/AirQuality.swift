import Foundation

// MARK: - AirQuality (entidade de domínio)
// Modelo puro — sem Decodable, sem rede. Representa a qualidade do ar de um
// ponto, derivada do índice da API (1–5) para uma categoria legível.

struct AirQuality: Equatable {

    /// Categoria de qualidade do ar (escala OpenWeather 1–5).
    enum Level: Int, CaseIterable {
        case good = 1
        case fair = 2
        case moderate = 3
        case poor = 4
        case veryPoor = 5

        /// Rótulo localizado para exibição.
        var label: String {
            switch self {
            case .good:     return "Boa"
            case .fair:     return "Razoável"
            case .moderate: return "Moderada"
            case .poor:     return "Ruim"
            case .veryPoor: return "Muito ruim"
            }
        }

        /// Posição relativa (0–1) na barra verde→amarelo→vermelho.
        var barPosition: Double {
            switch self {
            case .good:     return 0.1
            case .fair:     return 0.3
            case .moderate: return 0.5
            case .poor:     return 0.72
            case .veryPoor: return 0.92
            }
        }
    }

    let level: Level
    /// Concentração de material particulado fino (µg/m³), quando disponível.
    let pm25: Double?

    init(level: Level, pm25: Double? = nil) {
        self.level = level
        self.pm25 = pm25
    }

    static let preview = AirQuality(level: .good, pm25: 8.2)
}
