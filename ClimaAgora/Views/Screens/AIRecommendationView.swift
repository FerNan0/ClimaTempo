import SwiftUI

struct AIRecommendationView: View {
    let city: String
    let weather: Weather
    @ObservedObject var viewModel: WeatherViewModel
    @Environment(\.dismiss) var dismiss
    @State private var isGenerating = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Fundo gradiente pastel
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.82, green: 0.85, blue: 1.0),
                        Color(red: 0.90, green: 0.85, blue: 0.98),
                        Color(red: 0.95, green: 0.90, blue: 0.98)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("✨ Recomendações com IA")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                Text(city)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            Spacer()
                            Button(action: { dismiss() }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 44, height: 44)
                            }
                        }
                    }
                    .padding(16)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.45, green: 0.40, blue: 0.85),
                                Color(red: 0.55, green: 0.50, blue: 0.90),
                                Color(red: 0.65, green: 0.50, blue: 0.85)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    
                    if isGenerating {
                        Spacer()
                    } else if let iaResponse = viewModel.iaResponse, !iaResponse.isEmpty {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 16) {
                                // AI Analysis Card
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack(spacing: 8) {
                                        Text("🤖").font(.system(size: 20))
                                        Text("Análise Inteligente")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.3))
                                    }
                                    Text(iaResponse)
                                        .font(.system(size: 14))
                                        .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.4))
                                        .lineSpacing(4)
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(.ultraThinMaterial)
                                        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
                                )
                                
                                // Weather Conditions Card
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack(spacing: 8) {
                                        Text("📊").font(.system(size: 20))
                                        Text("Condições Atuais")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.3))
                                    }
                                    VStack(spacing: 10) {
                                        weatherRow("Temperatura", icon: "thermometer", value: "\(Int(weather.temperature))°C")
                                        weatherRow("Sensação", icon: "hand.raised", value: "\(Int(weather.feelsLike))°C")
                                        weatherRow("Umidade", icon: "water.waves", value: "\(weather.humidity)%")
                                        weatherRow("Vento", icon: "wind", value: String(format: "%.1f km/h", weather.windSpeed))
                                        weatherRow("UV", icon: "sun.max", value: "\(weather.uvIndex)")
                                    }
                                    .padding(12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.white.opacity(0.3))
                                    )
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(.ultraThinMaterial)
                                        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
                                )
                                
                                Spacer().frame(height: 20)
                            }
                            .padding(16)
                        }
                    } else {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 16) {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("💡 Dica")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.3))
                                    Text("Clique no botão abaixo para gerar recomendações personalizadas de atividades, roupas e dicas especiais baseadas nas condições climáticas atuais de \(city).")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color(red: 0.35, green: 0.35, blue: 0.45))
                                        .lineSpacing(4)
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(.ultraThinMaterial)
                                        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
                                )
                                Spacer()
                            }
                            .padding(16)
                        }
                    }
                    
                    // Generate Button
                    Button(action: {
                        HapticManager.shared.trigger(.medium)
                        isGenerating = true
                        viewModel.generateAIRecommendation(for: city, weather: weather) { isGenerating = false }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles")
                            Text(viewModel.iaResponse != nil ? "Gerar Novamente" : "Gerar com IA")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(14)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.45, green: 0.40, blue: 0.85),
                                    Color(red: 0.60, green: 0.50, blue: 0.88)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: Color.purple.opacity(0.2), radius: 8, x: 0, y: 4)
                    }
                    .disabled(isGenerating)
                    .opacity(isGenerating ? 0.6 : 1.0)
                    .padding(16)
                }
            }
            .loadingOverlay(
                isLoading: isGenerating,
                message: "Gerando recomendações personalizadas..."
            )
        }
    }
    
    private func weatherRow(_ label: String, icon: String, value: String) -> some View {
        HStack {
            Label(label, systemImage: icon)
                .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.5))
            Spacer()
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.3))
        }
    }
}

#Preview {
    AIRecommendationView(city: "São Paulo", weather: Weather.preview, viewModel: WeatherViewModel())
}
