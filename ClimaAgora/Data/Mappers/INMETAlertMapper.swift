import Foundation

// MARK: - INMETAlertMapper
//
// DTO do INMET → OfficialAlert (domínio), filtrando pela localização: só entram
// os avisos cujo polígono contém o ponto (lat/lon) da cidade — match preciso via
// point-in-polygon, sem depender de UF. Também traduz severidade/tipo para o
// formato acessível (semáforo + emoji) e resume a área.

enum INMETAlertMapper {

    static func map(_ response: INMETResponse, latitude: Double, longitude: Double) -> [OfficialAlert] {
        let hoje   = response.hoje.compactMap   { alert($0, at: latitude, longitude, isFuture: false) }
        let futuro = response.futuro.compactMap { alert($0, at: latitude, longitude, isFuture: true) }
        // Em vigor primeiro; dentro de cada grupo, mais grave primeiro.
        return (hoje + futuro).sorted {
            if $0.isFuture != $1.isFuture { return !$0.isFuture }
            return $0.level > $1.level
        }
    }

    // MARK: - Um aviso (só se cobrir o ponto)

    private static func alert(_ dto: INMETAviso, at lat: Double, _ lon: Double, isFuture: Bool) -> OfficialAlert? {
        guard let rings = dto.poligono?.rings, contains(lon: lon, lat: lat, rings: rings) else { return nil }

        return OfficialAlert(
            id: String(dto.id),
            source: "INMET",
            hazard: dto.descricao,
            severityLabel: dto.severidade,
            level: level(for: dto.severidade),
            emoji: emoji(for: dto.descricao),
            whatCanHappen: sentence(from: dto.riscos) ?? "Condição de risco na sua região.",
            whatToDo: sentence(from: dto.instrucoes) ?? "Fique atento e evite áreas de risco.",
            areaLabel: area(from: dto.estados),
            startText: format(dto.inicio),
            endText: format(dto.fim),
            isFuture: isFuture
        )
    }

    // MARK: - Point-in-polygon (ray casting)

    /// Verdadeiro se o ponto está dentro de qualquer anel externo.
    static func contains(lon: Double, lat: Double, rings: [[[Double]]]) -> Bool {
        rings.contains { isInside(lon: lon, lat: lat, ring: $0) }
    }

    static func isInside(lon: Double, lat: Double, ring: [[Double]]) -> Bool {
        guard ring.count >= 3 else { return false }
        var inside = false
        var j = ring.count - 1
        for i in 0..<ring.count {
            let xi = ring[i][0], yi = ring[i][1]
            let xj = ring[j][0], yj = ring[j][1]
            if (yi > lat) != (yj > lat),
               lon < (xj - xi) * (lat - yi) / (yj - yi) + xi {
                inside.toggle()
            }
            j = i
        }
        return inside
    }

    // MARK: - Traduções

    private static func level(for severidade: String) -> WeatherRisk.Level {
        let s = severidade.lowercased()
        if s.contains("grande perigo") { return .danger }
        if s.contains("potencial")     { return .attention }   // "Perigo Potencial"
        if s.contains("perigo")         { return .danger }
        return .attention
    }

    private static func emoji(for descricao: String) -> String {
        let d = descricao.lowercased()
        if d.contains("tempestade") || d.contains("raio") { return "⛈️" }
        if d.contains("vent")                              { return "💨" }
        if d.contains("chuva") || d.contains("acumulad")  { return "🌧️" }
        if d.contains("calor") || d.contains("elevada")   { return "🥵" }
        if d.contains("frio")  || d.contains("declínio") || d.contains("geada") { return "🥶" }
        if d.contains("umidade") || d.contains("seca")    { return "🏜️" }
        if d.contains("granizo")                           { return "🧊" }
        return "⚠️"
    }

    /// Junta os itens do INMET numa frase curta (acessibilidade: 1 bloco de texto).
    private static func sentence(from items: [String]?) -> String? {
        guard let items = items?.compactMap({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })
            .filter({ !$0.isEmpty }), !items.isEmpty else { return nil }
        var text = items.joined(separator: " ")
        if !text.hasSuffix(".") { text += "." }
        return text
    }

    /// "Santa Catarina,Paraná,..." → "Santa Catarina, Paraná e +3".
    private static func area(from estados: String?) -> String {
        let list = (estados ?? "").split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        guard !list.isEmpty else { return "sua região" }
        if list.count <= 2 { return list.joined(separator: " e ") }
        return "\(list[0]), \(list[1]) e +\(list.count - 2)"
    }

    /// "2026-08-13 09:15" → "13/08 09:15".
    private static func format(_ raw: String?) -> String? {
        guard let raw, !raw.isEmpty else { return nil }
        let parts = raw.split(separator: " ")
        guard let date = parts.first?.split(separator: "-"), date.count == 3 else { return raw }
        let time = parts.count > 1 ? " \(parts[1])" : ""
        return "\(date[2])/\(date[1])\(time)"
    }
}
