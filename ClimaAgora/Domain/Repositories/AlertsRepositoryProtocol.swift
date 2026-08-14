import Foundation

// MARK: - AlertsRepositoryProtocol
//
// Contrato para avisos oficiais. A implementação (INMET) mora na camada Data;
// o Domain só conhece esta interface — trocar a fonte oficial não toca o resto.

protocol AlertsRepositoryProtocol {
    /// Avisos oficiais ATIVOS ou próximos que cobrem o ponto (lat/lon) informado.
    func fetchActiveAlerts(latitude: Double, longitude: Double) async throws -> [OfficialAlert]
}
