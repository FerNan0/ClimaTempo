import SwiftUI
import ClimaUI

// MARK: - ContentView (Home) — redesign v2
//
// Renderiza o `state` e escuta o `route` para navegar. Toda a UI usa o
// Design System ClimaUI (tokens + vidro). O motor de adaptação cognitiva
// aparece em destaque (pill 🧠 no header + banner de sugestão), reforçando
// o propósito do app: reduzir a carga cognitiva e adaptar-se ao usuário.

struct ContentView: View {
    @ObservedObject var viewModel: HomeViewModel
    let router: AppRouting
    @ObservedObject var locationManager: LocationManager
    @ObservedObject private var engine = AdaptiveEngine.shared
    @ObservedObject private var accessibility = CognitiveAccessibilityManager.shared
    @State private var cogSheetOpen = false

    var body: some View {
        ZStack {
            ClimaGradient.surface.ignoresSafeArea()

            VStack(spacing: 0) {
                header
                AdaptiveSuggestionBanner()
                content
            }
        }
        .adaptiveScreen("Home")
        .sheet(item: $viewModel.route) { destination(for: $0) }
        .sheet(isPresented: $cogSheetOpen) { CognitiveSheet() }
        .loadingOverlay(isLoading: viewModel.state == .loading, message: "Buscando clima...")
        .onAppear {
            NotificationManager.shared.requestAuthorization()
            if locationManager.cityName != "São Paulo" { viewModel.cityName = locationManager.cityName }
            viewModel.start()
        }
    }

    // MARK: - Header (pills de vidro + pill do motor cognitivo)

    private var header: some View {
        HStack(spacing: ClimaSpacing.sm + 2) {
            pillButton("magnifyingglass") { viewModel.didTapSearch() }
            CognitivePill(load: min(10, Int(engine.currentLoad.rounded()))) { cogSheetOpen = true }
            Spacer()
            pillButton(viewModel.isFavorite ? "heart.fill" : "heart",
                       tint: viewModel.isFavorite ? ClimaColor.danger : nil) {
                HapticManager.shared.trigger(.light)
                viewModel.toggleFavorite()
            }
            pillButton("gearshape") { viewModel.didTapSettings() }
        }
        .padding(.horizontal, ClimaSpacing.md)
        .padding(.top, ClimaSpacing.sm)
    }

    private func pillButton(_ icon: String, tint: Color? = nil, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(tint ?? ClimaColor.textPrimary)
                .frame(width: 44, height: 44)
                .background(Circle().fill(.ultraThinMaterial))
                .overlay(Circle().stroke(ClimaColor.glassBorder, lineWidth: 1))
        }
    }

    // MARK: - Conteúdo por estado

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            Spacer()
        case .loaded:
            if let weather = viewModel.weather {
                if accessibility.isSimplifiedMode {
                    SimplifiedHomeView(
                        weather: weather,
                        advice: viewModel.simplifiedAdvice ?? .fallback(for: weather),
                        convert: convertInt,
                        risks: viewModel.weatherRisks,
                        officialAlerts: viewModel.officialAlerts
                    ) {
                        withAnimation { accessibility.isSimplifiedMode = false }
                    }
                } else {
                    weatherContent(weather)
                }
            }
        case .failed:
            noConnection
        }
    }

    private func weatherContent(_ weather: Weather) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: ClimaSpacing.md) {
                alertsArea
                hero(weather)
                statsRow(weather)

                if !viewModel.hourly.isEmpty {
                    HourlyStripView(hourly: viewModel.hourly, convert: convertInt) {
                        engine.registerTap(on: "Home")
                    }
                }

                HStack(spacing: ClimaSpacing.md) {
                    SunCardView(weather: weather)
                    if let aqi = viewModel.airQuality {
                        AirQualityCardView(airQuality: aqi)
                    }
                }

                if !viewModel.forecast.isEmpty {
                    ForecastPeriodView(
                        period: $viewModel.forecastPeriod,
                        days: viewModel.visibleForecast,
                        summary: viewModel.forecastSummary,
                        convert: convertInt
                    ) { engine.registerTap(on: "Home") }
                }

                suggestions
                shareButton
            }
            .padding(.horizontal, 18)
            .padding(.vertical, ClimaSpacing.md)
        }
    }

    private func convertInt(_ celsius: Double) -> Int {
        Int(viewModel.convertTemperature(celsius).rounded())
    }

    /// Área de avisos no topo da Home: avisos OFICIAIS (INMET) primeiro, depois
    /// o risco derivado on-device. Sem nada disso, só mostra "tudo tranquilo"
    /// se o usuário quer o semáforo e não pediu para reduzir informações.
    @ViewBuilder
    private var alertsArea: some View {
        ForEach(viewModel.officialAlerts) { alert in
            OfficialAlertCard(alert: alert,
                              simplified: false,
                              largeIcons: accessibility.useLargeIcons)
        }
        if !viewModel.weatherRisks.isEmpty {
            WeatherRiskCard(risks: viewModel.weatherRisks,
                            simplified: false,
                            largeIcons: accessibility.useLargeIcons)
        } else if viewModel.officialAlerts.isEmpty,
                  accessibility.showVisualSummary, !accessibility.reduceInformation {
            WeatherRiskCard(risks: [],
                            simplified: false,
                            largeIcons: accessibility.useLargeIcons)
        }
    }

    // MARK: - Hero (clicável → alimenta o motor de fricção)

    private func hero(_ weather: Weather) -> some View {
        VStack(spacing: 2) {
            Text(viewModel.cityName)
                .font(.system(size: 24, weight: .heavy, design: .rounded))
                .foregroundStyle(ClimaColor.textPrimary)
            Text("\(convertInt(weather.temperature))°")
                .font(.system(size: 96, weight: .ultraLight, design: .rounded))
                .foregroundStyle(ClimaColor.textPrimary)
            Text(weather.description.capitalized)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(ClimaColor.textSecondary)
            Text("Sensação térmica: \(convertInt(weather.feelsLike))°")
                .font(.system(size: 13))
                .foregroundStyle(ClimaColor.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, ClimaSpacing.sm)
        .contentShape(Rectangle())
        .onTapGesture { engine.registerTap(on: "Home") }
    }

    // MARK: - Stats (umidade / vento / UV)

    private func statsRow(_ weather: Weather) -> some View {
        HStack(spacing: ClimaSpacing.sm) {
            statTile("💧", "\(weather.humidity)%", "Umidade")
            statTile("💨", "\(String(format: "%.0f", weather.windKmh)) km/h", "Vento")
            statTile("☀️", "\(Int(weather.uvIndex))", "Índice UV")
        }
    }

    private func statTile(_ emoji: String, _ value: String, _ label: String) -> some View {
        VStack(spacing: 5) {
            Text(emoji).font(.system(size: 18))
            Text(value).font(.system(size: 15, weight: .heavy, design: .rounded)).foregroundStyle(ClimaColor.textPrimary)
            Text(label).font(.system(size: 10.5, weight: .bold)).foregroundStyle(ClimaColor.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, ClimaSpacing.md)
        .climaGlass(cornerRadius: ClimaRadius.lg)
    }

    // MARK: - Sugestões de IA

    private var suggestions: some View {
        VStack(alignment: .leading, spacing: ClimaSpacing.sm) {
            HomeSectionLabel(text: "SUGESTÕES IA ✨")
            ClimaGlassCard {
                suggestionRow(icon: "👕", title: "O que Vestir", text: viewModel.clothingSuggestion)
            }
            Button { viewModel.didTapSeeMore() } label: {
                ClimaGlassCard {
                    HStack {
                        suggestionRow(icon: "🎯", title: "Atividade Sugerida", text: viewModel.activitySuggestion)
                        Image(systemName: "chevron.right").foregroundStyle(ClimaColor.textTertiary)
                    }
                }
            }
            .buttonStyle(.plain)
        }
    }

    private func suggestionRow(icon: String, title: String, text: String?) -> some View {
        HStack(alignment: .top, spacing: ClimaSpacing.sm + 2) {
            Text(icon).font(.system(size: 20))
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.system(size: 15, weight: .heavy, design: .rounded)).foregroundStyle(ClimaColor.textPrimary)
                if let text {
                    Text(text).font(.system(size: 13)).foregroundStyle(ClimaColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                } else if viewModel.isLoadingIA {
                    Text("Gerando sugestão...").font(.system(size: 13)).italic().foregroundStyle(ClimaColor.textTertiary)
                } else {
                    Text("Toque para gerar").font(.system(size: 13)).italic().foregroundStyle(ClimaColor.textTertiary)
                }
            }
            Spacer(minLength: 0)
        }
    }

    // MARK: - Compartilhar

    private var shareButton: some View {
        ClimaButton("Compartilhar", icon: "square.and.arrow.up", variant: .secondary) {
            HapticManager.shared.trigger(.medium)
            viewModel.didTapShare()
        }
    }

    // MARK: - Sem conexão

    private var noConnection: some View {
        VStack(spacing: ClimaSpacing.md) {
            Spacer()
            Image(systemName: "wifi.slash").font(.system(size: 52, weight: .thin)).foregroundStyle(ClimaColor.textTertiary)
            Text("Sem conexão").font(.system(size: 22, weight: .bold, design: .rounded)).foregroundStyle(ClimaColor.textPrimary)
            Text("Verifique sua internet e tente novamente").font(.system(size: 14)).foregroundStyle(ClimaColor.textSecondary)
            ClimaButton("Tentar Novamente", icon: "arrow.clockwise") {
                HapticManager.shared.trigger(.medium)
                AdaptiveEngine.shared.registerRetry(on: "Home")
                viewModel.loadWeather(for: viewModel.cityName)
            }
            .fixedSize()
            Spacer(); Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    // MARK: - Roteamento

    @MainActor @ViewBuilder
    private func destination(for route: HomeViewModel.Route) -> some View {
        switch route {
        case .search:
            SearchView(viewModel: router.makeSearchViewModel(onCitySelected: { viewModel.loadWeather(for: $0) }))
        case .settings:
            SettingsView()
        case .activity:
            if let weather = viewModel.weather {
                ActivityRecommendationView(
                    viewModel: router.makeActivityViewModel(viewData: ActivityViewData(city: viewModel.cityName, weather: weather))
                )
            }
        case .share:
            if let weather = viewModel.weather {
                ShareSheet(items: [ShareManager.shared.generateShareText(for: weather)])
            }
        }
    }
}

#Preview {
    AppRouter()
}
