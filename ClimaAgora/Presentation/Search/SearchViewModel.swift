import Foundation

// MARK: - SearchViewModel
// Depende da interface SearchCitiesUseCaseProtocol.
// "Selecionar cidade" é a ação de rota desta tela (callback p/ a Home).

@MainActor
final class SearchViewModel: ObservableObject {

    enum State: Equatable {
        case idle
        case loading
        case loaded
    }

    @Published private(set) var state: State = .idle
    @Published private(set) var searchResults: [String] = []

    private let useCase: SearchCitiesUseCaseProtocol
    private let onCitySelected: (String) -> Void

    init(useCase: SearchCitiesUseCaseProtocol, onCitySelected: @escaping (String) -> Void) {
        self.useCase = useCase
        self.onCitySelected = onCitySelected
    }

    func search(_ query: String) {
        // Atalho de UX: nem dispara a Task com menos de 3 chars.
        // A regra "mínimo 3" mora no SearchCitiesUseCase (fonte da verdade).
        guard query.count >= 3 else {
            searchResults = []
            state = .idle
            return
        }
        state = .loading
        Task {
            searchResults = (try? await useCase.execute(.init(query: query))) ?? []
            state = .loaded
        }
    }

    func selectCity(_ city: String) {
        onCitySelected(city)
    }
}
