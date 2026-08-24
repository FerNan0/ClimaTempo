//
//  ManageFavoritesUseCaseTests.swift
//  ClimaAgoraTests
//
//  O toggle decide adicionar OU remover a partir do estado atual — a lógica
//  fica no use case, não no repositório (que só sabe adicionar/remover).
//

import Testing
import Foundation
@testable import ClimaAgora

struct ManageFavoritesUseCaseTests {

    private func makeSUT() -> (ManageFavoritesUseCase, MockFavoritesRepository) {
        let repo = MockFavoritesRepository()
        return (ManageFavoritesUseCase(repository: repo), repo)
    }

    @Test func toggleAdicionaQuandoNaoEhFavorita() {
        let (sut, repo) = makeSUT()
        sut.toggle("São Paulo")
        #expect(repo.isFavorite("São Paulo"))
    }

    @Test func toggleRemoveQuandoJaEhFavorita() {
        let (sut, repo) = makeSUT()
        sut.toggle("São Paulo")
        sut.toggle("São Paulo")
        #expect(!repo.isFavorite("São Paulo"))
    }

    @Test func isFavoriteRepassaParaORepositorio() {
        let (sut, repo) = makeSUT()
        repo.addFavorite("Curitiba")
        #expect(sut.isFavorite("Curitiba"))
        #expect(!sut.isFavorite("Salvador"))
    }

    @Test func getAllFavoritesRepassaParaORepositorio() {
        let (sut, repo) = makeSUT()
        repo.addFavorite("Curitiba")
        repo.addFavorite("Salvador")
        #expect(Set(sut.getAllFavorites()) == ["Curitiba", "Salvador"])
    }
}
