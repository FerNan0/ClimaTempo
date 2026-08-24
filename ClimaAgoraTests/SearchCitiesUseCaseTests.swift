//
//  SearchCitiesUseCaseTests.swift
//  ClimaAgoraTests
//
//  Regra de negócio "busca só a partir de 3 caracteres" — fonte da verdade
//  aqui no use case (a ViewModel só replica como atalho de UX).
//

import Testing
import Foundation
@testable import ClimaAgora

struct SearchCitiesUseCaseTests {

    private func makeSUT(searchResult: [String] = []) -> (SearchCitiesUseCase, MockWeatherRepository) {
        let repo = MockWeatherRepository()
        repo.searchResult = searchResult
        return (SearchCitiesUseCase(repository: repo), repo)
    }

    @Test func menosDe3CaracteresNaoChamaORepositorio() async throws {
        let (sut, repo) = makeSUT(searchResult: ["não deveria vir"])
        let result = try await sut.execute(.init(query: "SP"))
        #expect(result.isEmpty)
        #expect(repo.receivedSearchQuery == nil)
    }

    @Test func exatamente3CaracteresChamaORepositorio() async throws {
        let (sut, repo) = makeSUT(searchResult: ["São Paulo"])
        let result = try await sut.execute(.init(query: "São"))
        #expect(result == ["São Paulo"])
        #expect(repo.receivedSearchQuery == "São")
    }

    @Test func queryVaziaNaoChamaORepositorio() async throws {
        let (sut, repo) = makeSUT()
        _ = try await sut.execute(.init(query: ""))
        #expect(repo.receivedSearchQuery == nil)
    }
}
