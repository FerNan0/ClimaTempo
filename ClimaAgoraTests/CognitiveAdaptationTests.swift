//
//  CognitiveAdaptationTests.swift
//  ClimaAgoraTests
//
//  Testes do MOTOR DE ADAPTAÇÃO AUTOMÁTICA — o núcleo da contribuição do TCC.
//  Validam, de forma determinística, que o sistema transforma padrões de
//  comportamento (hesitação, erro, toques repetidos, loops de navegação) na
//  decisão correta de adaptação, superando a parametrização manual.
//
//  Podem ser citados no TCC como evidência de validação do artefato.
//

import Testing
import Foundation
@testable import ClimaAgora

// Helpers de construção de eventos com tempo controlado (determinismo).
private func makeEvent(_ kind: InteractionEvent.Kind, secondsAgo: TimeInterval, now: Date) -> InteractionEvent {
    InteractionEvent(kind: kind, screen: "Teste", timestamp: now.addingTimeInterval(-secondsAgo))
}

// MARK: - Score de carga cognitiva

struct CognitiveLoadScoreTests {

    private let estimator = CognitiveLoadEstimator()
    private let now = Date()

    @Test func testEmptyEvents_ScoreIsZero() {
        #expect(estimator.score(events: [], now: now) == 0)
    }

    @Test func testSingleError_ScoreEqualsWeight() {
        let events = [makeEvent(.error, secondsAgo: 1, now: now)]
        #expect(estimator.score(events: events, now: now) == 3.0)
    }

    @Test func testMultipleFrictionSignals_Sum() {
        let events = [
            makeEvent(.repeatedTap, secondsAgo: 1, now: now),  // 3.0
            makeEvent(.error, secondsAgo: 2, now: now),        // 3.0
            makeEvent(.hesitation, secondsAgo: 3, now: now)    // 1.5
        ]
        #expect(estimator.score(events: events, now: now) == 7.5)
    }

    @Test func testTaskCompleted_ReducesLoad() {
        let events = [
            makeEvent(.error, secondsAgo: 1, now: now),        // +3.0
            makeEvent(.error, secondsAgo: 2, now: now),        // +3.0
            makeEvent(.taskCompleted, secondsAgo: 1, now: now) // -2.5
        ]
        #expect(estimator.score(events: events, now: now) == 3.5)
    }

    @Test func testScore_NeverNegative() {
        // Só alívio → não deve produzir score negativo (piso em zero).
        let events = [
            makeEvent(.taskCompleted, secondsAgo: 1, now: now),
            makeEvent(.taskCompleted, secondsAgo: 2, now: now)
        ]
        #expect(estimator.score(events: events, now: now) == 0)
    }

    @Test func testEventsOutsideWindow_AreIgnored() {
        // Janela padrão = 90s. Eventos com 200s são antigos demais.
        let events = [
            makeEvent(.error, secondsAgo: 200, now: now),
            makeEvent(.error, secondsAgo: 300, now: now)
        ]
        #expect(estimator.score(events: events, now: now) == 0)
    }

    @Test func testMixedWindow_OnlyRecentCount() {
        let events = [
            makeEvent(.error, secondsAgo: 5, now: now),   // dentro (+3)
            makeEvent(.error, secondsAgo: 500, now: now)  // fora (ignorado)
        ]
        #expect(estimator.score(events: events, now: now) == 3.0)
    }
}

// MARK: - Decisão de adaptação

struct AdaptationDecisionTests {

    private let estimator = CognitiveLoadEstimator()
    private let now = Date()

    @Test func testLowLoad_NoChange() {
        let events = [makeEvent(.error, secondsAgo: 1, now: now)] // 3.0 < 6
        let decision = estimator.decide(events: events, now: now, alreadySimplified: false)
        #expect(decision == .noChange)
    }

    @Test func testAtSuggestThreshold_Suggests() {
        // 2 erros = 6.0 == suggestThreshold, < autoThreshold(10)
        let events = [
            makeEvent(.error, secondsAgo: 1, now: now),
            makeEvent(.error, secondsAgo: 2, now: now)
        ]
        let decision = estimator.decide(events: events, now: now, alreadySimplified: false)
        if case .suggestSimplified = decision {
            #expect(Bool(true))
        } else {
            #expect(Bool(false), "Esperava .suggestSimplified, obteve \(decision)")
        }
    }

    @Test func testHighLoad_AutoSimplifies() {
        // 4 toques repetidos = 12.0 >= autoThreshold(10)
        let events = (0..<4).map { makeEvent(.repeatedTap, secondsAgo: Double($0), now: now) }
        let decision = estimator.decide(events: events, now: now, alreadySimplified: false)
        if case .autoSimplify = decision {
            #expect(Bool(true))
        } else {
            #expect(Bool(false), "Esperava .autoSimplify, obteve \(decision)")
        }
    }

    @Test func testAlreadySimplified_NeverReSuggests() {
        // Carga altíssima, mas já simplificado → não repropõe.
        let events = (0..<10).map { makeEvent(.repeatedTap, secondsAgo: Double($0), now: now) }
        let decision = estimator.decide(events: events, now: now, alreadySimplified: true)
        #expect(decision == .noChange)
    }

    @Test func testSuccessCancelsSuggestion() {
        // 2 erros (6.0) mas seguidos de conclusão (-2.5) → 3.5 → noChange.
        let events = [
            makeEvent(.error, secondsAgo: 3, now: now),
            makeEvent(.error, secondsAgo: 2, now: now),
            makeEvent(.taskCompleted, secondsAgo: 1, now: now)
        ]
        let decision = estimator.decide(events: events, now: now, alreadySimplified: false)
        #expect(decision == .noChange)
    }

    @Test func testDecisionCarriesTransparentReason() {
        let events = [
            makeEvent(.hesitation, secondsAgo: 1, now: now),
            makeEvent(.hesitation, secondsAgo: 2, now: now),
            makeEvent(.hesitation, secondsAgo: 3, now: now),
            makeEvent(.hesitation, secondsAgo: 4, now: now) // 6.0
        ]
        let decision = estimator.decide(events: events, now: now, alreadySimplified: false)
        #expect(decision.reason != nil)
        #expect(decision.reason?.isEmpty == false)
    }
}

// MARK: - Sinal dominante / transparência

struct DominantSignalTests {

    private let estimator = CognitiveLoadEstimator()
    private let now = Date()

    @Test func testDominantIsMostImpactfulFriction() {
        let events = [
            makeEvent(.hesitation, secondsAgo: 1, now: now),   // 1.5
            makeEvent(.repeatedTap, secondsAgo: 2, now: now),  // 3.0
            makeEvent(.repeatedTap, secondsAgo: 3, now: now)   // 3.0 → total 6.0
        ]
        #expect(estimator.dominantFrictionKind(in: events) == .repeatedTap)
    }

    @Test func testDominantIgnoresRelief() {
        let events = [
            makeEvent(.taskCompleted, secondsAgo: 1, now: now), // alívio, ignorado
            makeEvent(.retry, secondsAgo: 2, now: now)          // único atrito
        ]
        #expect(estimator.dominantFrictionKind(in: events) == .retry)
    }

    @Test func testExplain_NonEmptyForFriction() {
        let events = [makeEvent(.backNavigation, secondsAgo: 1, now: now)]
        #expect(!estimator.explain(events: events).isEmpty)
    }
}

// MARK: - Configuração customizada (calibração)

struct EstimatorConfigurationTests {

    private let now = Date()

    @Test func testCustomThresholds_ChangeBehavior() {
        // Limiar de sugestão baixo (2.0) → um único erro (3.0) já sugere.
        let config = CognitiveLoadEstimator.Configuration(suggestThreshold: 2.0, autoThreshold: 100)
        let estimator = CognitiveLoadEstimator(configuration: config)
        let events = [makeEvent(.error, secondsAgo: 1, now: now)]
        let decision = estimator.decide(events: events, now: now, alreadySimplified: false)
        if case .suggestSimplified = decision { #expect(Bool(true)) }
        else { #expect(Bool(false), "Config custom deveria sugerir") }
    }

    @Test func testCustomWindow_ExcludesOlderEvents() {
        // Janela de 10s → evento de 20s atrás não conta.
        let config = CognitiveLoadEstimator.Configuration(window: 10)
        let estimator = CognitiveLoadEstimator(configuration: config)
        let events = [makeEvent(.error, secondsAgo: 20, now: now)]
        #expect(estimator.score(events: events, now: now) == 0)
    }
}

// MARK: - Métricas de validação

struct ValidationMetricsTests {

    @Test func testCountByKind() {
        var metrics = ValidationMetrics()
        metrics.count(.repeatedTap)
        metrics.count(.repeatedTap)
        metrics.count(.error)
        metrics.count(.taskCompleted)

        #expect(metrics.repeatedTaps == 2)
        #expect(metrics.errors == 1)
        #expect(metrics.tasksCompleted == 1)
        #expect(metrics.retries == 0)
    }

    @Test func testAcceptanceRate() {
        var metrics = ValidationMetrics()
        metrics.suggestionsShown = 4
        metrics.suggestionsAccepted = 3
        #expect(metrics.acceptanceRate == 0.75)
    }

    @Test func testAcceptanceRate_NilWhenNoSuggestions() {
        let metrics = ValidationMetrics()
        #expect(metrics.acceptanceRate == nil)
    }

    @Test func testTotalAdaptations() {
        var metrics = ValidationMetrics()
        metrics.suggestionsAccepted = 2
        metrics.autoAdaptations = 3
        #expect(metrics.totalAdaptations == 5)
    }

    @Test func testCodableRoundTrip() throws {
        var metrics = ValidationMetrics()
        metrics.repeatedTaps = 5
        metrics.suggestionsShown = 2
        let data = try JSONEncoder().encode(metrics)
        let decoded = try JSONDecoder().decode(ValidationMetrics.self, from: data)
        #expect(decoded == metrics)
    }

    @Test func testSummary_ContainsKeyFields() {
        var metrics = ValidationMetrics()
        metrics.totalTaps = 10
        metrics.repeatedTaps = 2
        let summary = metrics.humanReadableSummary()
        #expect(summary.contains("Toques totais: 10"))
        #expect(summary.contains("Toques repetidos: 2"))
    }
}
