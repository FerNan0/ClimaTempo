//
//  WeatherMapperTests.swift
//  ClimaAgoraTests
//
//  Teste de mapper (DTO → Domain) — item do checklist do guia de arquitetura.
//  Garante que a resposta crua da API vira um modelo de domínio correto.
//

import Testing
import Foundation
@testable import ClimaAgora

struct WeatherMapperTests {

    @Test func mapsDTOToDomainModel() {
        let dto = OpenWeatherResponse(
            name: "Lisboa",
            main: OpenWeatherMain(temp: 18.5, feels_like: 17.0, humidity: 72),
            weather: [OpenWeatherInfo(main: "Rain", description: "chuva leve")],
            wind: OpenWeatherWind(speed: 9.3),
            clouds: OpenWeatherClouds(all: 90),
            visibility: 8000,
            sys: OpenWeatherSys(sunrise: 1_700_000_000, sunset: 1_700_040_000)
        )

        let weather = WeatherMapper.map(dto)

        #expect(weather.city == "Lisboa")
        #expect(weather.temperature == 18.5)
        #expect(weather.feelsLike == 17.0)
        #expect(weather.condition == "Rain")          // chave bruta (inglês) p/ lógica
        #expect(weather.description == "chuva leve")   // texto localizado p/ tela
        #expect(weather.humidity == 72)
        #expect(weather.cloudiness == 90)
        #expect(weather.visibility == 8000)
        #expect(weather.uvIndex == 0.0)                // não vem deste endpoint
    }

    @Test func emptyWeatherArrayFallsBackToEmptyStrings() {
        let dto = OpenWeatherResponse(
            name: "Cidade",
            main: OpenWeatherMain(temp: 20, feels_like: 20, humidity: 50),
            weather: [],
            wind: OpenWeatherWind(speed: 5),
            clouds: OpenWeatherClouds(all: 0),
            visibility: 10000,
            sys: OpenWeatherSys(sunrise: 0, sunset: 0)
        )

        let weather = WeatherMapper.map(dto)

        #expect(weather.condition == "")
        #expect(weather.description == "")
    }
}

struct ForecastMapperTests {

    @Test func collapsesToOnePerDayAndCapsAtFive() {
        // 3 slots no mesmo dia + 6 dias seguintes → espera no máximo 5 dias.
        let day: TimeInterval = 86_400
        let base = 1_700_000_000.0
        var items: [OpenWeatherForecastItem] = []

        // mesmo dia (3 slots de 3h)
        for h in 0..<3 {
            items.append(makeItem(dt: base + Double(h) * 3 * 3600))
        }
        // próximos 6 dias
        for d in 1...6 {
            items.append(makeItem(dt: base + Double(d) * day))
        }

        let result = ForecastMapper.map(OpenWeatherForecastResponse(list: items))

        #expect(result.count == 5) // 7 dias distintos, limitado a 5
    }

    private func makeItem(dt: Double) -> OpenWeatherForecastItem {
        OpenWeatherForecastItem(
            dt: Int(dt),
            main: OpenWeatherMain(temp: 22, feels_like: 22, humidity: 60),
            weather: [OpenWeatherInfo(main: "Clear", description: "céu limpo")],
            wind: OpenWeatherWind(speed: 4),
            clouds: OpenWeatherClouds(all: 10),
            pop: 0.1
        )
    }
}
