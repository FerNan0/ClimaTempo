import Foundation

class SearchHistoryManager {
    static let shared = SearchHistoryManager()
    private let historyKey = "search_history"
    private let maxHistory = 10
    
    // MARK: - Obter Histórico de Busca
    func getSearchHistory() -> [String] {
        return UserDefaults.standard.stringArray(forKey: historyKey) ?? []
    }
    
    // MARK: - Adicionar ao Histórico
    func addSearch(_ city: String) {
        var history = getSearchHistory()
        
        // Remove se já existe (para evitar duplicatas)
        history.removeAll { $0 == city }
        
        // Adiciona no início
        history.insert(city, at: 0)
        
        // Mantém apenas os últimos 10
        if history.count > maxHistory {
            history = Array(history.prefix(maxHistory))
        }
        
        UserDefaults.standard.set(history, forKey: historyKey)
    }
    
    // MARK: - Limpar Histórico
    func clearHistory() {
        UserDefaults.standard.removeObject(forKey: historyKey)
    }
}
