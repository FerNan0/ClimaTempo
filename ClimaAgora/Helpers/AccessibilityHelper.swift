import SwiftUI

// MARK: - Gerenciador de Acessibilidade Cognitiva

/// Gerenciador central de preferências de acessibilidade cognitiva.
/// Persiste configurações via UserDefaults e publica mudanças para SwiftUI.
class CognitiveAccessibilityManager: ObservableObject {
    static let shared = CognitiveAccessibilityManager()
    
    /// Modo de linguagem simplificada ativado
    @Published var isSimplifiedMode: Bool {
        didSet { UserDefaults.standard.set(isSimplifiedMode, forKey: "cognitiveAccessibility_simplified") }
    }
    
    /// Usar ícones grandes nos cards
    @Published var useLargeIcons: Bool {
        didSet { UserDefaults.standard.set(useLargeIcons, forKey: "cognitiveAccessibility_largeIcons") }
    }
    
    /// Mostrar resumo visual (semáforo de clima)
    @Published var showVisualSummary: Bool {
        didSet { UserDefaults.standard.set(showVisualSummary, forKey: "cognitiveAccessibility_visualSummary") }
    }
    
    /// Reduzir quantidade de informação exibida
    @Published var reduceInformation: Bool {
        didSet { UserDefaults.standard.set(reduceInformation, forKey: "cognitiveAccessibility_reduceInfo") }
    }
    
    /// Feedback haptic reforçado
    @Published var enhancedHaptics: Bool {
        didSet { UserDefaults.standard.set(enhancedHaptics, forKey: "cognitiveAccessibility_haptics") }
    }

    // MARK: - Adaptação automática (motor comportamental)

    /// Interruptor-mestre da adaptação AUTOMÁTICA. Quando ligado, o
    /// AdaptiveEngine observa o comportamento e pode sugerir simplificar.
    /// Reflete a preferência de 62,8% por adaptação automática (Tabela 3 do TCC).
    /// Preserva a agência: o usuário pode desligar por completo a qualquer momento.
    @Published var automaticAdaptationEnabled: Bool {
        didSet { UserDefaults.standard.set(automaticAdaptationEnabled, forKey: "cognitiveAccessibility_autoEnabled") }
    }

    /// Permite que o motor aplique a simplificação SEM pedir permissão quando a
    /// carga cognitiva é muito alta. Default `false` (começa sempre sugerindo,
    /// para não surpreender). Sempre reversível e sinalizado.
    @Published var allowAutoApply: Bool {
        didSet { UserDefaults.standard.set(allowAutoApply, forKey: "cognitiveAccessibility_allowAutoApply") }
    }

    /// Origem da última ativação do modo simplificado — usada para transparência
    /// na UI ("adaptado automaticamente" vs. "você ativou").
    enum AdaptationSource: String {
        case manual              // usuário mexeu no toggle
        case suggestionAccepted  // motor sugeriu, usuário aceitou
        case automatic           // motor aplicou sozinho
    }
    @Published private(set) var lastAdaptationSource: AdaptationSource = .manual

    private init() {
        self.isSimplifiedMode = UserDefaults.standard.bool(forKey: "cognitiveAccessibility_simplified")
        self.useLargeIcons = UserDefaults.standard.bool(forKey: "cognitiveAccessibility_largeIcons")
        self.showVisualSummary = UserDefaults.standard.bool(forKey: "cognitiveAccessibility_visualSummary")
        self.reduceInformation = UserDefaults.standard.bool(forKey: "cognitiveAccessibility_reduceInfo")
        self.enhancedHaptics = UserDefaults.standard.bool(forKey: "cognitiveAccessibility_haptics")
        // Adaptação automática nasce LIGADA (é a tese do TCC), mas em modo
        // "sugerir" — não aplica nada sozinho até o usuário permitir.
        self.automaticAdaptationEnabled = UserDefaults.standard.object(forKey: "cognitiveAccessibility_autoEnabled") as? Bool ?? true
        self.allowAutoApply = UserDefaults.standard.bool(forKey: "cognitiveAccessibility_allowAutoApply")
    }

    /// Ativa o perfil simplificado (linguagem + menos informação + resumo visual),
    /// registrando a ORIGEM da mudança para exibição transparente ao usuário.
    /// Chamado tanto pela aceitação de uma sugestão quanto pela adaptação automática.
    func applySimplifiedProfile(source: AdaptationSource) {
        lastAdaptationSource = source
        isSimplifiedMode = true
        reduceInformation = true
        showVisualSummary = true
    }
    
    /// Ativa todos os recursos de acessibilidade cognitiva de uma vez
    func enableAll() {
        isSimplifiedMode = true
        useLargeIcons = true
        showVisualSummary = true
        reduceInformation = true
        enhancedHaptics = true
    }
    
    /// Desativa todos os recursos de acessibilidade cognitiva
    func disableAll() {
        isSimplifiedMode = false
        useLargeIcons = false
        showVisualSummary = false
        reduceInformation = false
        enhancedHaptics = false
    }
}

// MARK: - Semáforo Visual de Clima

/// Indica visualmente se o clima é bom, moderado ou ruim para sair de casa
enum WeatherSafetyLevel: String {
    case safe = "Bom para sair"
    case caution = "Atenção ao sair"
    case danger = "Melhor ficar em casa"
    
    var color: Color {
        switch self {
        case .safe: return .green
        case .caution: return .yellow
        case .danger: return .red
        }
    }
    
    var icon: String {
        switch self {
        case .safe: return "checkmark.circle.fill"
        case .caution: return "exclamationmark.triangle.fill"
        case .danger: return "xmark.octagon.fill"
        }
    }
    
    var emoji: String {
        switch self {
        case .safe: return "🟢"
        case .caution: return "🟡"
        case .danger: return "🔴"
        }
    }
    
    var simplifiedDescription: String {
        switch self {
        case .safe: return "Hoje é um bom dia para sair! O tempo está agradável."
        case .caution: return "Você pode sair, mas tome cuidado. Veja as dicas abaixo."
        case .danger: return "Hoje é melhor ficar em casa ou em lugar seguro."
        }
    }
    
    /// Avalia o nível de segurança com base no clima.
    /// Delega ao `WeatherRiskAssessor` (fonte única de limiares) — assim o
    /// semáforo e os avisos detalhados nunca discordam, e o bug de unidade do
    /// vento (m/s tratado como km/h) fica corrigido aqui também.
    static func evaluate(weather: Weather) -> WeatherSafetyLevel {
        switch WeatherRiskAssessor.overallLevel(WeatherRiskAssessor.assess(weather: weather)) {
        case .safe:      return .safe
        case .attention: return .caution
        case .danger:    return .danger
        }
    }
}

// MARK: - Categorias Visuais de Atividade

/// Categorias de atividades com ícones e cores para facilitar compreensão
enum ActivityCategory: String, CaseIterable {
    case outdoor = "Ao Ar Livre"
    case indoor = "Dentro de Casa"
    case exercise = "Exercício"
    case culture = "Cultura"
    case food = "Comida"
    case relax = "Relaxar"
    
    var icon: String {
        switch self {
        case .outdoor: return "sun.max.fill"
        case .indoor: return "house.fill"
        case .exercise: return "figure.run"
        case .culture: return "building.columns.fill"
        case .food: return "fork.knife"
        case .relax: return "leaf.fill"
        }
    }
    
    var emoji: String {
        switch self {
        case .outdoor: return "🌳"
        case .indoor: return "🏠"
        case .exercise: return "🏃"
        case .culture: return "🎭"
        case .food: return "🍽️"
        case .relax: return "🧘"
        }
    }
    
    var color: Color {
        switch self {
        case .outdoor: return .green
        case .indoor: return .blue
        case .exercise: return .orange
        case .culture: return .purple
        case .food: return .red
        case .relax: return .teal
        }
    }
}

// MARK: - Modelo de Atividade Estruturada

/// Atividade individual com dados estruturados para exibição acessível
struct AccessibleActivity: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let category: ActivityCategory
    let difficulty: DifficultyLevel
    
    enum DifficultyLevel: String {
        case easy = "Fácil"
        case moderate = "Moderado"
        case hard = "Intenso"
        
        var color: Color {
            switch self {
            case .easy: return .green
            case .moderate: return .yellow
            case .hard: return .orange
            }
        }
        
        var icon: String {
            switch self {
            case .easy: return "1.circle.fill"
            case .moderate: return "2.circle.fill"
            case .hard: return "3.circle.fill"
            }
        }
    }
}

// MARK: - Mapeamento: StructuredActivity (IA guiada) → card visual

extension AccessibleActivity {
    /// Converte o resultado ESTRUTURADO da IA (Guided Generation) no card visual,
    /// sem parsing de string. Tolerante: normaliza acentos/caixa e usa um default
    /// seguro caso o modelo devolva categoria/dificuldade fora do conjunto guiado.
    init(from s: StructuredActivity) {
        self.init(
            name: s.name,
            description: s.explanation,
            category: ActivityCategory.match(s.category),
            difficulty: DifficultyLevel.match(s.difficulty)
        )
    }
}

extension ActivityCategory {
    static func match(_ text: String) -> ActivityCategory {
        let normalized = text.folding(options: .diacriticInsensitive, locale: .current).lowercased()
        return allCases.first {
            $0.rawValue.folding(options: .diacriticInsensitive, locale: .current).lowercased() == normalized
        } ?? .outdoor
    }
}

extension AccessibleActivity.DifficultyLevel {
    static func match(_ text: String) -> AccessibleActivity.DifficultyLevel {
        switch text.folding(options: .diacriticInsensitive, locale: .current).lowercased() {
        case "facil":    return .easy
        case "intenso":  return .hard
        default:         return .moderate
        }
    }
}

// MARK: - Componentes Visuais de Acessibilidade

/// Semáforo visual do clima — indica de forma intuitiva se é seguro sair
struct WeatherSafetyBanner: View {
    let weather: Weather
    
    private var level: WeatherSafetyLevel {
        WeatherSafetyLevel.evaluate(weather: weather)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: level.icon)
                .font(.system(size: 28))
                .foregroundColor(level.color)
                .accessibilityHidden(true)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(level.rawValue)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.3))
                
                Text(level.simplifiedDescription)
                    .font(.system(size: 13))
                    .foregroundColor(Color(red: 0.35, green: 0.35, blue: 0.45))
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(level.color.opacity(0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(level.color.opacity(0.4), lineWidth: 1.5)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(level.rawValue). \(level.simplifiedDescription)")
    }
}

/// Card de resumo simplificado do clima — linguagem simples e direta
struct SimplifiedWeatherSummary: View {
    let weather: Weather
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 16))
                    .foregroundColor(.cyan)
                Text("Resumo Simples")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.3))
            }
            
            Text(generateSimpleSummary())
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.4))
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(4)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Resumo simples do clima. \(generateSimpleSummary())")
    }
    
    private func generateSimpleSummary() -> String {
        let temp = Int(weather.temperature)
        let condition = weather.condition.lowercased()
        
        var parts: [String] = []
        
        // Temperatura em linguagem simples
        if temp < 10 {
            parts.append("Está muito frio lá fora. 🥶")
        } else if temp < 18 {
            parts.append("Está um pouco frio. 🧥")
        } else if temp < 25 {
            parts.append("A temperatura está agradável. 😊")
        } else if temp < 32 {
            parts.append("Está quente. ☀️")
        } else {
            parts.append("Está muito quente! 🔥")
        }
        
        // Condição em linguagem simples
        if condition.contains("rain") || condition.contains("drizzle") {
            parts.append("Está chovendo. Leve um guarda-chuva! ☔")
        } else if condition.contains("cloud") {
            parts.append("O céu está nublado.")
        } else if condition.contains("clear") || condition.contains("sunny") {
            parts.append("O céu está limpo e bonito.")
        } else if condition.contains("thunder") {
            parts.append("Tem tempestade! Fique em lugar seguro. ⛈️")
        } else if condition.contains("snow") {
            parts.append("Está nevando! ❄️")
        }
        
        // Vento
        if weather.windSpeed > 30 {
            parts.append("O vento está muito forte.")
        }
        
        return parts.joined(separator: " ")
    }
}

/// Card de atividade com visual acessível — ícone grande, cor da categoria, texto claro
struct AccessibleActivityCard: View {
    let activity: AccessibleActivity
    let useLargeIcons: Bool
    
    var body: some View {
        HStack(spacing: 14) {
            // Ícone grande da categoria
            ZStack {
                Circle()
                    .fill(activity.category.color.opacity(0.15))
                    .frame(width: useLargeIcons ? 56 : 44, height: useLargeIcons ? 56 : 44)
                
                Image(systemName: activity.category.icon)
                    .font(.system(size: useLargeIcons ? 24 : 18))
                    .foregroundColor(activity.category.color)
            }
            .accessibilityHidden(true)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.name)
                    .font(.system(size: useLargeIcons ? 16 : 14, weight: .bold))
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.3))
                
                if !activity.description.isEmpty {
                    Text(activity.description)
                        .font(.system(size: useLargeIcons ? 14 : 12))
                        .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.5))
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // Badge de dificuldade
                HStack(spacing: 4) {
                    Image(systemName: activity.difficulty.icon)
                        .font(.system(size: 10))
                    Text(activity.difficulty.rawValue)
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundColor(activity.difficulty.color)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(activity.difficulty.color.opacity(0.12))
                .cornerRadius(6)
            }
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(activity.category.color.opacity(0.25), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(activity.name). \(activity.description). Dificuldade: \(activity.difficulty.rawValue). Categoria: \(activity.category.rawValue)")
    }
}

// MARK: - View Modifier para Acessibilidade Cognitiva

extension View {
    /// Aplica rótulo acessível para VoiceOver com label e hint
    func accessibleButton(label: String, hint: String = "") -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint)
            .accessibilityAddTraits(.isButton)
            .frame(minWidth: 44, minHeight: 44)
    }
    
    /// Melhora leitura de conteúdo estático
    func accessibleText(label: String) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityAddTraits(.isStaticText)
    }
    
    /// Agrupa elementos relacionados para leitura de tela
    func accessibleGroup(label: String) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(label)
    }
}

// MARK: - Helpers Estáticos

struct AccessibilityHelper {
    
    /// Formata números para leitura acessível
    static func formatNumberForAccessibility(_ number: Double, unit: String = "") -> String {
        let formatted = String(format: "%.1f", number).replacingOccurrences(of: ".", with: " vírgula ")
        if unit.isEmpty {
            return formatted
        }
        return "\(formatted) \(unit)"
    }
    
    /// Cria descrição de status para VoiceOver
    static func createStatusDescription(city: String, condition: String, temperature: Int) -> String {
        return "Clima em \(city): \(condition). Temperatura de \(temperature) graus."
    }
    
    /// Área de toque mínima para acessibilidade motora
    static let minTouchTargetSize: CGFloat = 44
    
    /// Parseia a resposta da IA em atividades estruturadas
    static func parseActivitiesFromAI(_ text: String) -> [AccessibleActivity] {
        let lines = text.components(separatedBy: "\n").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        
        var activities: [AccessibleActivity] = []
        
        for line in lines {
            let cleaned = line.trimmingCharacters(in: .whitespaces)
            guard !cleaned.isEmpty else { continue }
            
            // Tentar extrair nome e descrição (formato: "emoji Nome - Descrição")
            let parts = cleaned.components(separatedBy: " - ")
            
            let name: String
            let description: String
            
            if parts.count >= 2 {
                name = parts[0]
                    .replacingOccurrences(of: "^[^a-zA-ZÀ-ú]+", with: "", options: .regularExpression)
                    .trimmingCharacters(in: .whitespaces)
                description = parts[1...].joined(separator: " - ").trimmingCharacters(in: .whitespaces)
            } else {
                let cleanedLine = cleaned
                    .replacingOccurrences(of: "^[^a-zA-ZÀ-ú]+", with: "", options: .regularExpression)
                    .trimmingCharacters(in: .whitespaces)
                
                guard !cleanedLine.isEmpty else { continue }
                name = cleanedLine
                description = ""
            }
            
            guard !name.isEmpty else { continue }
            
            let category = categorizeActivity(name + " " + description)
            let difficulty = evaluateDifficulty(name + " " + description)
            
            activities.append(AccessibleActivity(
                name: name,
                description: description,
                category: category,
                difficulty: difficulty
            ))
        }
        
        return activities
    }
    
    /// Categoriza uma atividade baseado em palavras-chave
    private static func categorizeActivity(_ text: String) -> ActivityCategory {
        let lower = text.lowercased()
        
        if lower.contains("corr") || lower.contains("exerc") || lower.contains("acade") ||
            lower.contains("caminhad") || lower.contains("bike") || lower.contains("cicl") ||
            lower.contains("trilh") || lower.contains("nada") || lower.contains("nata") || lower.contains("surf") {
            return .exercise
        }
        if lower.contains("museu") || lower.contains("teatro") || lower.contains("cinem") ||
            lower.contains("galeri") || lower.contains("exposiç") || lower.contains("cultur") ||
            lower.contains("bibliote") || lower.contains("históri") {
            return .culture
        }
        if lower.contains("restaur") || lower.contains("café") || lower.contains("comid") ||
            lower.contains("gastrono") || lower.contains("feira") || lower.contains("mercad") ||
            lower.contains("bar ") || lower.contains("sorvete") {
            return .food
        }
        if lower.contains("relax") || lower.contains("spa") || lower.contains("medit") ||
            lower.contains("yoga") || lower.contains("massage") || lower.contains("descan") ||
            lower.contains("leitura") || lower.contains("livro") {
            return .relax
        }
        if lower.contains("casa") || lower.contains("indoor") || lower.contains("jogo") ||
            lower.contains("shopping") || lower.contains("serie") || lower.contains("filme") {
            return .indoor
        }
        
        return .outdoor
    }
    
    /// Avalia dificuldade de uma atividade
    private static func evaluateDifficulty(_ text: String) -> AccessibleActivity.DifficultyLevel {
        let lower = text.lowercased()
        
        if lower.contains("trilh") || lower.contains("escal") || lower.contains("surf") ||
            lower.contains("corrid") || lower.contains("intens") {
            return .hard
        }
        if lower.contains("caminhad") || lower.contains("bike") || lower.contains("cicl") ||
            lower.contains("nada") || lower.contains("nata") || lower.contains("exerc") {
            return .moderate
        }
        
        return .easy
    }
}

// MARK: - Descrições Padrão para VoiceOver

enum AccessibilityDescriptions {
    static let loadingWeather = "Carregando informações do tempo"
    static let searchCity = "Pesquisar outra cidade. Toque para abrir a busca"
    static let addFavorite = "Adicionar aos favoritos"
    static let removeFavorite = "Remover de favoritos"
    static let shareWeather = "Compartilhar informações do tempo"
    static let visitPlace = "Quero visitar esse lugar. Toque para ver atividades recomendadas"
    static let retryButton = "Tentar novamente"
    static let closeButton = "Fechar"
    static let simplifiedMode = "Modo de linguagem simplificada. Textos mais curtos e fáceis de entender"
    
    static func temperature(_ temp: Int) -> String {
        return "Temperatura de \(temp) graus Celsius"
    }
    
    static func humidity(_ percent: Int) -> String {
        return "Umidade de \(percent) porcento"
    }
    
    static func wind(_ speed: Double) -> String {
        return "Vento de \(String(format: "%.1f", speed)) quilômetros por hora"
    }
    
    static func safetyLevel(_ level: WeatherSafetyLevel) -> String {
        return "\(level.rawValue). \(level.simplifiedDescription)"
    }
}
