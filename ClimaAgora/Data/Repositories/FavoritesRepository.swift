import Foundation

// MARK: - Implementação concreta do FavoritesRepositoryProtocol
// Delega ao FavoriteCitiesManager (UserDefaults).
// Trocar a persistência (p.ex. CloudKit) = só mudar esta classe.

final class FavoritesRepository: FavoritesRepositoryProtocol {
    private let manager = FavoriteCitiesManager.shared

    func isFavorite(_ city: String) -> Bool    { manager.isFavorite(city) }
    func addFavorite(_ city: String)            { manager.addFavorite(city) }
    func removeFavorite(_ city: String)         { manager.removeFavorite(city) }
    func getAllFavorites() -> [String]           { manager.getFavoriteCities() }
}
