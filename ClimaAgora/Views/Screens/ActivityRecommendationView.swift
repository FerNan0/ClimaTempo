import SwiftUI
import ClimaUI

struct ActivityRecommendationView: View {
    @StateObject var viewModel: ActivityViewModel
    @ObservedObject var accessibility = CognitiveAccessibilityManager.shared
    @Environment(\.dismiss) var dismiss

    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            ClimaGradient.surface.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Atividades em \(viewModel.city)")
                            .font(.system(size: accessibility.useLargeIcons ? 24 : 20, weight: .bold))
                            .foregroundColor(.white)
                        Text(viewModel.weather.condition)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .accessibleButton(label: AccessibilityDescriptions.closeButton, hint: "Fecha a tela de atividades")
                }
                .padding()
                .background(ClimaGradient.brand)

                // Tab Selector
                HStack(spacing: 0) {
                    TabButton(title: "Recomendações", isSelected: selectedTab == 0) { selectedTab = 0 }
                    TabButton(title: "Atividades",    isSelected: selectedTab == 1) { selectedTab = 1 }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)

                if viewModel.state == .loading {
                    Spacer()
                } else {
                    TabView(selection: $selectedTab) {
                        RecommendationsTab(viewModel: viewModel, accessibility: accessibility).tag(0)
                        ActivitiesTab(viewModel: viewModel, accessibility: accessibility).tag(1)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }

                Spacer()
            }
        }
        .loadingOverlay(
            isLoading: viewModel.state == .loading,
            message: accessibility.isSimplifiedMode ? "Preparando dicas..." : "Gerando recomendações com IA..."
        )
        .onAppear {
            viewModel.loadAll()
        }
    }
}

// MARK: - Tab: Recomendações

struct RecommendationsTab: View {
    @ObservedObject var viewModel: ActivityViewModel
    @ObservedObject var accessibility: CognitiveAccessibilityManager

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if accessibility.showVisualSummary {
                    WeatherSafetyBanner(weather: viewModel.weather)
                }
                if accessibility.isSimplifiedMode {
                    SimplifiedWeatherSummary(weather: viewModel.weather)
                }
                if !accessibility.reduceInformation {
                    WeatherInfoCard(weather: viewModel.weather)
                }

                if let response = viewModel.iaResponse {
                    AIResponseCard(
                        title: accessibility.isSimplifiedMode ? "📋 Dicas para Hoje" : "✨ Recomendações Personalizadas",
                        content: response
                    )
                } else {
                    PlaceholderCard(text: "Nenhuma recomendação disponível")
                }

                if !accessibility.reduceInformation {
                    if let suggestion = viewModel.clothingSuggestion {
                        RecommendationCard(emoji: "👕", title: "O que Vestir", content: suggestion)
                    }
                    if let activity = viewModel.activitySuggestion {
                        RecommendationCard(emoji: "🎯", title: "Atividade Sugerida", content: activity)
                    }
                }

                if let alert = viewModel.weatherAlert, alert != "OK" {
                    RecommendationCard(emoji: "⚠️", title: "Alerta de Clima", content: alert)
                }
            }
            .padding()
        }
    }
}

// MARK: - Tab: Atividades

struct ActivitiesTab: View {
    @ObservedObject var viewModel: ActivityViewModel
    @ObservedObject var accessibility: CognitiveAccessibilityManager

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if accessibility.showVisualSummary {
                    WeatherSafetyBanner(weather: viewModel.weather)
                }
                if accessibility.isSimplifiedMode {
                    CategoryLegendView()
                }

                if accessibility.isSimplifiedMode,
                   let structured = viewModel.structuredActivities, !structured.isEmpty {
                    // Caminho PREFERENCIAL: dados estruturados via Guided Generation
                    // (on-device). Sem parsing de string — cada card vem tipado.
                    activityCards(structured.map(AccessibleActivity.init(from:)))
                } else if let activities = viewModel.dynamicActivities {
                    if accessibility.isSimplifiedMode {
                        // Fallback (nuvem/pré-iOS 26): parsing do texto solto.
                        let parsed = AccessibilityHelper.parseActivitiesFromAI(activities)
                        if parsed.isEmpty {
                            AIResponseCard(title: "🎉 Atividades em \(viewModel.city)", content: activities)
                        } else {
                            activityCards(parsed)
                        }
                    } else {
                        AIResponseCard(title: "🎉 Atividades em \(viewModel.city)", content: activities)
                    }
                } else {
                    PlaceholderCard(text: "Nenhuma atividade disponível no momento")
                }
            }
            .padding()
        }
    }

    /// Renderiza a lista de cards acessíveis (usada tanto pelo caminho estruturado
    /// quanto pelo fallback de parsing).
    @ViewBuilder
    private func activityCards(_ activities: [AccessibleActivity]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("🎉 Atividades em \(viewModel.city)")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(ClimaColor.textPrimary)
                .padding(.bottom, 4)
            ForEach(activities) { activity in
                AccessibleActivityCard(activity: activity, useLargeIcons: accessibility.useLargeIcons)
            }
        }
    }
}

// MARK: - Componentes reutilizáveis (sem dependência de ViewModel específico)

struct CategoryLegendView: View {
    let categories: [ActivityCategory] = [.outdoor, .indoor, .exercise, .culture, .food, .relax]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("📖 Tipos de Atividade")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(ClimaColor.textPrimary)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(categories, id: \.rawValue) { cat in
                    HStack(spacing: 4) {
                        Image(systemName: cat.icon).font(.system(size: 12)).foregroundColor(cat.color)
                        Text(cat.rawValue).font(.system(size: 10, weight: .medium)).foregroundColor(ClimaColor.textSecondary)
                    }
                    .padding(.vertical, 4).padding(.horizontal, 6)
                    .background(cat.color.opacity(0.12)).cornerRadius(6)
                }
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(.ultraThinMaterial).shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Legenda de tipos de atividade: Ao Ar Livre, Dentro de Casa, Exercício, Cultura, Comida e Relaxar")
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.callout).fontWeight(.semibold)
                .foregroundColor(isSelected ? ClimaColor.textPrimary : ClimaColor.textTertiary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color.white.opacity(0.6) : Color.clear)
                        .shadow(color: isSelected ? Color.black.opacity(0.05) : Color.clear, radius: 4, x: 0, y: 2)
                )
        }
        .accessibleButton(label: title, hint: isSelected ? "Aba selecionada" : "Toque para selecionar")
    }
}

struct WeatherInfoCard: View {
    let weather: Weather
    var body: some View {
        ClimaCard {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 4) { Image(systemName: "thermometer"); Text("\(Int(weather.temperature))°C") }
                    HStack(spacing: 4) { Image(systemName: "cloud"); Text(weather.condition) }
                    HStack(spacing: 4) { Image(systemName: "drop"); Text("Umidade: \(weather.humidity)%") }
                }
                .font(.footnote).foregroundColor(ClimaColor.textSecondary)
                Spacer()
                VStack(alignment: .trailing, spacing: 8) {
                    HStack(spacing: 4) { Image(systemName: "wind"); Text("\(String(format: "%.1f", weather.windSpeed)) km/h") }
                    HStack(spacing: 4) { Image(systemName: "eye"); Text("\(Double(weather.visibility) / 1000, specifier: "%.1f") km") }
                    HStack(spacing: 4) { Image(systemName: "sun.max"); Text("UV: \(Int(weather.uvIndex))") }
                }
                .font(.footnote).foregroundColor(ClimaColor.textSecondary)
            }
        }
        .accessibleGroup(label: AccessibilityHelper.createStatusDescription(city: weather.city, condition: weather.condition, temperature: Int(weather.temperature)) + ". " + AccessibilityDescriptions.humidity(weather.humidity) + ". " + AccessibilityDescriptions.wind(weather.windSpeed))
    }
}

struct AIResponseCard: View {
    let title: String
    let content: String
    var body: some View {
        ClimaCard {
            VStack(alignment: .leading, spacing: ClimaSpacing.sm + 4) {
                Text(title).font(.headline).foregroundColor(ClimaColor.textPrimary)
                Text(content).font(.body).foregroundColor(ClimaColor.textSecondary).lineLimit(nil).lineSpacing(3)
            }
        }
        .accessibilityElement(children: .combine).accessibilityLabel("\(title). \(content)")
    }
}

struct RecommendationCard: View {
    let emoji: String; let title: String; let content: String
    var body: some View {
        ClimaCard {
            VStack(alignment: .leading, spacing: ClimaSpacing.sm) {
                HStack {
                    Text(emoji).font(.title2)
                    Text(title).font(.headline).foregroundColor(ClimaColor.textPrimary)
                    Spacer()
                }
                Text(content).font(.callout).foregroundColor(ClimaColor.textSecondary).lineLimit(nil).lineSpacing(2)
            }
        }
        .accessibilityElement(children: .combine).accessibilityLabel("\(title). \(content)")
    }
}

struct PlaceholderCard: View {
    let text: String
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "questionmark.circle").font(.system(size: 40)).foregroundColor(ClimaColor.textTertiary)
            Text(text).foregroundColor(ClimaColor.textTertiary).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity).padding()
        .background(RoundedRectangle(cornerRadius: 14).fill(.ultraThinMaterial).shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2))
    }
}

#Preview {
    ActivityRecommendationView(
        viewModel: ActivityViewModel(
            viewData: ActivityViewData(city: "São Paulo", weather: Weather.preview),
            fetchAIUseCase: FetchAIRecommendationsUseCase(repository: IARepository())
        )
    )
}
