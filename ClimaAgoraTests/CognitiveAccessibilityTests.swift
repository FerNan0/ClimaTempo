//
//  CognitiveAccessibilityTests.swift
//  ClimaAgoraTests
//
//  Testes unitários para validar o sistema de acessibilidade cognitiva.
//  Estes testes podem ser citados no TCC como evidência de validação do sistema.
//

import Testing
import SwiftUI
@testable import ClimaAgora

// MARK: - Testes do CognitiveAccessibilityManager

// `.serialized`: estes testes mutam o singleton compartilhado
// `CognitiveAccessibilityManager.shared` (+ UserDefaults). Sem serializar, o
// Swift Testing os roda em paralelo e eles disputam o mesmo estado (flaky).
@Suite(.serialized)
struct CognitiveAccessibilityManagerTests {
    
    @Test func testEnableAllSetsAllToTrue() {
        let manager = CognitiveAccessibilityManager.shared
        manager.disableAll()
        manager.enableAll()
        
        #expect(manager.isSimplifiedMode == true)
        #expect(manager.useLargeIcons == true)
        #expect(manager.showVisualSummary == true)
        #expect(manager.reduceInformation == true)
        #expect(manager.enhancedHaptics == true)
    }
    
    @Test func testDisableAllSetsAllToFalse() {
        let manager = CognitiveAccessibilityManager.shared
        manager.enableAll()
        manager.disableAll()
        
        #expect(manager.isSimplifiedMode == false)
        #expect(manager.useLargeIcons == false)
        #expect(manager.showVisualSummary == false)
        #expect(manager.reduceInformation == false)
        #expect(manager.enhancedHaptics == false)
    }
    
    @Test func testPersistenceViaUserDefaults() {
        let manager = CognitiveAccessibilityManager.shared
        manager.isSimplifiedMode = true
        
        #expect(UserDefaults.standard.bool(forKey: "cognitiveAccessibility_simplified") == true)
        
        manager.isSimplifiedMode = false
        #expect(UserDefaults.standard.bool(forKey: "cognitiveAccessibility_simplified") == false)
    }
    
    @Test func testIndividualTogglePersistence() {
        let manager = CognitiveAccessibilityManager.shared
        manager.disableAll()
        
        manager.useLargeIcons = true
        #expect(UserDefaults.standard.bool(forKey: "cognitiveAccessibility_largeIcons") == true)
        
        manager.showVisualSummary = true
        #expect(UserDefaults.standard.bool(forKey: "cognitiveAccessibility_visualSummary") == true)
        
        manager.reduceInformation = true
        #expect(UserDefaults.standard.bool(forKey: "cognitiveAccessibility_reduceInfo") == true)
        
        manager.enhancedHaptics = true
        #expect(UserDefaults.standard.bool(forKey: "cognitiveAccessibility_haptics") == true)
        
        // Cleanup
        manager.disableAll()
    }
}

// MARK: - Testes do Semáforo de Clima (WeatherSafetyLevel)

struct WeatherSafetyLevelTests {
    
    // Helper para criar Weather com parâmetros específicos
    private func makeWeather(
        temp: Double = 22,
        condition: String = "Clear",
        windSpeed: Double = 10,
        uvIndex: Double = 5
    ) -> Weather {
        return Weather(
            city: "Teste",
            temperature: temp,
            feelsLike: temp,
            condition: condition,
            description: "Teste",
            humidity: 60,
            windSpeed: windSpeed,
            cloudiness: 20,
            sunrise: Date(),
            sunset: Date(),
            uvIndex: uvIndex,
            visibility: 10000
        )
    }
    
    // MARK: Condições SEGURAS (🟢)
    
    @Test func testSafeWeather_ClearDay() {
        let weather = makeWeather(temp: 22, condition: "Clear", windSpeed: 10, uvIndex: 5)
        let level = WeatherSafetyLevel.evaluate(weather: weather)
        #expect(level == .safe)
    }
    
    @Test func testSafeWeather_PleasantTemp() {
        let weather = makeWeather(temp: 25, condition: "Partly Cloudy", windSpeed: 15, uvIndex: 3)
        let level = WeatherSafetyLevel.evaluate(weather: weather)
        #expect(level == .safe)
    }
    
    // MARK: Condições de ATENÇÃO (🟡)
    
    @Test func testCautionWeather_Rain() {
        let weather = makeWeather(temp: 20, condition: "Light Rain", windSpeed: 10, uvIndex: 3)
        let level = WeatherSafetyLevel.evaluate(weather: weather)
        #expect(level == .caution)
    }
    
    @Test func testCautionWeather_Drizzle() {
        let weather = makeWeather(temp: 18, condition: "Drizzle", windSpeed: 8, uvIndex: 2)
        let level = WeatherSafetyLevel.evaluate(weather: weather)
        #expect(level == .caution)
    }
    
    @Test func testCautionWeather_HotTemp() {
        let weather = makeWeather(temp: 37, condition: "Clear", windSpeed: 5, uvIndex: 6)
        let level = WeatherSafetyLevel.evaluate(weather: weather)
        #expect(level == .caution)
    }
    
    @Test func testCautionWeather_ColdTemp() {
        let weather = makeWeather(temp: 3, condition: "Clear", windSpeed: 5, uvIndex: 2)
        let level = WeatherSafetyLevel.evaluate(weather: weather)
        #expect(level == .caution)
    }
    
    @Test func testCautionWeather_HighUV() {
        let weather = makeWeather(temp: 28, condition: "Clear", windSpeed: 5, uvIndex: 9)
        let level = WeatherSafetyLevel.evaluate(weather: weather)
        #expect(level == .caution)
    }
    
    @Test func testCautionWeather_StrongWind() {
        let weather = makeWeather(temp: 22, condition: "Clear", windSpeed: 45, uvIndex: 4)
        let level = WeatherSafetyLevel.evaluate(weather: weather)
        #expect(level == .caution)
    }
    
    // MARK: Condições PERIGOSAS (🔴)
    
    @Test func testDangerWeather_Thunderstorm() {
        let weather = makeWeather(temp: 20, condition: "Thunderstorm", windSpeed: 30, uvIndex: 1)
        let level = WeatherSafetyLevel.evaluate(weather: weather)
        #expect(level == .danger)
    }
    
    @Test func testDangerWeather_ExtremeHeat() {
        let weather = makeWeather(temp: 43, condition: "Clear", windSpeed: 5, uvIndex: 10)
        let level = WeatherSafetyLevel.evaluate(weather: weather)
        #expect(level == .danger)
    }
    
    @Test func testDangerWeather_ExtremeCold() {
        let weather = makeWeather(temp: -2, condition: "Clear", windSpeed: 10, uvIndex: 1)
        let level = WeatherSafetyLevel.evaluate(weather: weather)
        #expect(level == .danger)
    }
    
    @Test func testDangerWeather_ExtremeWind() {
        let weather = makeWeather(temp: 22, condition: "Clear", windSpeed: 65, uvIndex: 4)
        let level = WeatherSafetyLevel.evaluate(weather: weather)
        #expect(level == .danger)
    }
    
    // MARK: Propriedades do Semáforo
    
    @Test func testSafetyLevelColors() {
        #expect(WeatherSafetyLevel.safe.color == .green)
        #expect(WeatherSafetyLevel.caution.color == .yellow)
        #expect(WeatherSafetyLevel.danger.color == .red)
    }
    
    @Test func testSafetyLevelEmojis() {
        #expect(WeatherSafetyLevel.safe.emoji == "🟢")
        #expect(WeatherSafetyLevel.caution.emoji == "🟡")
        #expect(WeatherSafetyLevel.danger.emoji == "🔴")
    }
    
    @Test func testSafetyLevelIcons() {
        #expect(WeatherSafetyLevel.safe.icon == "checkmark.circle.fill")
        #expect(WeatherSafetyLevel.caution.icon == "exclamationmark.triangle.fill")
        #expect(WeatherSafetyLevel.danger.icon == "xmark.octagon.fill")
    }
    
    @Test func testSafetyLevelDescriptions_NotEmpty() {
        #expect(!WeatherSafetyLevel.safe.simplifiedDescription.isEmpty)
        #expect(!WeatherSafetyLevel.caution.simplifiedDescription.isEmpty)
        #expect(!WeatherSafetyLevel.danger.simplifiedDescription.isEmpty)
    }
}

// MARK: - Testes de Categorização de Atividades

struct ActivityCategorizationTests {
    
    @Test func testCategorizeExercise() {
        let activities = AccessibilityHelper.parseActivitiesFromAI("🏃 Corrida no parque - Faça uma corrida leve")
        #expect(activities.first?.category == .exercise)
    }
    
    @Test func testCategorizeCulture() {
        let activities = AccessibilityHelper.parseActivitiesFromAI("🎭 Visitar museu - Conheça o museu de arte")
        #expect(activities.first?.category == .culture)
    }
    
    @Test func testCategorizeFood() {
        let activities = AccessibilityHelper.parseActivitiesFromAI("🍽️ Restaurante italiano - Experimente uma boa comida")
        #expect(activities.first?.category == .food)
    }
    
    @Test func testCategorizeRelax() {
        let activities = AccessibilityHelper.parseActivitiesFromAI("🧘 Yoga matinal - Sessão de yoga e meditação relaxante")
        #expect(activities.first?.category == .relax)
    }
    
    @Test func testCategorizeIndoor() {
        let activities = AccessibilityHelper.parseActivitiesFromAI("🎮 Jogos em casa - Jogos de tabuleiro no shopping")
        #expect(activities.first?.category == .indoor)
    }
    
    @Test func testCategorizeOutdoor_Default() {
        let activities = AccessibilityHelper.parseActivitiesFromAI("🌳 Passeio no parque - Aproveite o dia bonito")
        #expect(activities.first?.category == .outdoor)
    }
}

// MARK: - Testes de Parsing de Atividades da IA

struct ActivityParsingTests {
    
    @Test func testParseActivitiesWithNameAndDescription() {
        let text = """
        🌳 Caminhada no Ibirapuera - Aproveite o clima agradável para uma caminhada
        🍽️ Feira gastronômica - Visite a feira de comida local
        """
        let activities = AccessibilityHelper.parseActivitiesFromAI(text)
        
        #expect(activities.count == 2)
        #expect(activities[0].name.contains("Caminhada"))
        #expect(!activities[0].description.isEmpty)
        #expect(activities[1].name.contains("Feira"))
    }
    
    @Test func testParseActivitiesNameOnly() {
        let text = """
        Visitar o MASP
        Passeio de bike
        """
        let activities = AccessibilityHelper.parseActivitiesFromAI(text)
        
        #expect(activities.count == 2)
        #expect(activities[0].description.isEmpty)
    }
    
    @Test func testParseEmptyText() {
        let activities = AccessibilityHelper.parseActivitiesFromAI("")
        #expect(activities.isEmpty)
    }
    
    @Test func testParseActivities_AllHaveIds() {
        let text = """
        Atividade 1 - Descrição 1
        Atividade 2 - Descrição 2
        Atividade 3 - Descrição 3
        """
        let activities = AccessibilityHelper.parseActivitiesFromAI(text)
        
        // Todos devem ter IDs únicos
        let ids = activities.map { $0.id }
        let uniqueIds = Set(ids)
        #expect(ids.count == uniqueIds.count)
    }
    
    @Test func testParseActivities_AllHaveDifficulty() {
        let text = """
        Corrida intensa no parque - Treino pesado
        Leitura no café - Relaxe com um livro
        Caminhada leve - Passeie pelo bairro
        """
        let activities = AccessibilityHelper.parseActivitiesFromAI(text)
        
        // Corrida intensa deve ser difícil
        #expect(activities[0].difficulty == .hard || activities[0].difficulty == .moderate)
        // Leitura deve ser fácil
        #expect(activities[1].difficulty == .easy)
    }
}

// MARK: - Testes de Dificuldade de Atividades

struct DifficultyEvaluationTests {
    
    @Test func testHardActivities() {
        let hardTexts = ["trilha na montanha", "escalada", "surf no litoral", "corrida intensa"]
        for text in hardTexts {
            let activities = AccessibilityHelper.parseActivitiesFromAI("\(text) - Descrição teste")
            #expect(activities.first?.difficulty == .hard, "'\(text)' deveria ser classificado como hard/intenso")
        }
    }
    
    @Test func testModerateActivities() {
        let moderateTexts = ["caminhada no parque", "bike pela cidade", "natação na piscina"]
        for text in moderateTexts {
            let activities = AccessibilityHelper.parseActivitiesFromAI("\(text) - Descrição teste")
            #expect(activities.first?.difficulty == .moderate, "'\(text)' deveria ser classificado como moderate")
        }
    }
    
    @Test func testEasyActivities() {
        let easyTexts = ["leitura no café", "visitar museu", "restaurante italiano"]
        for text in easyTexts {
            let activities = AccessibilityHelper.parseActivitiesFromAI("\(text) - Descrição teste")
            #expect(activities.first?.difficulty == .easy, "'\(text)' deveria ser classificado como easy/fácil")
        }
    }
    
    @Test func testDifficultyLevelProperties() {
        #expect(AccessibleActivity.DifficultyLevel.easy.rawValue == "Fácil")
        #expect(AccessibleActivity.DifficultyLevel.moderate.rawValue == "Moderado")
        #expect(AccessibleActivity.DifficultyLevel.hard.rawValue == "Intenso")
        
        #expect(AccessibleActivity.DifficultyLevel.easy.color == .green)
        #expect(AccessibleActivity.DifficultyLevel.moderate.color == .yellow)
        #expect(AccessibleActivity.DifficultyLevel.hard.color == .orange)
    }
}

// MARK: - Testes das Categorias de Atividade

struct ActivityCategoryTests {
    
    @Test func testAllCategoriesHaveEmoji() {
        for category in ActivityCategory.allCases {
            #expect(!category.emoji.isEmpty, "\(category.rawValue) deve ter emoji")
        }
    }
    
    @Test func testAllCategoriesHaveIcon() {
        for category in ActivityCategory.allCases {
            #expect(!category.icon.isEmpty, "\(category.rawValue) deve ter ícone SF Symbol")
        }
    }
    
    @Test func testAllCategoriesHaveName() {
        for category in ActivityCategory.allCases {
            #expect(!category.rawValue.isEmpty, "Categoria deve ter nome")
        }
    }
    
    @Test func testCategoryCount() {
        #expect(ActivityCategory.allCases.count == 6)
    }
}

// MARK: - Testes do AccessibilityHelper Estático

struct AccessibilityHelperTests {
    
    @Test func testFormatNumberForAccessibility() {
        let result = AccessibilityHelper.formatNumberForAccessibility(25.3, unit: "graus")
        #expect(result.contains("25"))
        #expect(result.contains("3"))
        #expect(result.contains("graus"))
        #expect(result.contains("vírgula"))
    }
    
    @Test func testFormatNumberWithoutUnit() {
        let result = AccessibilityHelper.formatNumberForAccessibility(10.0)
        #expect(!result.contains("graus"))
    }
    
    @Test func testCreateStatusDescription() {
        let desc = AccessibilityHelper.createStatusDescription(
            city: "São Paulo",
            condition: "Ensolarado",
            temperature: 28
        )
        #expect(desc.contains("São Paulo"))
        #expect(desc.contains("Ensolarado"))
        #expect(desc.contains("28"))
    }
    
    @Test func testMinTouchTargetSize() {
        // WCAG recomenda no mínimo 44pt
        #expect(AccessibilityHelper.minTouchTargetSize >= 44)
    }
}

// MARK: - Testes das Descrições de Acessibilidade

struct AccessibilityDescriptionsTests {
    
    @Test func testTemperatureDescription() {
        let desc = AccessibilityDescriptions.temperature(25)
        #expect(desc.contains("25"))
        #expect(desc.contains("graus"))
        #expect(desc.contains("Celsius"))
    }
    
    @Test func testHumidityDescription() {
        let desc = AccessibilityDescriptions.humidity(65)
        #expect(desc.contains("65"))
        #expect(desc.contains("porcento"))
    }
    
    @Test func testWindDescription() {
        let desc = AccessibilityDescriptions.wind(12.5)
        #expect(desc.contains("12"))
        #expect(desc.contains("quilômetros"))
    }
    
    @Test func testSafetyLevelDescription() {
        let desc = AccessibilityDescriptions.safetyLevel(.safe)
        #expect(desc.contains("Bom para sair"))
    }
    
    @Test func testStaticDescriptions_NotEmpty() {
        #expect(!AccessibilityDescriptions.loadingWeather.isEmpty)
        #expect(!AccessibilityDescriptions.searchCity.isEmpty)
        #expect(!AccessibilityDescriptions.addFavorite.isEmpty)
        #expect(!AccessibilityDescriptions.removeFavorite.isEmpty)
        #expect(!AccessibilityDescriptions.shareWeather.isEmpty)
        #expect(!AccessibilityDescriptions.visitPlace.isEmpty)
        #expect(!AccessibilityDescriptions.retryButton.isEmpty)
        #expect(!AccessibilityDescriptions.closeButton.isEmpty)
        #expect(!AccessibilityDescriptions.simplifiedMode.isEmpty)
    }
}

// MARK: - Testes de Cenários de Borda (Edge Cases)

struct EdgeCaseTests {
    
    @Test func testWeatherAtExactBoundary_35Degrees() {
        // 35°C é o limite para caution (> 35)
        let weatherAt35 = Weather(
            city: "Teste", temperature: 35, feelsLike: 35, condition: "Clear",
            description: "", humidity: 50, windSpeed: 10, cloudiness: 0,
            sunrise: Date(), sunset: Date(), uvIndex: 5, visibility: 10000
        )
        let level = WeatherSafetyLevel.evaluate(weather: weatherAt35)
        // temp > 35 => caution, 35 is NOT > 35 so it should be safe
        #expect(level == .safe)
    }
    
    @Test func testWeatherAtExactBoundary_36Degrees() {
        let weatherAt36 = Weather(
            city: "Teste", temperature: 36, feelsLike: 36, condition: "Clear",
            description: "", humidity: 50, windSpeed: 10, cloudiness: 0,
            sunrise: Date(), sunset: Date(), uvIndex: 5, visibility: 10000
        )
        let level = WeatherSafetyLevel.evaluate(weather: weatherAt36)
        #expect(level == .caution)
    }
    
    @Test func testWeatherAtExactBoundary_42Degrees() {
        // 42°C é o limite para danger (> 42)
        let weatherAt42 = Weather(
            city: "Teste", temperature: 42, feelsLike: 42, condition: "Clear",
            description: "", humidity: 50, windSpeed: 10, cloudiness: 0,
            sunrise: Date(), sunset: Date(), uvIndex: 5, visibility: 10000
        )
        let level = WeatherSafetyLevel.evaluate(weather: weatherAt42)
        // temp > 42 => danger; 42 is NOT > 42
        // But temp > 35 => caution; 42 > 35 IS true
        #expect(level == .caution)
    }
    
    @Test func testWeatherAtExactBoundary_43Degrees() {
        let weatherAt43 = Weather(
            city: "Teste", temperature: 43, feelsLike: 43, condition: "Clear",
            description: "", humidity: 50, windSpeed: 10, cloudiness: 0,
            sunrise: Date(), sunset: Date(), uvIndex: 5, visibility: 10000
        )
        let level = WeatherSafetyLevel.evaluate(weather: weatherAt43)
        #expect(level == .danger)
    }
    
    @Test func testParseActivities_WithSpecialCharacters() {
        let text = "Café no São Paulo ☕ - Aproveite o café com pão de queijo"
        let activities = AccessibilityHelper.parseActivitiesFromAI(text)
        #expect(!activities.isEmpty)
        #expect(activities.first?.name.contains("Caf") == true)
    }
    
    @Test func testParseActivities_OnlyWhitespace() {
        let text = "   \n   \n   "
        let activities = AccessibilityHelper.parseActivitiesFromAI(text)
        #expect(activities.isEmpty)
    }
    
    @Test func testThunderstormTakesPriorityOverTemp() {
        // Mesmo com temp agradável, thunderstorm = danger
        let weather = Weather(
            city: "Teste", temperature: 22, feelsLike: 22, condition: "Thunderstorm",
            description: "", humidity: 80, windSpeed: 25, cloudiness: 90,
            sunrise: Date(), sunset: Date(), uvIndex: 1, visibility: 5000
        )
        let level = WeatherSafetyLevel.evaluate(weather: weather)
        #expect(level == .danger)
    }
}
