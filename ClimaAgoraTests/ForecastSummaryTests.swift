//
//  ForecastSummaryTests.swift
//  ClimaAgoraTests
//
//  Agregação do período de previsão (médias de máx/mín e dias de chuva) —
//  usada no card "Máx. média / Mín. média / Dias de chuva" da Home.
//

import Testing
import Foundation
@testable import ClimaAgora

struct ForecastSummaryTests {

    private func day(max: Double, min: Double, precipitation: Double) -> DailyForecast {
        DailyForecast(date: Date(), tempMax: max, tempMin: min, condition: "Clouds",
                      description: "nublado", precipitation: precipitation, humidity: 60, windSpeed: 2)
    }

    @Test func listaVaziaDevolveZeros() {
        let summary = ForecastSummary.from([])
        #expect(summary == ForecastSummary(averageMax: 0, averageMin: 0, rainyDays: 0))
    }

    @Test func calculaMediasCorretamente() {
        let days = [
            day(max: 30, min: 20, precipitation: 0),
            day(max: 20, min: 10, precipitation: 0),
        ]
        let summary = ForecastSummary.from(days)
        #expect(summary.averageMax == 25)
        #expect(summary.averageMin == 15)
    }

    @Test func contaDiasDeChuvaComLimiarDe30PorCento() {
        let days = [
            day(max: 25, min: 15, precipitation: 30),  // conta (limiar inclusivo)
            day(max: 25, min: 15, precipitation: 29.9), // não conta
            day(max: 25, min: 15, precipitation: 80),  // conta
        ]
        #expect(ForecastSummary.from(days).rainyDays == 2)
    }

    @Test func nenhumDiaDeChuva() {
        let days = [day(max: 25, min: 15, precipitation: 0), day(max: 26, min: 16, precipitation: 5)]
        #expect(ForecastSummary.from(days).rainyDays == 0)
    }
}
