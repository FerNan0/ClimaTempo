import Foundation

// MARK: - Implementação concreta do IARepositoryProtocol
//
// Roteamento em duas camadas (Privacy by Design):
//   1. FoundationModels (on-device, iOS 26+) — sem tráfego de rede
//   2. OpenAI GPT-3.5 (nuvem) — fallback automático
//
// Bridging completion → async/await via withCheckedContinuation.

final class IARepository: IARepositoryProtocol {
    private let apiKey: String
    private let endpoint = "https://api.openai.com/v1/chat/completions"
    private let client: NetworkClient

    init(client: NetworkClient = NetworkClient(), apiKey: String = Secrets.openAIKey) {
        self.client = client
        self.apiKey = apiKey
    }

    // MARK: - Protocolo público (async)

    func suggestClothing(weather: Weather) async -> String? {
        let data = WeatherData(from: weather)
        return await route(
            onDevice: { FoundationModelsService.shared.suggestClothing(weather: data, completion: $0) },
            cloudPrompt: """
            Sugira roupas para uma pessoa sair de casa considerando:
            Temperatura: \(Int(weather.temperature))°C
            Condição: \(weather.condition)
            Responda em português, de forma simples. Máximo 1 frase. Comece com um emoji.
            """,
            maxTokens: 50
        )
    }

    func suggestActivity(weather: Weather) async -> String? {
        let data = WeatherData(from: weather)
        return await route(
            onDevice: { FoundationModelsService.shared.suggestActivity(weather: data, completion: $0) },
            cloudPrompt: """
            Sugira atividades divertidas para fazer hoje considerando:
            Temperatura: \(Int(weather.temperature))°C
            Condição: \(weather.condition)
            Umidade: \(weather.humidity)%
            Responda em português, de forma simples e motivadora. Máximo 1 frase. Comece com um emoji.
            """,
            maxTokens: 50
        )
    }

    func getWeatherAlert(weather: Weather) async -> String? {
        let data = WeatherData(from: weather)
        return await route(
            onDevice: { FoundationModelsService.shared.getWeatherAlert(weather: data, completion: $0) },
            cloudPrompt: """
            Gere um alerta importante para o usuário considerando:
            Temperatura: \(Int(weather.temperature))°C
            Condição: \(weather.condition)
            Vento: \(String(format: "%.1f", weather.windSpeed)) km/h
            Umidade: \(weather.humidity)%
            Se não houver perigo, retorne "OK".
            Se houver algum cuidado, responda em português de forma simples. Máximo 1 frase.
            """,
            maxTokens: 30
        )
    }

    func explainWeather(weather: Weather) async -> String? {
        let data = WeatherData(from: weather)
        return await route(
            onDevice: { FoundationModelsService.shared.explainWeather(weather: data, completion: $0) },
            cloudPrompt: """
            Explique de forma simples e acessível o seguinte clima para uma pessoa com deficiência cognitiva:
            Cidade: \(weather.city)
            Temperatura: \(Int(weather.temperature))°C
            Condição: \(weather.condition)
            Seja breve, claro e use palavras simples. Máximo 2 frases.
            """,
            maxTokens: 100
        )
    }

    func generateDetailedRecommendation(city: String, weather: Weather, simplified: Bool) async -> String? {
        let data = WeatherData(from: weather)
        return await route(
            onDevice: {
                FoundationModelsService.shared.generateDetailedRecommendation(
                    city: city, weather: data, simplified: simplified, completion: $0
                )
            },
            cloudPrompt: detailedRecommendationPrompt(city: city, weather: weather, simplified: simplified),
            maxTokens: 300
        )
    }

    func generateDynamicActivities(city: String, weather: Weather, simplified: Bool) async -> String? {
        let data = WeatherData(from: weather)
        return await route(
            onDevice: {
                FoundationModelsService.shared.generateDynamicActivities(
                    city: city, weather: data, simplified: simplified, completion: $0
                )
            },
            cloudPrompt: dynamicActivitiesPrompt(city: city, weather: weather, simplified: simplified),
            maxTokens: 250
        )
    }

    func generateStructuredActivities(city: String, weather: Weather, simplified: Bool) async -> [StructuredActivity]? {
        // Guided Generation só existe on-device (iOS 26+). Sem isso, retorna nil
        // e o chamador usa o caminho de texto (que roteia para OpenAI).
        guard isFoundationModelsAvailable() else { return nil }
        let data = WeatherData(from: weather)
        return await FoundationModelsService.shared.generateStructuredActivities(
            city: city, weather: data, simplified: simplified
        )
    }

    func generateSimplifiedAdvice(weather: Weather) async -> SimplifiedAdvice? {
        // Conselho simples só via Guided Generation on-device (iOS 26+).
        guard isFoundationModelsAvailable() else { return nil }
        let data = WeatherData(from: weather)
        return await FoundationModelsService.shared.generateSimplifiedAdvice(weather: data)
    }

    // MARK: - Roteamento interno

    private func route(
        onDevice: @escaping (@escaping (String?) -> Void) -> Void,
        cloudPrompt: String,
        maxTokens: Int
    ) async -> String? {
        if isFoundationModelsAvailable() {
            // Ponte completion-handler → async/await.
            // INVARIANTE: `onDevice` DEVE chamar o completion exatamente uma vez.
            // FoundationModelsService.generate garante isso (sucesso, erro ou fallback).
            // Chamar duas vezes = crash "continuation resumed twice".
            let result = await withCheckedContinuation { continuation in
                onDevice { continuation.resume(returning: $0) }
            }
            if let result { return result }
        }
        return await fetchFromOpenAI(prompt: cloudPrompt, maxTokens: maxTokens)
    }

    // MARK: - OpenAI (async)

    private func fetchFromOpenAI(prompt: String, maxTokens: Int) async -> String? {
        let body: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [["role": "user", "content": prompt]],
            "max_tokens": maxTokens,
            "temperature": 0.7
        ]

        guard let bodyData = try? JSONSerialization.data(withJSONObject: body) else { return nil }

        do {
            let response: OpenAIResponse = try await client.post(
                endpoint,
                headers: [
                    "Authorization": "Bearer \(apiKey)",
                    "Content-Type": "application/json"
                ],
                body: bodyData
            )
            return response.choices.first?.message.content
        } catch {
            return nil
        }
    }

    // MARK: - Prompts detalhados

    private func detailedRecommendationPrompt(city: String, weather: Weather, simplified: Bool) -> String {
        if simplified {
            return """
            Você fala de forma MUITO SIMPLES, como para uma criança de 10 anos.
            CLIMA AGORA em \(city): \(Int(weather.temperature))°C, sensação \(Int(weather.feelsLike))°C, \(weather.description.capitalized), vento \(String(format: "%.1f", weather.windSpeed)) km/h, umidade \(weather.humidity)%.
            REGRAS: frases curtas (máx 10 palavras), emojis, 1 ideia por linha.
            Responda (máx 150 palavras):
            🌡️ Como está o tempo (1 frase)
            👕 O que vestir (2-3 itens)
            ✅ O que fazer (2-3 atividades)
            ⚠️ Cuidados (1-2 avisos, se necessário)
            """
        }
        return """
        Você é um assistente amigável de clima. Gere recomendações detalhadas e práticas.
        📍 Cidade: \(city) | 🌡️ Temperatura: \(Int(weather.temperature))°C | Sensação: \(Int(weather.feelsLike))°C
        🌤️ Condição: \(weather.description.capitalized) | 💨 Vento: \(String(format: "%.1f", weather.windSpeed)) km/h
        💧 Umidade: \(weather.humidity)% | ☀️ UV: \(weather.uvIndex)
        Inclua: o que vestir, atividades, cuidados especiais. Máximo 300 palavras. Português do Brasil.
        """
    }

    private func dynamicActivitiesPrompt(city: String, weather: Weather, simplified: Bool) -> String {
        if simplified {
            return """
            Liste 5 atividades para \(city) com \(Int(weather.temperature))°C e \(weather.description.capitalized).
            Formato: emoji Nome (Fácil/Moderado/Intenso) — explicação simples
            Máximo 150 palavras. Apenas a lista.
            """
        }
        return """
        Atividades em \(city) com \(Int(weather.temperature))°C, \(weather.description.capitalized), umidade \(weather.humidity)%, UV \(weather.uvIndex).
        Liste 6-8 atividades específicas para essa cidade e clima.
        Formato: emoji Atividade — motivo breve. Máximo 250 palavras.
        """
    }
}
