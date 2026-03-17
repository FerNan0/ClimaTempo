import Foundation

class WantToVisitManager {
    static let shared = WantToVisitManager()
    private let wantToVisitKey = "want_to_visit_cities"
    
    // MARK: - Obter Cidades a Visitar
    func getCitiesWantToVisit() -> [String] {
        return UserDefaults.standard.stringArray(forKey: wantToVisitKey) ?? []
    }
    
    // MARK: - Adicionar Cidade para Visitar
    func addWantToVisit(_ city: String) {
        var cities = getCitiesWantToVisit()
        if !cities.contains(city) {
            cities.append(city)
            UserDefaults.standard.set(cities, forKey: wantToVisitKey)
        }
    }
    
    // MARK: - Remover Cidade para Visitar
    func removeWantToVisit(_ city: String) {
        var cities = getCitiesWantToVisit()
        cities.removeAll { $0 == city }
        UserDefaults.standard.set(cities, forKey: wantToVisitKey)
    }
    
    // MARK: - Verificar se quer Visitar
    func wantsToVisit(_ city: String) -> Bool {
        return getCitiesWantToVisit().contains(city)
    }
}
