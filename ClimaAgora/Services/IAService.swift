import Foundation

// MARK: - OpenAI Response Model
struct OpenAIResponse: Decodable {
    let choices: [Choice]
    struct Choice: Decodable {
        let message: Message
        struct Message: Decodable {
            let content: String
        }
    }
}

class IAService {
    static let shared = IAService()
    private let apiKey = Secrets.openAIKey
    private let endpoint = "https://api.openai.com/v1/chat/completions"
    
    // MARK: - Explicação do Clima
    func explainWeather(weather: Weather, completion: @escaping (String?) -> Void) {
        let prompt = """
        Explique de forma simples e acessível o seguinte clima para uma pessoa com deficiência cognitiva:
        Cidade: \(weather.city)
        Temperatura: \(Int(weather.temperature))°C
        Condição: \(weather.condition)
        Descrição: \(weather.description)
        
        Seja breve, claro e use palavras simples. Máximo 2 frases.
        """
        
        fetchFromOpenAI(prompt: prompt, maxTokens: 100, completion: completion)
    }
    
    // MARK: - Sugestão de Roupa
    func suggestClothing(weather: Weather, completion: @escaping (String?) -> Void) {
        let prompt = """
        Sugira roupas para uma pessoa sair de casa considerando:
        Temperatura: \(Int(weather.temperature))°C
        Condição: \(weather.condition)
        
        Responda em português, de forma simples. Máximo 1 frase. Comece com um emoji apropriado.
        """
        
        fetchFromOpenAI(prompt: prompt, maxTokens: 50, completion: completion)
    }
    
    // MARK: - Sugestão de Atividade
    func suggestActivity(weather: Weather, completion: @escaping (String?) -> Void) {
        let prompt = """
        Sugira atividades divertidas para fazer hoje considerando:
        Temperatura: \(Int(weather.temperature))°C
        Condição: \(weather.condition)
        Umidade: \(weather.humidity)%
        
        Responda em português, de forma simples e motivadora. Máximo 1 frase. Comece com um emoji.
        """
        
        fetchFromOpenAI(prompt: prompt, maxTokens: 50, completion: completion)
    }
    
    // MARK: - Alerta Inteligente
    func getWeatherAlert(weather: Weather, completion: @escaping (String?) -> Void) {
        let prompt = """
        Gere um alerta importante para o usuário considerando:
        Temperatura: \(Int(weather.temperature))°C
        Condição: \(weather.condition)
        Vento: \(String(format: "%.1f", weather.windSpeed)) km/h
        Umidade: \(weather.humidity)%
        
        Se não houver perigo, retorne "OK".
        Se houver algum cuidado, responda em português de forma simples. Máximo 1 frase.
        """
        
        fetchFromOpenAI(prompt: prompt, maxTokens: 30, completion: completion)
    }
    
    // MARK: - Chamada Customizada OpenAI
    func fetchCustom(prompt: String, maxTokens: Int, completion: @escaping (String?) -> Void) {
        fetchFromOpenAI(prompt: prompt, maxTokens: maxTokens, completion: completion)
    }
    
    // MARK: - Recomendação Detalhada com IA
    func generateDetailedRecommendation(city: String, weather: Weather, simplified: Bool = false, completion: @escaping (String?) -> Void) {
        let weatherDescription = weather.description.capitalized
        
        let prompt: String
        if simplified {
            prompt = """
            Você é um assistente de clima que fala de forma MUITO SIMPLES e CLARA, como se explicasse para uma criança de 10 anos ou uma pessoa com dificuldade de compreensão.

            CLIMA AGORA em \(city):
            - Temperatura: \(Int(weather.temperature))°C
            - Sensação: \(Int(weather.feelsLike))°C
            - Tempo: \(weatherDescription)
            - Vento: \(String(format: "%.1f", weather.windSpeed)) km/h
            - Umidade: \(weather.humidity)%

            REGRAS IMPORTANTES:
            - Use frases CURTAS (máximo 10 palavras cada)
            - Use palavras SIMPLES do dia a dia
            - Use emojis para ilustrar cada dica
            - Organize em tópicos com APENAS 1 ideia por linha
            - NÃO use palavras difíceis ou técnicas
            - Comece com "Hoje o dia está..." em 1 frase simples

            Responda com estas seções:
            🌡️ Como está o tempo (1 frase simples)
            👕 O que vestir (2-3 itens simples)
            ✅ O que fazer (2-3 atividades simples)
            ⚠️ Cuidados (1-2 avisos simples, se necessário)

            Máximo 150 palavras.
            """
        } else {
            prompt = """
            Você é um assistente amigável e acessível de clima. Gere recomendações detalhadas e práticas para a pessoa considerando as condições climáticas.

            INFORMAÇÕES DO CLIMA:
            📍 Cidade: \(city)
            🌡️ Temperatura: \(Int(weather.temperature))°C
            🤔 Sensação térmica: \(Int(weather.feelsLike))°C
            🌤️ Condição: \(weatherDescription)
            💨 Vento: \(String(format: "%.1f", weather.windSpeed)) km/h
            💧 Umidade: \(weather.humidity)%
            ☀️ Índice UV: \(weather.uvIndex)

            Por favor, forneça recomendações em português brasileiro de forma:
            1. Empática e amigável
            2. Prática e acionável
            3. Organizada em categorias claras
            4. Com dicas específicas para o clima atual

            Inclua sugestões sobre:
            - O que vestir
            - Atividades recomendadas
            - Cuidados especiais (protetor solar, hidratação, etc.)
            - Atividades a evitar (se relevante)
            - Dicas locais para aproveitar o dia

            Seja conciso mas informativo (máximo 300 palavras).
            """
        }
        
        fetchFromOpenAI(prompt: prompt, maxTokens: 300) { result in
            completion(result)
        }
    }
    
    // MARK: - Atividades Dinâmicas baseadas em Clima
    func generateDynamicActivities(city: String, weather: Weather, simplified: Bool = false, completion: @escaping (String?) -> Void) {
        let weatherDescription = weather.description.capitalized
        
        let prompt: String
        if simplified {
            prompt = """
            Liste atividades para fazer em \(city) com \(Int(weather.temperature))°C e \(weatherDescription).

            REGRAS PARA RESPONDER:
            - Use frases CURTAS e SIMPLES
            - Cada atividade deve ter: emoji + nome curto + por que é bom
            - Use palavras fáceis de entender
            - Coloque um nível de esforço: (Fácil), (Moderado) ou (Intenso)
            - Liste exatamente 5 atividades
            
            Formato de cada linha:
            emoji Nome da Atividade (Nível) - Explicação simples de por quê

            Exemplo:
            🚶 Caminhada no parque (Fácil) - Bom para relaxar com esse tempo agradável
            
            Máximo 150 palavras. Apenas a lista, sem introdução.
            """
        } else {
            prompt = """
            O que se tem pra fazer em \(city) com \(Int(weather.temperature))°C e as seguintes condições climáticas?

            CONDIÇÕES CLIMÁTICAS ATUAIS:
            - Temperatura: \(Int(weather.temperature))°C
            - Sensação térmica: \(Int(weather.feelsLike))°C
            - Condição: \(weatherDescription)
            - Umidade: \(weather.humidity)%
            - Vento: \(String(format: "%.1f", weather.windSpeed)) km/h
            - Índice UV: \(weather.uvIndex)
            - Visibilidade: \(String(format: "%.1f", Double(weather.visibility) / 1000)) km

            Considere as atrações turísticas, atividades locais e características únicas de \(city).
            Responda com uma LISTA de 6-8 atividades ESPECÍFICAS E REALISTAS para essa cidade com esse clima.
            
            Formato: 🏃 Atividade Específica - Descrição breve do por quê é boa para esse clima
            
            Seja entusiasmado, prático e recomende atividades que fazem sentido com o clima atual.
            Máximo 250 palavras.
            """
        }
        
        fetchFromOpenAI(prompt: prompt, maxTokens: 250) { result in
            completion(result)
        }
    }
    
    // MARK: - Chamada Genérica OpenAI
    private func fetchFromOpenAI(prompt: String, maxTokens: Int, completion: @escaping (String?) -> Void) {
        let body: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [["role": "user", "content": prompt]],
            "max_tokens": maxTokens,
            "temperature": 0.7
        ]
        
        guard let url = URL(string: endpoint),
              let httpBody = try? JSONSerialization.data(withJSONObject: body) else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 15.0
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Erro de conexão OpenAI: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    if let data = data, let errorResponse = String(data: data, encoding: .utf8) {
                        print("Erro OpenAI (\(httpResponse.statusCode)): \(errorResponse)")
                    }
                    completion(nil)
                    return
                }
            }
            
            guard let data = data else {
                completion(nil)
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(OpenAIResponse.self, from: data)
                let explanation = decoded.choices.first?.message.content
                DispatchQueue.main.async {
                    completion(explanation)
                }
            } catch {
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Erro ao decodificar OpenAI: \(error). Resposta: \(responseString.prefix(200))")
                }
                completion(nil)
            }
        }.resume()
    }
}
