import Foundation

// MARK: - Interface

protocol ManageFavoritesUseCaseProtocol {
    func isFavorite(_ city: String) -> Bool
    func toggle(_ city: String)
    func getAllFavorites() -> [String]
}

// MARK: - Implementação

final class ManageFavoritesUseCase: ManageFavoritesUseCaseProtocol {
    private let repository: FavoritesRepositoryProtocol

    init(repository: FavoritesRepositoryProtocol) {
        self.repository = repository
    }

    func isFavorite(_ city: String) -> Bool {
        repository.isFavorite(city)
    }

    func toggle(_ city: String) {
        if repository.isFavorite(city) {
            repository.removeFavorite(city)
        } else {
            repository.addFavorite(city)
        }
    }

    func getAllFavorites() -> [String] {
        repository.getAllFavorites()
    }
}
