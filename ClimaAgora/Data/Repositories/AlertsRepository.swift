import Foundation

// MARK: - AlertsRepository (INMET)
//
// Busca os avisos meteorológicos oficiais do INMET (feed público, sem chave) e
// os filtra pela localização via mapper. É uma FONTE ADICIONAL: se o INMET
// estiver fora do ar ou lento, a ViewModel trata como "sem avisos" e o motor de
// risco local (WeatherRiskAssessor) continua funcionando.
//
// `actor` para serializar o acesso ao cache. O feed é nacional e pesado (traz
// ícones em base64), então guardamos a resposta por alguns minutos: trocar de
// cidade vira só um re-filtro local (instantâneo, sem baixar tudo de novo).

actor AlertsRepository: AlertsRepositoryProtocol {

    private let client: NetworkClient
    private let url = "https://apiprevmet3.inmet.gov.br/avisos/ativos"
    private let ttl: TimeInterval = 600   // 10 min

    private var cached: (response: INMETResponse, at: Date)?

    init(client: NetworkClient) {
        self.client = client
    }

    func fetchActiveAlerts(latitude: Double, longitude: Double) async throws -> [OfficialAlert] {
        let response = try await currentResponse()
        return INMETAlertMapper.map(response, latitude: latitude, longitude: longitude)
    }

    /// Resposta do INMET: usa o cache se ainda fresco; senão baixa e guarda.
    private func currentResponse() async throws -> INMETResponse {
        if let cached, Date().timeIntervalSince(cached.at) < ttl {
            return cached.response
        }
        // Timeout generoso: o feed é grande, e o aviso é complemento assíncrono
        // (carrega em background sem travar a Home).
        let response: INMETResponse = try await client.get(url, timeoutInterval: 30)
        cached = (response, Date())
        return response
    }
}
