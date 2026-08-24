//
//  WeatherTests.swift
//  ClimaAgoraTests
//
//  Lógica pura do modelo Weather: conversão de vento (m/s → km/h, o bug que
//  fazia o risco de ventania nunca disparar — ver WeatherRiskAssessorTests)
//  e o progresso do sol no arco nascer/pôr.
//

import Testing
import Foundation
@testable import ClimaAgora

struct WeatherTests {

    private func weather(windSpeed: Double = 0, sunrise: Date = Date(), sunset: Date = Date()) -> Weather {
        Weather(city: "Teste", temperature: 20, feelsLike: 20, condition: "Clear",
                description: "teste", humidity: 60, windSpeed: windSpeed, cloudiness: 0,
                sunrise: sunrise, sunset: sunset, uvIndex: 0, visibility: 10000)
    }

    // MARK: - windKmh

    @Test func convertePraKmhMultiplicandoPor36() {
        #expect(weather(windSpeed: 10).windKmh == 36)
    }

    @Test func ventoZeroPermaneceZero() {
        #expect(weather(windSpeed: 0).windKmh == 0)
    }

    // MARK: - daylightProgress

    @Test func antesDoNascerDoSolSatura0() {
        let sunrise = Date()
        let w = weather(sunrise: sunrise, sunset: sunrise.addingTimeInterval(3600))
        let progress = w.daylightProgress(at: sunrise.addingTimeInterval(-600))
        #expect(progress == 0)
    }

    @Test func depoisDoPorDoSolSatura1() {
        let sunrise = Date()
        let w = weather(sunrise: sunrise, sunset: sunrise.addingTimeInterval(3600))
        let progress = w.daylightProgress(at: sunrise.addingTimeInterval(7200))
        #expect(progress == 1)
    }

    @Test func noMeioDoDiaEhMetade() {
        let sunrise = Date()
        let w = weather(sunrise: sunrise, sunset: sunrise.addingTimeInterval(3600))
        let progress = w.daylightProgress(at: sunrise.addingTimeInterval(1800))
        #expect(progress == 0.5)
    }

    @Test func semDuracaoDeDiaDevolveZero() {
        // sunset == sunrise (dado inconsistente) não pode dividir por zero.
        let now = Date()
        let w = weather(sunrise: now, sunset: now)
        #expect(w.daylightProgress(at: now) == 0)
    }
}
