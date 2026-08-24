//
//  SimplifiedAdviceTests.swift
//  ClimaAgoraTests
//
//  O fallback determinístico (sem IA) do modo simples — precisa SEMPRE dar um
//  conselho claro, mesmo sem o modelo on-device disponível. Testa as
//  fronteiras exatas das faixas de temperatura e os avisos de chuva/tempestade.
//

import Testing
import Foundation
@testable import ClimaAgora

struct SimplifiedAdviceTests {

    private func weather(temp: Double, condition: String = "Clear") -> Weather {
        Weather(city: "Teste", temperature: temp, feelsLike: temp, condition: condition,
                description: "teste", humidity: 60, windSpeed: 2, cloudiness: 0,
                sunrise: Date(), sunset: Date().addingTimeInterval(3600), uvIndex: 0, visibility: 10000)
    }

    @Test func muitoFrioAbaixoDe10() {
        let advice = SimplifiedAdvice.fallback(for: weather(temp: 9))
        #expect(advice.weatherPhrase.contains("muito frio"))
        #expect(advice.advice.contains("casaco"))
    }

    @Test func fronteiraDe10GrausEhFrioNaoMuitoFrio() {
        let advice = SimplifiedAdvice.fallback(for: weather(temp: 10))
        #expect(advice.weatherPhrase.contains("um pouco frio"))
    }

    @Test func fronteiraDe18GrausEhAgradavel() {
        let advice = SimplifiedAdvice.fallback(for: weather(temp: 18))
        #expect(advice.weatherPhrase.contains("agradável"))
        #expect(advice.advice.contains("Bom dia"))
    }

    @Test func fronteiraDe25GrausEhQuente() {
        let advice = SimplifiedAdvice.fallback(for: weather(temp: 25))
        #expect(advice.weatherPhrase.contains("quente"))
    }

    @Test func fronteiraDe30GrausSugereAgua() {
        let advice = SimplifiedAdvice.fallback(for: weather(temp: 30))
        #expect(advice.advice.contains("água"))
    }

    @Test func fronteiraDe32GrausEhMuitoQuente() {
        let advice = SimplifiedAdvice.fallback(for: weather(temp: 32))
        #expect(advice.weatherPhrase.contains("muito quente"))
    }

    @Test func chuvaGeraAvisoDeCautela() {
        let advice = SimplifiedAdvice.fallback(for: weather(temp: 20, condition: "Rain"))
        #expect(advice.caution?.contains("chuva") == true)
    }

    @Test func tempestadeGeraAvisoDeCautela() {
        let advice = SimplifiedAdvice.fallback(for: weather(temp: 20, condition: "Thunderstorm"))
        #expect(advice.caution?.contains("tempestade") == true)
    }

    @Test func climaSecoNaoGeraCautela() {
        let advice = SimplifiedAdvice.fallback(for: weather(temp: 20, condition: "Clear"))
        #expect(advice.caution == nil)
    }
}
