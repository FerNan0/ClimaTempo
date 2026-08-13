import SwiftUI
import ClimaUI

// MARK: - Componentes novos da Home (design handoff v2)
// Todos usam o ClimaUI (tokens + vidro) e recebem dados de domínio puros.

// Emoji da condição (mesma linguagem visual do app — sem assets).
func weatherEmoji(for condition: String) -> String {
    let c = condition.lowercased()
    if c.contains("thunder") { return "⛈️" }
    if c.contains("drizzle") { return "🌦️" }
    if c.contains("rain")    { return "🌧️" }
    if c.contains("snow")    { return "❄️" }
    if c.contains("cloud")   { return "☁️" }
    if c.contains("clear")   { return "☀️" }
    if c.contains("mist") || c.contains("fog") || c.contains("haze") { return "🌫️" }
    return "🌤️"
}

// MARK: - Modo simples full-screen
//
// Quando o modo simplificado está ativo (por escolha ou pelo motor), a Home
// vira uma tela minimalista: sem cards densos, só o essencial + um conselho em
// linguagem simples gerado on-device. Realiza a tese do TCC — reduzir a carga
// cognitiva estranha ao mínimo — e é sempre reversível ("Voltar ao normal").

struct SimplifiedHomeView: View {
    let weather: Weather
    let advice: SimplifiedAdvice
    let convert: (Double) -> Int
    let onExit: () -> Void

    var body: some View {
        VStack(spacing: ClimaSpacing.lg) {
            Text("MODO SIMPLES ATIVO")
                .font(.system(size: 12, weight: .heavy, design: .rounded)).tracking(1)
                .foregroundStyle(ClimaColor.cyan)
                .padding(.horizontal, ClimaSpacing.md).padding(.vertical, ClimaSpacing.sm)
                .background(Capsule().fill(ClimaColor.cyan.opacity(0.15)))

            Spacer(minLength: 0)

            Text(weather.city)
                .font(.system(size: 30, weight: .heavy, design: .rounded))
                .foregroundStyle(ClimaColor.textPrimary)
            Text("\(convert(weather.temperature))°")
                .font(.system(size: 120, weight: .ultraLight, design: .rounded))
                .foregroundStyle(ClimaColor.textPrimary)
            Text(weather.description.capitalized)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(ClimaColor.textSecondary)

            ClimaGlassCard(cornerRadius: ClimaRadius.xl) {
                VStack(alignment: .leading, spacing: ClimaSpacing.md) {
                    adviceLine(advice.weatherPhrase)
                    adviceLine(advice.advice)
                    if let caution = advice.caution { adviceLine(caution) }
                }
            }

            Spacer(minLength: 0)

            ClimaButton("Voltar ao normal", icon: "arrow.uturn.backward",
                        variant: .secondary, size: .large, action: onExit)
        }
        .padding(ClimaSpacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func adviceLine(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 21, weight: .semibold, design: .rounded))
            .foregroundStyle(ClimaColor.textPrimary)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Rótulo de seção (label em caixa alta, discreto)

struct HomeSectionLabel: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .heavy, design: .rounded))
            .tracking(0.6)
            .foregroundStyle(ClimaColor.textTertiary)
    }
}

// MARK: - Pill do motor cognitivo (🧠 + carga)

struct CognitivePill: View {
    let load: Int
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text("🧠")
                Text("\(load)")
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                    .foregroundStyle(ClimaColor.cognitiveLoad(load))
            }
            .frame(height: 44)
            .padding(.horizontal, ClimaSpacing.md)
            .background(Capsule().fill(ClimaColor.cognitiveLoadFill(load)))
            .overlay(Capsule().stroke(ClimaColor.cognitiveLoad(load).opacity(0.4), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Carga cognitiva \(load) de 10. Toque para ver detalhes do motor de adaptação")
    }
}

// MARK: - Faixa de próximas horas

struct HourlyStripView: View {
    let hourly: [HourlyForecast]
    let convert: (Double) -> Int
    var onItemTap: () -> Void = {}

    var body: some View {
        ClimaGlassCard {
            VStack(alignment: .leading, spacing: ClimaSpacing.sm) {
                HomeSectionLabel(text: "PRÓXIMAS HORAS")
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: ClimaSpacing.lg) {
                        ForEach(hourly) { item in
                            Button(action: onItemTap) {
                                VStack(spacing: 6) {
                                    Text(hour(item.time))
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(ClimaColor.textSecondary)
                                    Text(weatherEmoji(for: item.condition)).font(.system(size: 20))
                                    Text("\(convert(item.temperature))°")
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                        .foregroundStyle(ClimaColor.textPrimary)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    private func hour(_ date: Date) -> String {
        let f = DateFormatter(); f.locale = Locale(identifier: "pt_BR"); f.dateFormat = "HH'h'"
        return f.string(from: date)
    }
}

// MARK: - Card nascer / pôr do sol (arco + posição do sol)

struct SunCardView: View {
    let weather: Weather

    var body: some View {
        ClimaGlassCard {
            VStack(alignment: .leading, spacing: ClimaSpacing.sm) {
                HomeSectionLabel(text: "NASCER / PÔR DO SOL")
                GeometryReader { geo in
                    let w = geo.size.width, h = geo.size.height
                    let p = weather.daylightProgress()
                    ZStack {
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: h))
                            path.addQuadCurve(to: CGPoint(x: w, y: h),
                                              control: CGPoint(x: w / 2, y: -h * 0.5))
                        }
                        .stroke(ClimaColor.textTertiary.opacity(0.5),
                                style: StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                        let pt = sunPoint(progress: p, width: w, height: h)
                        Circle().fill(ClimaColor.caution).frame(width: 14, height: 14).position(pt)
                    }
                }
                .frame(height: 60)
                HStack {
                    sunTime(icon: "↑", date: weather.sunrise)
                    Spacer()
                    sunTime(icon: "↓", date: weather.sunset)
                }
            }
        }
    }

    private func sunPoint(progress: CGFloat, width w: CGFloat, height h: CGFloat) -> CGPoint {
        // Quadrática de (0,h) a (w,h) com controle (w/2, -h/2).
        let t = progress
        let x = 2 * (1 - t) * t * (w / 2) + t * t * w
        let y = pow(1 - t, 2) * h + 2 * (1 - t) * t * (-h * 0.5) + t * t * h
        return CGPoint(x: x, y: y)
    }

    private func sunTime(icon: String, date: Date) -> some View {
        let f = DateFormatter(); f.locale = Locale(identifier: "pt_BR"); f.dateFormat = "HH:mm"
        return HStack(spacing: 4) {
            Text(icon).foregroundStyle(ClimaColor.textTertiary)
            Text(f.string(from: date))
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(ClimaColor.textPrimary)
        }
    }
}

// MARK: - Card qualidade do ar

struct AirQualityCardView: View {
    let airQuality: AirQuality

    var body: some View {
        ClimaGlassCard {
            VStack(alignment: .leading, spacing: ClimaSpacing.sm) {
                HomeSectionLabel(text: "QUALIDADE DO AR")
                Text("\(airQuality.level.rawValue)")
                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                    .foregroundStyle(ClimaColor.textPrimary)
                Text(airQuality.level.label)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(barColor)
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(LinearGradient(colors: [ClimaColor.safe, ClimaColor.caution, ClimaColor.danger],
                                                 startPoint: .leading, endPoint: .trailing))
                            .frame(height: 6)
                        Circle().fill(.white)
                            .frame(width: 12, height: 12)
                            .overlay(Circle().stroke(barColor, lineWidth: 2))
                            .position(x: geo.size.width * airQuality.level.barPosition, y: 3)
                    }
                }
                .frame(height: 12)
            }
        }
    }

    private var barColor: Color {
        switch airQuality.level {
        case .good, .fair: return ClimaColor.safe
        case .moderate:    return ClimaColor.caution
        case .poor, .veryPoor: return ClimaColor.danger
        }
    }
}

// MARK: - Previsão por período (3/7/10d)

struct ForecastPeriodView: View {
    @Binding var period: ForecastPeriod
    let days: [DailyForecast]
    let summary: ForecastSummary
    let convert: (Double) -> Int
    var onRowTap: () -> Void = {}

    var body: some View {
        ClimaGlassCard {
            VStack(alignment: .leading, spacing: ClimaSpacing.md) {
                HStack {
                    HomeSectionLabel(text: "PREVISÃO")
                    Spacer()
                    ClimaSegmented(ForecastPeriod.allCases, selection: $period) { $0.label }
                        .frame(width: 150)
                }
                HStack(spacing: ClimaSpacing.sm) {
                    ClimaSummaryTile(value: "\(convert(summary.averageMax))°", label: "Máx. média")
                    ClimaSummaryTile(value: "\(convert(summary.averageMin))°", label: "Mín. média")
                    ClimaSummaryTile(value: "\(summary.rainyDays)", label: "Dias de chuva")
                }
                VStack(spacing: 0) {
                    ForEach(days) { day in
                        Button(action: onRowTap) {
                            forecastRow(day)
                        }
                        .buttonStyle(.plain)
                        if day.id != days.last?.id {
                            Divider().overlay(ClimaColor.textTertiary.opacity(0.2))
                        }
                    }
                }
            }
        }
    }

    private func forecastRow(_ day: DailyForecast) -> some View {
        HStack {
            Text(dayName(day.date))
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(ClimaColor.textPrimary)
                .frame(width: 48, alignment: .leading)
            Text(weatherEmoji(for: day.condition)).font(.system(size: 18))
            Spacer()
            Text("\(convert(day.tempMin))°")
                .font(.system(size: 14)).foregroundStyle(ClimaColor.textTertiary)
                .frame(width: 32, alignment: .trailing)
            tempBar(day)
                .frame(width: 70, height: 5)
            Text("\(convert(day.tempMax))°")
                .font(.system(size: 14, weight: .semibold)).foregroundStyle(ClimaColor.textPrimary)
                .frame(width: 32, alignment: .leading)
        }
        .padding(.vertical, ClimaSpacing.sm + 2)
    }

    private func tempBar(_ day: DailyForecast) -> some View {
        GeometryReader { geo in
            let allMin = days.map(\.tempMin).min() ?? day.tempMin
            let allMax = days.map(\.tempMax).max() ?? day.tempMax
            let range = max(1, allMax - allMin)
            let start = (day.tempMin - allMin) / range
            let end = (day.tempMax - allMin) / range
            let barW = max(6, geo.size.width * (end - start))
            ZStack(alignment: .leading) {
                Capsule().fill(ClimaColor.textTertiary.opacity(0.2))
                Capsule()
                    .fill(LinearGradient(colors: [ClimaColor.sky, ClimaColor.caution],
                                         startPoint: .leading, endPoint: .trailing))
                    .frame(width: barW)
                    .offset(x: geo.size.width * start)
            }
        }
    }

    private func dayName(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) { return "Hoje" }
        let f = DateFormatter(); f.locale = Locale(identifier: "pt_BR"); f.dateFormat = "EEE"
        return f.string(from: date).capitalized
    }
}
