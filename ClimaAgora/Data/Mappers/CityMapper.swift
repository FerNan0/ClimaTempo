import Foundation

// MARK: - Mapper: OpenWeatherGeocodingResult → String (nome de exibição)

enum CityMapper {
    static func displayName(_ dto: OpenWeatherGeocodingResult) -> String {
        if let state = dto.state {
            return "\(dto.name), \(state)"
        }
        return dto.name
    }

    static func displayNames(_ dtos: [OpenWeatherGeocodingResult]) -> [String] {
        var seen = Set<String>()
        return dtos.compactMap { dto -> String? in
            let name = displayName(dto)
            return seen.insert(name).inserted ? name : nil
        }
    }
}
