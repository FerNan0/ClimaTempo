//
//  WeatherRiskAssessorTests.swift
//  ClimaAgoraTests
//
//  Testa o motor de avisos de risco do tempo. Determinístico e sem rede/IA:
//  cada limiar vira uma asserção — é a evidência empírica que o TCC precisa
//  (e a regressão que garante que a "ventania" nunca mais passe batido).
//

import Testing
import Foundation
@testable import ClimaAgora

struct WeatherRiskAssessorTests {

    /// Fábrica de clima com defaults tranquilos; sobrescreve só o que o caso testa.
    private func weather(
        condition: String = "Clear",
        feelsLike: Double = 24,
        windSpeed: Double = 2,      // m/s
        uvIndex: Double = 0,
        visibility: Int = 10000
    ) -> Weather {
        Weather(
            city: "Teste", temperature: feelsLike, feelsLike: feelsLike,
            condition: condition, description: "teste", humidity: 60,
            windSpeed: windSpeed, cloudiness: 0,
            sunrise: Date(), sunset: Date().addingTimeInterval(3600),
            uvIndex: uvIndex, visibility: visibility
        )
    }

    @Test func climaCalmoNaoGeraRisco() {
        #expect(WeatherRiskAssessor.assess(weather: weather()).isEmpty)
    }

    @Test func ventaniaGeraPerigoDeVento() {
        // 14 m/s (~50 km/h): com a lógica antiga (comparava com 40/60 km/h) NÃO
        // disparava — este teste trava a correção.
        let risks = WeatherRiskAssessor.assess(weather: weather(windSpeed: 14))
        #expect(risks.contains { $0.hazard == .wind && $0.level == .danger })
    }

    @Test func ventoModeradoGeraAtencao() {
        let wind = WeatherRiskAssessor.assess(weather: weather(windSpeed: 9)).first { $0.hazard == .wind }
        #expect(wind?.level == .attention)
    }

    @Test func tempestadeEhOMaisGrave() {
        // Tempestade + vento forte → tempestade (perigo) vem primeiro.
        let risks = WeatherRiskAssessor.assess(weather: weather(condition: "Thunderstorm", windSpeed: 9))
        #expect(risks.first?.hazard == .storm)
        #expect(risks.first?.level == .danger)
    }

    @Test func calorExtremoGeraPerigo() {
        let risks = WeatherRiskAssessor.assess(weather: weather(feelsLike: 40))
        #expect(risks.contains { $0.hazard == .heat && $0.level == .danger })
    }

    @Test func frioGeraAtencao() {
        let risks = WeatherRiskAssessor.assess(weather: weather(feelsLike: 6))
        #expect(risks.contains { $0.hazard == .cold && $0.level == .attention })
    }

    @Test func chuvaAgoraGeraAtencao() {
        let risks = WeatherRiskAssessor.assess(weather: weather(condition: "Rain"))
        #expect(risks.contains { $0.hazard == .rain })
    }

    @Test func chuvaACaminhoPelaPrevisao() {
        let hoje = DailyForecast(date: Date(), tempMax: 25, tempMin: 18,
                                 condition: "Clouds", description: "nublado",
                                 precipitation: 90, humidity: 70, windSpeed: 3)
        let risks = WeatherRiskAssessor.assess(weather: weather(condition: "Clouds"), forecast: [hoje])
        #expect(risks.contains { $0.hazard == .rain })
    }

    @Test func neblinaGeraAtencao() {
        let risks = WeatherRiskAssessor.assess(weather: weather(visibility: 800))
        #expect(risks.contains { $0.hazard == .fog && $0.level == .attention })
    }

    @Test func nivelGeralEhOMaisGrave() {
        let risks = WeatherRiskAssessor.assess(weather: weather(condition: "Thunderstorm", windSpeed: 9))
        #expect(WeatherRiskAssessor.overallLevel(risks) == .danger)
    }

    @Test func semRiscoNivelGeralEhSafe() {
        #expect(WeatherRiskAssessor.overallLevel([]) == .safe)
    }
}
