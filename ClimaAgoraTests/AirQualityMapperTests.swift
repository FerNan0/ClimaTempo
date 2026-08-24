//
//  AirQualityMapperTests.swift
//  ClimaAgoraTests
//
//  Mapper DTO → domínio da qualidade do ar: lista vazia deve virar nil (sem
//  dado da API, não "boa por padrão"), e um aqi fora da escala 1–5 não pode
//  derrubar o mapeamento — cai num nível neutro (moderate).
//

import Testing
import Foundation
@testable import ClimaAgora

struct AirQualityMapperTests {

    private func dto(aqi: Int, pm25: Double = 12.3) -> OpenWeatherAirPollutionResponse {
        OpenWeatherAirPollutionResponse(list: [
            OpenWeatherAirPollutionItem(
                main: OpenWeatherAirPollutionMain(aqi: aqi),
                components: OpenWeatherAirPollutionComponents(pm2_5: pm25)
            )
        ])
    }

    @Test func mapeiaAqiValidoParaONivelCorreto() {
        let result = AirQualityMapper.map(dto(aqi: 1))
        #expect(result?.level == .good)
        #expect(result?.pm25 == 12.3)
    }

    @Test func mapeiaTodosOsNiveisDaEscala() {
        #expect(AirQualityMapper.map(dto(aqi: 1))?.level == .good)
        #expect(AirQualityMapper.map(dto(aqi: 2))?.level == .fair)
        #expect(AirQualityMapper.map(dto(aqi: 3))?.level == .moderate)
        #expect(AirQualityMapper.map(dto(aqi: 4))?.level == .poor)
        #expect(AirQualityMapper.map(dto(aqi: 5))?.level == .veryPoor)
    }

    @Test func listaVaziaViraNil() {
        let response = OpenWeatherAirPollutionResponse(list: [])
        #expect(AirQualityMapper.map(response) == nil)
    }

    @Test func aqiForaDaEscalaCaiParaModerate() {
        // A API nunca deveria mandar 0 ou 6, mas o mapper não pode quebrar.
        #expect(AirQualityMapper.map(dto(aqi: 0))?.level == .moderate)
        #expect(AirQualityMapper.map(dto(aqi: 6))?.level == .moderate)
    }
}
