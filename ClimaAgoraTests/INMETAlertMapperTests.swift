//
//  INMETAlertMapperTests.swift
//  ClimaAgoraTests
//
//  Testa o filtro por localização (point-in-polygon) e o mapeamento do feed do
//  INMET para o modelo acessível. Determinístico, sem rede.
//

import Testing
import Foundation
@testable import ClimaAgora

struct INMETAlertMapperTests {

    // Quadrado em torno de São Paulo (lon -47..-46, lat -24..-23), pontos [lon,lat].
    private let squareSP: [[Double]] = [
        [-47, -24], [-46, -24], [-46, -23], [-47, -23], [-47, -24]
    ]

    // MARK: - Geometria

    @Test func pontoDentroDoPoligono() {
        #expect(INMETAlertMapper.isInside(lon: -46.6, lat: -23.5, ring: squareSP))
    }

    @Test func pontoForaDoPoligono() {
        // Rio de Janeiro (~-43.2, -22.9) está fora do quadrado de SP.
        #expect(!INMETAlertMapper.isInside(lon: -43.2, lat: -22.9, ring: squareSP))
    }

    @Test func aneisDegeneradosNaoContem() {
        #expect(!INMETAlertMapper.isInside(lon: 0, lat: 0, ring: [[0, 0], [1, 1]]))
    }

    // MARK: - Decode + mapeamento + filtro

    private func decode(_ json: String) -> INMETResponse {
        try! JSONDecoder().decode(INMETResponse.self, from: Data(json.utf8))
    }

    /// JSON mínimo com um aviso de "hoje" cobrindo SP e um de "futuro" cobrindo SP.
    private let fixture = """
    {
      "hoje": [{
        "id": 1, "descricao": "Tempestade", "severidade": "Perigo",
        "aviso_cor": "#FF0000",
        "riscos": ["Risco de corte de energia.", "Alagamentos."],
        "instrucoes": ["Não se abrigue sob árvores."],
        "estados": "São Paulo,Rio de Janeiro,Minas Gerais",
        "inicio": "2026-08-13 09:15", "fim": "2026-08-14 23:59",
        "poligono": {"type":"Polygon","coordinates":[[[-47,-24],[-46,-24],[-46,-23],[-47,-23],[-47,-24]]]}
      }],
      "futuro": [{
        "id": 2, "descricao": "Ventania", "severidade": "Perigo Potencial",
        "riscos": ["Vento forte."], "instrucoes": ["Segure objetos soltos."],
        "estados": "São Paulo",
        "inicio": "2026-08-15 06:00", "fim": "2026-08-15 18:00",
        "poligono": {"type":"Polygon","coordinates":[[[-47,-24],[-46,-24],[-46,-23],[-47,-23],[-47,-24]]]}
      }]
    }
    """

    @Test func mapeiaAvisosQueCobremACidade() {
        let alerts = INMETAlertMapper.map(decode(fixture), latitude: -23.5, longitude: -46.6)
        #expect(alerts.count == 2)
        // Em vigor (hoje) vem antes do futuro.
        #expect(alerts.first?.isFuture == false)
        #expect(alerts.first?.hazard == "Tempestade")
        #expect(alerts.first?.level == .danger)
        #expect(alerts.first?.source == "INMET")
        // "Perigo Potencial" → atenção; marcado como futuro.
        let futuro = alerts.first { $0.isFuture }
        #expect(futuro?.level == .attention)
    }

    @Test func filtraAvisosForaDaCidade() {
        // Brasília (~-47.9, -15.8) está fora do quadrado de SP → nenhum aviso.
        let alerts = INMETAlertMapper.map(decode(fixture), latitude: -15.8, longitude: -47.9)
        #expect(alerts.isEmpty)
    }

    @Test func juntaRiscosEInstrucoesEmFrase() {
        let alerts = INMETAlertMapper.map(decode(fixture), latitude: -23.5, longitude: -46.6)
        #expect(alerts.first?.whatCanHappen.contains("energia") == true)
        #expect(alerts.first?.whatToDo.contains("árvores") == true)
    }

    @Test func resumeAreaComEstados() {
        let alerts = INMETAlertMapper.map(decode(fixture), latitude: -23.5, longitude: -46.6)
        // 3 estados → "São Paulo, Rio de Janeiro e +1"
        #expect(alerts.first?.areaLabel.contains("+1") == true)
    }

    @Test func decodeToleranteAElementoInvalido() {
        // O segundo elemento de "hoje" é inválido (sem campos obrigatórios) e deve
        // ser descartado sem derrubar o primeiro.
        let json = """
        {"hoje":[
          {"id":1,"descricao":"Chuva","severidade":"Perigo Potencial",
           "poligono":{"type":"Polygon","coordinates":[[[-47,-24],[-46,-24],[-46,-23],[-47,-23],[-47,-24]]]}},
          {"foo":"bar"}
        ],"futuro":[]}
        """
        let alerts = INMETAlertMapper.map(decode(json), latitude: -23.5, longitude: -46.6)
        #expect(alerts.count == 1)
        #expect(alerts.first?.hazard == "Chuva")
    }
}
