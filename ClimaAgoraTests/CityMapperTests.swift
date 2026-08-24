//
//  CityMapperTests.swift
//  ClimaAgoraTests
//
//  Nome de exibição da cidade (geocoding → String) e deduplicação da lista de
//  resultados de busca (a API às vezes devolve a mesma cidade repetida com
//  coordenadas quase iguais).
//

import Testing
import Foundation
@testable import ClimaAgora

struct CityMapperTests {

    private func result(name: String, state: String?, lat: Double = 0, lon: Double = 0) -> OpenWeatherGeocodingResult {
        OpenWeatherGeocodingResult(name: name, state: state, country: "BR", lat: lat, lon: lon)
    }

    @Test func comEstadoJuntaNomeEEstado() {
        let name = CityMapper.displayName(result(name: "Curitiba", state: "Paraná"))
        #expect(name == "Curitiba, Paraná")
    }

    @Test func semEstadoUsaSoONome() {
        let name = CityMapper.displayName(result(name: "Ubatuba", state: nil))
        #expect(name == "Ubatuba")
    }

    @Test func displayNamesRemoveDuplicatas() {
        let names = CityMapper.displayNames([
            result(name: "Curitiba", state: "Paraná", lat: -25.42, lon: -49.27),
            result(name: "Curitiba", state: "Paraná", lat: -25.43, lon: -49.26), // "duplicata" (coords levemente diferentes)
            result(name: "Curitiba", state: "Bahia"),
        ])
        #expect(names == ["Curitiba, Paraná", "Curitiba, Bahia"])
    }

    @Test func displayNamesComListaVazia() {
        #expect(CityMapper.displayNames([]).isEmpty)
    }
}
