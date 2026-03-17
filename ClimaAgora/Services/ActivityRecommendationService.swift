import Foundation

class ActivityRecommendationService {
    static let shared = ActivityRecommendationService()
    
    private init() {}
    
    // MARK: - Dados de Atividades por Cidade
    let cityActivities: [String: [String]] = [
        // São Paulo
        "São Paulo": ["museus", "teatro", "gastronomia", "shoppings", "vida noturna"],
        "Campinas": ["museus", "gastronomia", "parques"],
        "Sorocaba": ["ecoturismo", "trilhas", "pesca"],
        "São Miguel Arcanjo": ["trilhas", "cachoeiras", "pousadas rurais"],
        "Itu": ["turismo histórico", "gastronomia"],
        
        // Paraná - Esportes radicais
        "Boituva": ["salto de paraquedas", "voo livre", "parapente"],
        "Curitiba": ["museus", "parques", "gastronomia"],
        "Foz do Iguaçu": ["turismo de natureza", "rafting", "tirolesa"],
        
        // Santa Catarina
        "Florianópolis": ["praias", "surfe", "mergulho", "trilhas"],
        "Blumenau": ["trilhas", "cachoeiras", "esportes aquáticos"],
        "Brusque": ["cicloturismo", "trilhas", "esportes aquáticos"],
        "Bombinhas": ["praias", "mergulho", "surfe"],
        "Balneário Camboriú": ["praias", "parques aquáticos", "gastronomia"],
        
        // Rio de Janeiro
        "Rio de Janeiro": ["montanhismo", "surfe", "voo livre", "parapente", "trilhas"],
        "Niterói": ["praias", "museus", "trilhas"],
        "Paraty": ["trilhas", "turismo de natureza", "mergulho"],
        "Angra dos Reis": ["praias", "mergulho", "trilhas"],
        
        // Minas Gerais
        "Belo Horizonte": ["gastronomia", "museus", "shows"],
        "Ouro Preto": ["turismo histórico", "trilhas"],
        "Divinópolis": ["turismo industrial", "trilhas"],
        "Tiradentes": ["turismo histórico", "gastronomia"],
        
        // Ceará
        "Fortaleza": ["kitesurf", "surfe", "mergulho", "praias"],
        "Jericoacoara": ["kitesurf", "trekking", "praias"],
        "Canoa Quebrada": ["praias", "esportes aquáticos"],
        
        // Bahia
        "Salvador": ["praias", "turismo cultural", "mergulho"],
        "Ilhéus": ["praias", "ecoturismo", "cacau"],
        "Maragogipe": ["ecoturismo", "turismo rural"],
        
        // Pernambuco
        "Recife": ["praias", "turismo cultural", "mergulho"],
        "Porto de Galinhas": ["praias", "mergulho", "passeios de jangada"],
        
        // Amazonas
        "Manaus": ["trekking na selva", "turismo de natureza", "observação de fauna"],
        
        // Rio Grande do Sul
        "Porto Alegre": ["museus", "gastronomia", "parques"],
        "Gramado": ["ecoturismo", "trilhas", "gastronomia"],
        "Canela": ["trilhas", "cachoeiras", "ecoturismo"],
        
        // Goiás
        "Pirenópolis": ["trilhas", "cachoeiras", "turismo rural"],
        "Goiânia": ["museus", "parques", "gastronomia"],
        
        // Espírito Santo
        "Vitória": ["praias", "parques", "gastronomia"],
        
        // Internacional
        "Nova York": ["cultura", "gastronomia", "museus"],
        "Paris": ["turismo cultural", "gastronomia", "museus"],
        "Tóquio": ["turismo cultural", "gastronomia", "eletrônica"],
        "Barcelona": ["praias", "arquitetura", "gastronomia"],
        "Ibiza": ["praias", "vida noturna", "esportes aquáticos"],
    ]
    
    // MARK: - Categoria de Esportes com Status
    let sportCategories: [String: SportCategory] = [
        "salto de paraquedas": SportCategory(
            name: "Salto de Paraquedas",
            categories: ["A", "B", "C", "D", "E"],
            description: "Conforme classificação CBPQ",
            regulatoryBody: "CBPQ - Confederação Brasileira de Paraquedismo",
            siteReference: "https://www.cbpq.org.br/"
        ),
        "voo livre": SportCategory(
            name: "Voo Livre",
            categories: ["Iniciante", "Intermediário", "Avançado"],
            description: "Parapente e Asa Delta",
            regulatoryBody: "CBVL - Confederação Brasileira de Voo Livre",
            siteReference: "https://www.cbvl.org.br/"
        ),
        "parapente": SportCategory(
            name: "Parapente",
            categories: ["Iniciante", "Intermediário", "Avançado"],
            description: "Parapente",
            regulatoryBody: "CBVL - Confederação Brasileira de Voo Livre",
            siteReference: "https://www.cbvl.org.br/"
        ),
        "surfe": SportCategory(
            name: "Surfe",
            categories: ["Infantil", "Juvenil", "Amador", "Profissional"],
            description: "Esporte aquático em ondas",
            regulatoryBody: "CBSU - Confederação Brasileira de Surfe",
            siteReference: "https://www.cbsurf.com.br/"
        ),
        "kitesurf": SportCategory(
            name: "Kitesurf",
            categories: ["Iniciante", "Intermediário", "Avançado"],
            description: "Esporte aquático com pipa",
            regulatoryBody: "CBKS - Confederação Brasileira de Kitesurf",
            siteReference: "https://www.cbks.org.br/"
        ),
        "rafting": SportCategory(
            name: "Rafting",
            categories: ["Iniciante", "Intermediário", "Avançado"],
            description: "Descida de rios com bote",
            regulatoryBody: "ABRF - Associação Brasileira de Rafting",
            siteReference: "https://www.abrf.org.br/"
        ),
        "mergulho": SportCategory(
            name: "Mergulho",
            categories: ["Open Water", "Advanced", "Master", "Profissional"],
            description: "Mergulho autônomo",
            regulatoryBody: "PADI / DAN",
            siteReference: "https://www.padi.com/"
        ),
        "trilhas": SportCategory(
            name: "Trilhas e Trekking",
            categories: ["Leve", "Moderado", "Pesado"],
            description: "Caminhadas em trilhas",
            regulatoryBody: "ABNT / Órgãos de Conservação",
            siteReference: "https://www.abnt.org.br/"
        ),
    ]
    
    // MARK: - Obter Atividades Recomendadas
    func getActivitiesForCity(_ city: String, completion: @escaping (ActivityRecommendation?) -> Void) {
        // Limpar o nome da cidade (remover estado/país)
        let cityName = city.components(separatedBy: ",").first?.trimmingCharacters(in: .whitespaces) ?? city
        
        // Procurar por correspondência exata ou por aproximação
        var activities = cityActivities[cityName]
        
        // Se não encontrar correspondência exata, tentar correspondência insensível a maiúsculas/minúsculas
        if activities == nil {
            activities = cityActivities.first { key, _ in
                key.lowercased() == cityName.lowercased()
            }?.value
        }
        
        // Se ainda não encontrar, procurar por aproximação (começo do nome)
        if activities == nil {
            activities = cityActivities.first { key, _ in
                key.lowercased().contains(cityName.lowercased()) || cityName.lowercased().contains(key.lowercased())
            }?.value
        }
        
        // Se não encontrar no banco de dados, retornar recomendações genéricas
        let finalActivities = activities ?? ["turismo", "gastronomia", "cultura", "natureza", "aventura"]
        let actualCityName = cityName
        
        let recommendation = ActivityRecommendation(
            city: actualCityName,
            activities: finalActivities,
            sportCategories: getSportCategoriesForActivities(finalActivities),
            weatherSuitability: [:],
            similarCities: findSimilarCities(for: actualCityName, mainActivities: finalActivities)
        )
        
        completion(recommendation)
    }
    
    // MARK: - Encontrar Cidades Similares
    func findSimilarCities(for city: String, mainActivities: [String]) -> [SimilarCity] {
        var similar: [SimilarCity] = []
        
        for (otherCity, otherActivities) in cityActivities {
            if otherCity == city { continue }
            
            let matchingActivities = mainActivities.filter { activity in
                otherActivities.contains(where: { $0.lowercased().contains(activity.lowercased()) })
            }
            
            if !matchingActivities.isEmpty {
                let similarity = Double(matchingActivities.count) / Double(mainActivities.count)
                similar.append(SimilarCity(
                    name: otherCity,
                    matchingActivities: matchingActivities,
                    similarityScore: similarity
                ))
            }
        }
        
        // Ordenar por similaridade
        return similar.sorted { $0.similarityScore > $1.similarityScore }.prefix(5).map { $0 }
    }
    
    // MARK: - Obter Categorias de Esporte
    private func getSportCategoriesForActivities(_ activities: [String]) -> [String: SportCategory] {
        var categories: [String: SportCategory] = [:]
        
        for activity in activities {
            let key = activity.lowercased()
            if let category = sportCategories[key] {
                categories[activity] = category
            }
        }
        
        return categories
    }
    
    // MARK: - Buscar Atividades via IA (fallback)
    private func fetchActivitiesFromAI(for city: String, completion: @escaping (ActivityRecommendation?) -> Void) {
        let prompt = """
        Liste as 5 principais atividades turísticas e esportes praticados em \(city).
        Responda em JSON com formato: {"activities": ["atividade1", "atividade2", ...]}
        """
        
        IAService.shared.fetchCustom(prompt: prompt, maxTokens: 100) { response in
            if let response = response {
                print("Atividades sugeridas pela IA: \(response)")
            }
            completion(nil)
        }
    }
}

// MARK: - Modelos

struct ActivityRecommendation {
    let city: String
    let activities: [String]
    let sportCategories: [String: SportCategory]
    let weatherSuitability: [String: WeatherSuitability]
    let similarCities: [SimilarCity]
}

struct SportCategory {
    let name: String
    let categories: [String]
    let description: String
    let regulatoryBody: String
    let siteReference: String
}

struct SimilarCity {
    let name: String
    let matchingActivities: [String]
    let similarityScore: Double
}

struct WeatherSuitability {
    let activity: String
    let temperature: String
    let windSpeed: String
    let rainfall: String
    let suitabilityScore: Double
}
