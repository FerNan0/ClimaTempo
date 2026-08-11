import Foundation

protocol FavoritesRepositoryProtocol {
    func isFavorite(_ city: String) -> Bool
    func addFavorite(_ city: String)
    func removeFavorite(_ city: String)
    func getAllFavorites() -> [String]
}
