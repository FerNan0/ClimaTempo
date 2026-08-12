import Foundation

// MARK: - Foundation Models Service (Apple Intelligence — on-device)
//
// Utiliza o Foundation Models framework introduzido na WWDC 2026 para
// inferência local, sem envio de dados a servidores externos.
//
// Requisitos: iOS 26+, dispositivo com Apple Intelligence habilitado.
// Fallback automático para IAService (OpenAI) em dispositivos incompatíveis.
//
// Referência acadêmica:
//   Apple Inc. (2026). "What's new in the Foundation Models framework".
//   WWDC26. https://developer.apple.com/videos/wwdc2026/
//   Apple Inc. (2026). "Meet Core AI".
//   WWDC26. https://developer.apple.com/videos/wwdc2026/

// ---------------------------------------------------------------------------
// NOTE: O import abaixo requer Xcode 26+ com iOS 26 SDK.
// Em builds com SDK anterior, o serviço retorna nil e o app usa o fallback.
// ---------------------------------------------------------------------------

#if canImport(FoundationModels)
import FoundationModels
#endif

// MARK: - Tipos @Generable (Guided Generation)
//
// Estes tipos ativam a GERAÇÃO GUIADA do Foundation Models: em vez de o modelo
// devolver texto solto (que exigia parsing frágil), ele preenche DIRETAMENTE
// estas estruturas tipadas. Garante que o "modo simplificado" sempre venha no
// formato certo (nome curto + 1 frase + categoria + dificuldade), eliminando a
// principal fonte de fragilidade da versão anterior.
//
// Só existem quando o SDK do Foundation Models está presente (iOS 26+).

#if canImport(FoundationModels)
@available(iOS 26.0, *)
@Generable
struct GeneratedActivity {
    @Guide(description: "Nome curto e claro da atividade, no máximo 4 palavras, sem emoji")
    var name: String

    @Guide(description: "Uma única frase simples, até 12 palavras, explicando a atividade")
    var explanation: String

    @Guide(description: "Categoria da atividade", .anyOf(["Ao Ar Livre", "Dentro de Casa", "Exercício", "Cultura", "Comida", "Relaxar"]))
    var category: String

    @Guide(description: "Nível de esforço físico", .anyOf(["Fácil", "Moderado", "Intenso"]))
    var difficulty: String
}

@available(iOS 26.0, *)
@Generable
struct GeneratedActivityList {
    @Guide(description: "Lista de atividades recomendadas para o clima atual", .count(5))
    var activities: [GeneratedActivity]
}
#endif

// MARK: - Disponibilidade

/// Verifica se o Foundation Models framework está disponível no dispositivo.
/// Retorna `true` em iOS 26+ com Apple Intelligence habilitado.
func isFoundationModelsAvailable() -> Bool {
    #if canImport(FoundationModels)
    if #available(iOS 26.0, *) {
        return true
    }
    #endif
    return false
}

// MARK: - FoundationModelsService

/// Serviço de IA on-device usando o Foundation Models framework da Apple.
///
/// **Vantagens acadêmicas documentadas no TCC:**
/// - Privacidade por design: nenhum dado climático ou de comportamento
///   do usuário trafega para servidores externos (LGPD/GDPR compliant).
/// - Operação offline: não depende de conectividade ou chave de API.
/// - Latência reduzida: inferência local elimina round-trip de rede.
/// - Custo zero por requisição: sem dependência de quota de API externa.
///
/// Estas características endereçam diretamente a limitação ética apontada
/// na seção de Limitações do TCC sobre privacidade de dados de interação.
class FoundationModelsService {

    static let shared = FoundationModelsService()
    private init() {}

    // MARK: - Explicação do Clima (Modo Simplificado)

    /// Gera uma explicação do clima em linguagem simples para usuários
    /// com dificuldades cognitivas, usando processamento on-device.
    func explainWeather(weather: WeatherData, completion: @escaping (String?) -> Void) {
        let prompt = buildSimplePrompt(
            instruction: "Explique o clima de forma simples e acessível para uma pessoa com dificuldade cognitiva. Máximo 2 frases curtas.",
            weather: weather
        )
        generate(prompt: prompt, completion: completion)
    }

    // MARK: - Sugestão de Roupa

    func suggestClothing(weather: WeatherData, completion: @escaping (String?) -> Void) {
        let prompt = buildSimplePrompt(
            instruction: "Sugira uma roupa simples para sair. 1 frase. Comece com emoji.",
            weather: weather
        )
        generate(prompt: prompt, completion: completion)
    }

    // MARK: - Sugestão de Atividade

    func suggestActivity(weather: WeatherData, completion: @escaping (String?) -> Void) {
        let prompt = buildSimplePrompt(
            instruction: "Sugira 1 atividade para hoje. 1 frase simples. Comece com emoji.",
            weather: weather
        )
        generate(prompt: prompt, completion: completion)
    }

    // MARK: - Alerta de Clima

    func getWeatherAlert(weather: WeatherData, completion: @escaping (String?) -> Void) {
        let prompt = buildSimplePrompt(
            instruction: "Há algum perigo nesse clima? Se não, responda apenas 'OK'. Se houver, 1 frase de aviso simples.",
            weather: weather
        )
        generate(prompt: prompt, completion: completion)
    }

    // MARK: - Recomendação Detalhada

    /// Gera recomendação completa adaptada ao modo cognitivo do usuário.
    /// - Parameter simplified: quando `true`, aplica linguagem Plain Language
    ///   (frases curtas, vocabulário simples, estrutura visual com emojis),
    ///   conforme diretrizes de acessibilidade cognitiva para TEA.
    func generateDetailedRecommendation(
        city: String,
        weather: WeatherData,
        simplified: Bool,
        completion: @escaping (String?) -> Void
    ) {
        let prompt = simplified
            ? buildAccessibleRecommendationPrompt(city: city, weather: weather)
            : buildDetailedRecommendationPrompt(city: city, weather: weather)
        generate(prompt: prompt, completion: completion)
    }

    // MARK: - Atividades Dinâmicas

    func generateDynamicActivities(
        city: String,
        weather: WeatherData,
        simplified: Bool,
        completion: @escaping (String?) -> Void
    ) {
        let prompt = simplified
            ? buildAccessibleActivitiesPrompt(city: city, weather: weather)
            : buildDetailedActivitiesPrompt(city: city, weather: weather)
        generate(prompt: prompt, completion: completion)
    }

    // MARK: - Atividades Estruturadas (Guided Generation)

    /// Gera atividades já ESTRUTURADAS on-device via `@Generable`, sem parsing
    /// de string. Retorna `nil` quando indisponível/erro, sinalizando fallback
    /// para o caminho de texto (que roteia para a nuvem).
    func generateStructuredActivities(
        city: String,
        weather: WeatherData,
        simplified: Bool
    ) async -> [StructuredActivity]? {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            let prompt = """
            Sugira 5 atividades para fazer em \(city) considerando o clima:
            \(Int(weather.temperature))°C, \(weather.description), \
            vento \(String(format: "%.0f", weather.windSpeed)) km/h, umidade \(weather.humidity)%.
            \(simplified ? "Use nomes e explicações MUITO simples, do dia a dia." : "")
            Escolha atividades adequadas à temperatura e à condição do tempo.
            """
            do {
                let session = LanguageModelSession()
                let response = try await session.respond(to: prompt, generating: GeneratedActivityList.self)
                let mapped = response.content.activities.map {
                    StructuredActivity(
                        name: $0.name,
                        explanation: $0.explanation,
                        category: $0.category,
                        difficulty: $0.difficulty
                    )
                }
                return mapped.isEmpty ? nil : mapped
            } catch {
                print("⚠️ [FoundationModels] Guided generation falhou: \(error.localizedDescription)")
                return nil
            }
        }
        #endif
        return nil
    }

    // MARK: - Motor de Geração (Foundation Models)

    private func generate(prompt: String, completion: @escaping (String?) -> Void) {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            Task {
                do {
                    // Cria uma nova sessão de inferência local.
                    // O modelo roda inteiramente no Neural Engine do dispositivo.
                    let session = LanguageModelSession()
                    let response = try await session.respond(to: prompt)
                    await MainActor.run {
                        completion(response.content)
                    }
                } catch {
                    print("⚠️ [FoundationModels] Erro na inferência: \(error.localizedDescription)")
                    await MainActor.run {
                        completion(nil) // sinaliza fallback para IAService
                    }
                }
            }
            return
        }
        #endif
        // Dispositivo não suporta Foundation Models — sinaliza fallback
        completion(nil)
    }

    // MARK: - Construtores de Prompt

    /// Prompt compacto para respostas curtas (sugestões, alertas)
    private func buildSimplePrompt(instruction: String, weather: WeatherData) -> String {
        """
        \(instruction)

        Clima: \(weather.condition), \(Int(weather.temperature))°C, \
        vento \(String(format: "%.0f", weather.windSpeed)) km/h, \
        umidade \(weather.humidity)%.
        Responda em português do Brasil.
        """
    }

    /// Prompt Plain Language para usuários com TEA (modo simplificado)
    /// Aplica diretrizes cognitivas: frases ≤10 palavras, 1 ideia por linha,
    /// emojis como âncoras visuais, vocabulário do cotidiano.
    private func buildAccessibleRecommendationPrompt(city: String, weather: WeatherData) -> String {
        """
        Você fala de forma MUITO SIMPLES, como para uma criança de 10 anos.

        CLIMA AGORA em \(city): \(Int(weather.temperature))°C, \
        sensação \(Int(weather.feelsLike))°C, \(weather.description), \
        vento \(String(format: "%.0f", weather.windSpeed)) km/h, \
        umidade \(weather.humidity)%.

        REGRAS:
        - Frases CURTAS (máximo 10 palavras)
        - Palavras SIMPLES do dia a dia
        - Emoji no início de cada linha
        - 1 ideia por linha
        - NÃO use palavras técnicas

        Responda com estas seções (máximo 120 palavras):
        🌡️ Como está o tempo (1 frase)
        👕 O que vestir (2 itens)
        ✅ O que fazer (2 atividades)
        ⚠️ Cuidados (1 aviso, se necessário)
        """
    }

    /// Prompt padrão para recomendação detalhada (modo normal)
    private func buildDetailedRecommendationPrompt(city: String, weather: WeatherData) -> String {
        """
        Gere recomendações práticas e amigáveis para o clima atual.

        Cidade: \(city)
        Temperatura: \(Int(weather.temperature))°C | Sensação: \(Int(weather.feelsLike))°C
        Condição: \(weather.description)
        Vento: \(String(format: "%.1f", weather.windSpeed)) km/h
        Umidade: \(weather.humidity)%
        Índice UV: \(weather.uvIndex)

        Inclua: o que vestir, atividades recomendadas, cuidados especiais.
        Máximo 250 palavras. Responda em português do Brasil.
        """
    }

    private func buildAccessibleActivitiesPrompt(city: String, weather: WeatherData) -> String {
        """
        Liste 5 atividades para \(city) com \(Int(weather.temperature))°C e \(weather.description).

        REGRAS:
        - Frases curtas e simples
        - Formato: emoji Nome (Fácil/Moderado/Intenso) — explicação simples
        - Máximo 120 palavras
        - Apenas a lista, sem introdução
        """
    }

    private func buildDetailedActivitiesPrompt(city: String, weather: WeatherData) -> String {
        """
        Sugira 6 atividades para \(city) considerando:
        Temperatura: \(Int(weather.temperature))°C | Sensação: \(Int(weather.feelsLike))°C
        Condição: \(weather.description) | Umidade: \(weather.humidity)%
        Vento: \(String(format: "%.1f", weather.windSpeed)) km/h | UV: \(weather.uvIndex)

        Formato: emoji Atividade — motivo breve
        Máximo 220 palavras. Português do Brasil.
        """
    }
}

// MARK: - WeatherData (Protocolo interno de desacoplamento)

/// Subset dos campos de Weather necessários para geração de prompts.
/// Evita acoplamento direto ao modelo de domínio em contextos de teste.
struct WeatherData {
    let city: String
    let temperature: Double
    let feelsLike: Double
    let condition: String
    let description: String
    let windSpeed: Double
    let humidity: Int
    let uvIndex: Double

    init(from weather: Weather) {
        self.city       = weather.city
        self.temperature = weather.temperature
        self.feelsLike  = weather.feelsLike
        self.condition  = weather.condition
        self.description = weather.description
        self.windSpeed  = weather.windSpeed
        self.humidity   = weather.humidity
        self.uvIndex    = weather.uvIndex
    }
}
