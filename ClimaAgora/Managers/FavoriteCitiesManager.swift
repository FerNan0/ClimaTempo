import Foundation

class FavoriteCitiesManager {
    static let shared = FavoriteCitiesManager()
    private let favoritesKey = "favorite_cities"
    
    // MARK: - Obter Cidades Favoritas
    func getFavoriteCities() -> [String] {
        return UserDefaults.standard.stringArray(forKey: favoritesKey) ?? []
    }
    
    // MARK: - Adicionar Cidade Favorita
    func addFavorite(_ city: String) {
        var favorites = getFavoriteCities()
        if !favorites.contains(city) {
            favorites.append(city)
            UserDefaults.standard.set(favorites, forKey: favoritesKey)
        }
    }
    
    // MARK: - Remover Cidade Favorita
    func removeFavorite(_ city: String) {
        var favorites = getFavoriteCities()
        favorites.removeAll { $0 == city }
        UserDefaults.standard.set(favorites, forKey: favoritesKey)
    }
    
    // MARK: - Verificar se é Favorita
    func isFavorite(_ city: String) -> Bool {
        return getFavoriteCities().contains(city)
    }
}
