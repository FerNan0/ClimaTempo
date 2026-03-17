// filepath: ClimaAgora/Views/Screens/ContentView.swift
import SwiftUI

// MARK: - ContentView (Tela Principal)

struct ContentView: View {
    @StateObject private var viewModel = WeatherViewModel()
    @StateObject private var locationManager = LocationManager()
    @State private var showSearch = false
    @State private var showSettings = false
    @State private var showShareSheet = false
    @State private var showActivityRecommendation = false
    
    /// Determina se o fundo é claro (para ajustar cores do texto)
    private var isLightBackground: Bool {
        guard let weather = viewModel.weather else { return true }
        let now = Date()
        let isNight = now < weather.sunrise || now > weather.sunset
        return !isNight
    }
    
    /// Cor primária do texto baseada no fundo
    private var primaryTextColor: Color {
        isLightBackground ? Color(red: 0.15, green: 0.15, blue: 0.25) : .white
    }
    
    /// Cor secundária do texto baseada no fundo
    private var secondaryTextColor: Color {
        isLightBackground ? Color(red: 0.35, green: 0.35, blue: 0.45) : .white.opacity(0.7)
    }
    
    /// Cor terciária do texto
    private var tertiaryTextColor: Color {
        isLightBackground ? Color(red: 0.5, green: 0.5, blue: 0.6) : .white.opacity(0.5)
    }
    
    /// Cor dos ícones do header
    private var headerIconColor: Color {
        isLightBackground ? Color(red: 0.25, green: 0.25, blue: 0.4) : .white
    }
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            VStack(spacing: 0) {
                headerSection
                mainContentSection
            }
        }
        .sheet(isPresented: $showSearch) {
            SearchView(viewModel: viewModel)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(viewModel: viewModel)
        }
        .sheet(isPresented: $showShareSheet) {
            if let weather = viewModel.weather {
                ShareSheet(items: [ShareManager.shared.generateShareText(for: weather)])
            }
        }
        .sheet(isPresented: $showActivityRecommendation) {
            if let weather = viewModel.weather {
                ActivityRecommendationView(city: viewModel.cityName, weather: weather, viewModel: viewModel)
            }
        }
        .loadingOverlay(
            isLoading: viewModel.isLoading,
            message: "Buscando clima..."
        )
        .loadingOverlay(
            isLoading: viewModel.isLoadingIA && viewModel.weather != nil,
            message: "Gerando sugestões com IA..."
        )
        .onAppear {
            NotificationManager.shared.requestAuthorization()
            if locationManager.cityName != "São Paulo" {
                viewModel.cityName = locationManager.cityName
            }
            viewModel.loadWeather(for: viewModel.cityName)
        }
    }
    
    // MARK: - Background
    
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: viewModel.getBackgroundGradient()),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        HStack {
            Button(action: { showSearch = true }) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(headerIconColor)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(isLightBackground ? 0.5 : 0.15))
                    )
            }
            
            Spacer()
            
            Button(action: {
                HapticManager.shared.trigger(.light)
                viewModel.toggleFavorite()
            }) {
                Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(viewModel.isFavorite ? .red : headerIconColor)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(isLightBackground ? 0.5 : 0.15))
                    )
            }
            
            Button(action: { showSettings = true }) {
                Image(systemName: "gearshape")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(headerIconColor)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(isLightBackground ? 0.5 : 0.15))
                    )
            }
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Main Content
    
    @ViewBuilder
    private var mainContentSection: some View {
        if viewModel.isLoading {
            Spacer()
        } else if let weather = viewModel.weather {
            weatherContentSection(weather: weather)
        } else {
            noConnectionSection
        }
    }
    
    // MARK: - Weather Content
    
    private func weatherContentSection(weather: Weather) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                heroSection(weather: weather)
                    .padding(.bottom, 24)
                
                VStack(spacing: 16) {
                    statsRow(weather: weather)
                    forecastSection
                    suggestionsSection
                    shareButton
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
    }
    
    // MARK: - Hero Section (Temperature + City)
    
    private func heroSection(weather: Weather) -> some View {
        VStack(spacing: 4) {
            Text(viewModel.cityName)
                .font(.system(size: 34, weight: .regular, design: .rounded))
                .foregroundColor(primaryTextColor)
            
            let temp = Int(viewModel.convertTemperature(weather.temperature))
            Text("\(temp)°")
                .font(.system(size: 96, weight: .thin, design: .rounded))
                .foregroundColor(primaryTextColor)
            
            Text(weather.description.capitalized)
                .font(.system(size: 20, weight: .medium, design: .rounded))
                .foregroundColor(secondaryTextColor)
            
            let feelsLike = Int(viewModel.convertTemperature(weather.feelsLike))
            Text("Sensação térmica: \(feelsLike)°")
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(tertiaryTextColor)
                .padding(.top, 2)
        }
        .padding(.top, 8)
    }
    
    // MARK: - Stats Row
    
    private func statsRow(weather: Weather) -> some View {
        HStack(spacing: 0) {
            statItem(icon: "drop.fill", value: "\(weather.humidity)%", label: "Umidade", color: .cyan)
            
            Divider()
                .frame(height: 36)
                .background(isLightBackground ? Color.gray.opacity(0.2) : Color.white.opacity(0.3))
            
            let windText = String(format: "%.1f", weather.windSpeed)
            statItem(icon: "wind", value: "\(windText) km/h", label: "Vento", color: .mint)
            
            Divider()
                .frame(height: 36)
                .background(isLightBackground ? Color.gray.opacity(0.2) : Color.white.opacity(0.3))
            
            statItem(icon: "sun.max.fill", value: "\(Int(weather.uvIndex))", label: "UV", color: .orange)
        }
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        )
    }
    
    private func statItem(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(primaryTextColor)
            Text(label)
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(tertiaryTextColor)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Forecast
    
    private var forecastSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("PREVISÃO DE 5 DIAS", systemImage: "calendar")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(tertiaryTextColor)
                .padding(.horizontal, 4)
            
            VStack(spacing: 0) {
                ForEach(Array(viewModel.forecast.enumerated()), id: \.element.id) { index, day in
                    forecastRow(day: day)
                    
                    if index < viewModel.forecast.count - 1 {
                        Divider()
                            .background(isLightBackground ? Color.gray.opacity(0.15) : Color.white.opacity(0.15))
                            .padding(.horizontal, 16)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
            )
        }
    }
    
    private func forecastRow(day: DailyForecast) -> some View {
        HStack(spacing: 0) {
            Text(formatDayName(day.date))
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(primaryTextColor)
                .frame(width: 50, alignment: .leading)
            
            Spacer()
            
            AnimatedConditionView(condition: day.condition)
                .frame(width: 30, height: 30)
                .scaleEffect(0.5)
                .frame(width: 30, height: 30)
            
            Spacer()
            
            HStack(spacing: 4) {
                let minTemp = Int(viewModel.convertTemperature(day.tempMin))
                Text("\(minTemp)°")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(tertiaryTextColor)
                    .frame(width: 32, alignment: .trailing)
                
                temperatureBar(tempMin: day.tempMin, tempMax: day.tempMax)
                    .frame(width: 80, height: 5)
                
                let maxTemp = Int(viewModel.convertTemperature(day.tempMax))
                Text("\(maxTemp)°")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(primaryTextColor)
                    .frame(width: 32, alignment: .leading)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    private func temperatureBar(tempMin: Double, tempMax: Double) -> some View {
        GeometryReader { geo in
            let overallMin = viewModel.forecast.map(\.tempMin).min() ?? tempMin
            let overallMax = viewModel.forecast.map(\.tempMax).max() ?? tempMax
            let range = overallMax - overallMin
            let width = geo.size.width
            
            let startFraction = range > 0 ? (tempMin - overallMin) / range : 0
            let endFraction = range > 0 ? (tempMax - overallMin) / range : 1
            let barWidth = Swift.max(4, width * (endFraction - startFraction))
            
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(isLightBackground ? Color.gray.opacity(0.15) : Color.white.opacity(0.15))
                
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [.cyan, .yellow, .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: barWidth)
                    .offset(x: width * startFraction)
            }
        }
    }
    
    private func formatDayName(_ date: Date) -> String {
        let calendar = Calendar.current
        if (calendar.isDateInToday(date)) { return "Hoje" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).capitalized
    }
    
    // MARK: - Suggestions
    
    private var suggestionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("SUGESTÕES IA", systemImage: "sparkles")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(tertiaryTextColor)
                .padding(.horizontal, 4)
            
            VStack(spacing: 0) {
                clothingSuggestionCard
                
                Divider()
                    .background(isLightBackground ? Color.gray.opacity(0.15) : Color.white.opacity(0.15))
                    .padding(.horizontal, 16)
                
                activitySuggestionCard
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
            )
        }
    }
    
    private var clothingSuggestionCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "tshirt.fill")
                .font(.system(size: 20))
                .foregroundColor(.blue)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("O que Vestir")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(primaryTextColor)
                
                suggestionText(
                    content: viewModel.clothingSuggestion,
                    isLoading: viewModel.isLoadingIA
                )
            }
            
            Spacer()
        }
        .padding(16)
    }
    
    private var activitySuggestionCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "figure.walk")
                    .font(.system(size: 20))
                    .foregroundColor(.green)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Atividades Recomendadas")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(primaryTextColor)
                    
                    suggestionText(
                        content: viewModel.activitySuggestion,
                        isLoading: viewModel.isLoadingIA
                    )
                }
                
                Spacer()
            }
            
            activityActionButtons
        }
        .padding(16)
    }
    
    @ViewBuilder
    private func suggestionText(content: String?, isLoading: Bool) -> some View {
        if let text = content {
            Text(text)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(secondaryTextColor)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        } else if isLoading {
            Text("Gerando sugestão...")
                .font(.system(size: 14))
                .italic()
                .foregroundColor(tertiaryTextColor)
        } else {
            Text("Toque para gerar sugestão")
                .font(.system(size: 14))
                .italic()
                .foregroundColor(tertiaryTextColor)
        }
    }
    
    private var activityActionButtons: some View {
        HStack(spacing: 10) {
            Button(action: {
                HapticManager.shared.trigger(.light)
                viewModel.fetchActivitySuggestion()
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 11, weight: .semibold))
                    Text("Recarregar")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundColor(isLightBackground ? Color(red: 0.3, green: 0.3, blue: 0.5) : .white)
                .padding(.vertical, 7)
                .padding(.horizontal, 14)
                .background(
                    Capsule()
                        .fill(isLightBackground ? Color.white.opacity(0.6) : Color.white.opacity(0.15))
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                )
            }
            
            Button(action: {
                showActivityRecommendation = true
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 11, weight: .semibold))
                    Text("Ver Mais")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundColor(isLightBackground ? Color(red: 0.3, green: 0.3, blue: 0.5) : .white)
                .padding(.vertical, 7)
                .padding(.horizontal, 14)
                .background(
                    Capsule()
                        .fill(isLightBackground ? Color.white.opacity(0.6) : Color.white.opacity(0.15))
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                )
            }
            
            Spacer()
        }
        .padding(.leading, 44)
    }
    
    // MARK: - Share Button
    
    private var shareButton: some View {
        Button(action: {
            HapticManager.shared.trigger(.medium)
            showShareSheet = true
        }) {
            HStack(spacing: 8) {
                Image(systemName: "square.and.arrow.up")
                Text("Compartilhar")
            }
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(isLightBackground ? Color(red: 0.3, green: 0.3, blue: 0.5) : .white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
            )
        }
    }
    
    // MARK: - No Connection
    
    private var noConnectionSection: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "wifi.slash")
                .font(.system(size: 56, weight: .thin))
                .foregroundColor(tertiaryTextColor)
            
            Text("Sem conexão")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(primaryTextColor)
            
            Text("Verifique sua internet e tente novamente")
                .font(.system(size: 15))
                .foregroundColor(secondaryTextColor)
            
            Button(action: {
                HapticManager.shared.trigger(.medium)
                viewModel.loadWeather(for: viewModel.cityName)
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                    Text("Tentar Novamente")
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.5))
                .padding(.vertical, 12)
                .padding(.horizontal, 24)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                )
            }
            .frame(minHeight: 44)
            
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ContentView()
}
