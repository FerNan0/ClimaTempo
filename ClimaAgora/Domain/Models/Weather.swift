import Foundation

// MARK: - Entidades de Domínio
// Modelos puros — sem Decodable, sem dependência de rede ou UI.

struct Weather: Identifiable, Equatable {
    let id: UUID
    let city: String
    let temperature: Double
    let feelsLike: Double
    /// Chave da condição vinda da API (ex.: "Clouds", "Rain") — em inglês.
    /// Use para lógica/switch (gradiente, ícone, semáforo). NÃO exibir direto ao usuário.
    let condition: String
    /// Texto já localizado em pt-br (ex.: "nublado") — este é o que vai pra tela.
    let description: String
    let humidity: Int
    let windSpeed: Double
    let cloudiness: Int
    let sunrise: Date
    let sunset: Date
    let uvIndex: Double
    let visibility: Int
    /// Coordenadas da cidade (usadas por features que dependem de lat/lon,
    /// como qualidade do ar). Default 0 mantém compatibilidade com quem não as informa.
    let latitude: Double
    let longitude: Double

    init(
        id: UUID = UUID(),
        city: String,
        temperature: Double,
        feelsLike: Double,
        condition: String,
        description: String,
        humidity: Int,
        windSpeed: Double,
        cloudiness: Int,
        sunrise: Date,
        sunset: Date,
        uvIndex: Double,
        visibility: Int,
        latitude: Double = 0,
        longitude: Double = 0
    ) {
        self.id = id
        self.city = city
        self.temperature = temperature
        self.feelsLike = feelsLike
        self.condition = condition
        self.description = description
        self.humidity = humidity
        self.windSpeed = windSpeed
        self.cloudiness = cloudiness
        self.sunrise = sunrise
        self.sunset = sunset
        self.uvIndex = uvIndex
        self.visibility = visibility
        self.latitude = latitude
        self.longitude = longitude
    }

    /// Velocidade do vento em km/h. A API devolve em m/s (units=metric); esta é
    /// a forma correta de exibir "km/h" na tela (× 3,6).
    var windKmh: Double { windSpeed * 3.6 }

    /// Progresso do sol entre o nascer (0) e o pôr (1) num instante — puro,
    /// para posicionar o sol no arco do card "nascer / pôr do sol".
    /// Fora do intervalo diurno, satura em 0 ou 1.
    func daylightProgress(at now: Date = Date()) -> Double {
        let total = sunset.timeIntervalSince(sunrise)
        guard total > 0 else { return 0 }
        let elapsed = now.timeIntervalSince(sunrise)
        return min(1, max(0, elapsed / total))
    }

    // Igualdade SEMÂNTICA (de propósito não compara todos os campos):
    // dois climas são "iguais" se cidade + temperatura + condição batem.
    // Evita que um refetch com os mesmos valores dispare re-render na View.
    static func == (lhs: Weather, rhs: Weather) -> Bool {
        lhs.city == rhs.city &&
        lhs.temperature == rhs.temperature &&
        lhs.condition == rhs.condition
    }

    static let preview = Weather(
        city: "São Paulo",
        temperature: 25.0,
        feelsLike: 26.0,
        condition: "Ensolarado",
        description: "Céu limpo",
        humidity: 65,
        windSpeed: 12.5,
        cloudiness: 10,
        sunrise: Date().addingTimeInterval(-21600),
        sunset: Date().addingTimeInterval(21600),
        uvIndex: 7.5,
        visibility: 10000
    )
}

struct DailyForecast: Identifiable {
    let id: UUID
    let date: Date
    let tempMax: Double
    let tempMin: Double
    let condition: String
    let description: String
    let precipitation: Double
    let humidity: Int
    let windSpeed: Double

    init(
        id: UUID = UUID(),
        date: Date,
        tempMax: Double,
        tempMin: Double,
        condition: String,
        description: String,
        precipitation: Double,
        humidity: Int,
        windSpeed: Double
    ) {
        self.id = id
        self.date = date
        self.tempMax = tempMax
        self.tempMin = tempMin
        self.condition = condition
        self.description = description
        self.precipitation = precipitation
        self.humidity = humidity
        self.windSpeed = windSpeed
    }
}

struct HourlyForecast: Identifiable {
    let id: UUID
    let time: Date
    let temperature: Double
    let condition: String
    let precipitation: Double
    let humidity: Int

    init(
        id: UUID = UUID(),
        time: Date,
        temperature: Double,
        condition: String,
        precipitation: Double,
        humidity: Int
    ) {
        self.id = id
        self.time = time
        self.temperature = temperature
        self.condition = condition
        self.precipitation = precipitation
        self.humidity = humidity
    }
}
