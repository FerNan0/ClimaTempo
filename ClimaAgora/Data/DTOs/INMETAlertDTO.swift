import Foundation

// MARK: - DTOs do INMET (apiprevmet3.inmet.gov.br/avisos/ativos)
//
// A resposta separa avisos em `hoje` (em vigor) e `futuro` (vão começar).
// Decodifica de forma tolerante: um aviso malformado é descartado em vez de
// derrubar a lista inteira (é um recurso de segurança — degradar, não sumir).

struct INMETResponse: Decodable {
    let hoje: [INMETAviso]
    let futuro: [INMETAviso]

    private enum CodingKeys: String, CodingKey { case hoje, futuro }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        hoje   = (try? c.decode(LossyArray<INMETAviso>.self, forKey: .hoje))?.elements ?? []
        futuro = (try? c.decode(LossyArray<INMETAviso>.self, forKey: .futuro))?.elements ?? []
    }
}

struct INMETAviso: Decodable {
    let id: Int
    let descricao: String
    let severidade: String
    let aviso_cor: String?
    let riscos: [String]?
    let instrucoes: [String]?
    let estados: String?
    let inicio: String?
    let fim: String?
    let poligono: INMETGeometry?
}

// MARK: - Geometria (GeoJSON Polygon/MultiPolygon → lista de anéis [lon,lat])

struct INMETGeometry: Decodable {
    /// Anéis normalizados: cada anel é uma lista de pontos [lon, lat].
    let rings: [[[Double]]]

    private enum CodingKeys: String, CodingKey { case type, coordinates }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let type = (try? c.decode(String.self, forKey: .type)) ?? "Polygon"

        if type == "MultiPolygon",
           let multi = try? c.decode([[[[Double]]]].self, forKey: .coordinates) {
            // [polígono][anel][ponto][lon/lat] → junta todos os anéis externos
            rings = multi.flatMap { $0 }
        } else if let poly = try? c.decode([[[Double]]].self, forKey: .coordinates) {
            rings = poly
        } else {
            rings = []
        }
    }
}

// MARK: - LossyArray (descarta elementos que não decodificam)

struct LossyArray<Element: Decodable>: Decodable {
    let elements: [Element]

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var result: [Element] = []
        while !container.isAtEnd {
            if let element = try? container.decode(Element.self) {
                result.append(element)
            } else {
                _ = try? container.decode(AnyDecodableSkip.self) // avança 1 posição
            }
        }
        elements = result
    }
}

private struct AnyDecodableSkip: Decodable {
    init(from decoder: Decoder) throws {}
}
