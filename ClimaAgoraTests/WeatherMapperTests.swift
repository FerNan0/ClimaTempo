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
            coord: OpenWeatherCoord(lat: 38.72, lon: -9.14),
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
            coord: OpenWeatherCoord(lat: 0, lon: 0),
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

    @Test func collapsesPointsToOnePerDay() {
        // 4 pontos no mesmo dia + 2 dias seguintes → 3 dias distintos.
        let day: TimeInterval = 86_400
        let base = Calendar.current.startOfDay(for: Date()).timeIntervalSince1970 + 3600
        var items: [OpenWeatherForecastItem] = []
        for h in 0..<4 { items.append(makeItem(dt: base + Double(h) * 3 * 3600, temp: 20)) }
        for d in 1...2 { items.append(makeItem(dt: base + Double(d) * day, temp: 20)) }

        let result = ForecastMapper.map(OpenWeatherForecastResponse(list: items))

        #expect(result.count == 3)
    }

    @Test func aggregatesRealMinAndMaxPerDay() {
        // Vários pontos no MESMO dia com temperaturas diferentes:
        // o mapper deve extrair a mínima e a máxima reais (não tempMax == tempMin).
        let base = Calendar.current.startOfDay(for: Date()).timeIntervalSince1970 + 3600
        let temps: [Double] = [14, 19, 25, 21]
        let items = temps.enumerated().map { i, t in
            makeItem(dt: base + Double(i) * 3 * 3600, temp: t)
        }

        let result = ForecastMapper.map(OpenWeatherForecastResponse(list: items))

        #expect(result.count == 1)
        #expect(result[0].tempMin == 14)
        #expect(result[0].tempMax == 25)
        #expect(result[0].tempMax != result[0].tempMin)
    }

    private func makeItem(dt: Double, temp: Double) -> OpenWeatherForecastItem {
        OpenWeatherForecastItem(
            dt: Int(dt),
            main: OpenWeatherMain(temp: temp, feels_like: temp, humidity: 60),
            weather: [OpenWeatherInfo(main: "Clear", description: "céu limpo")],
            wind: OpenWeatherWind(speed: 4),
            clouds: OpenWeatherClouds(all: 10),
            pop: 0.1
        )
    }
}
