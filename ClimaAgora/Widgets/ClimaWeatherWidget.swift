import WidgetKit
import SwiftUI

// MARK: - Widget Entry
struct ClimaWeatherEntry: TimelineEntry {
    let date: Date
    let cityName: String
    let temperature: Double
    let condition: String
    let description: String
    let humidity: Int
    let windSpeed: Double
}

// MARK: - Widget Timeline Provider
struct ClimaWeatherProvider: TimelineProvider {
    func placeholder(in context: Context) -> ClimaWeatherEntry {
        ClimaWeatherEntry(
            date: Date(),
            cityName: "São Paulo",
            temperature: 25,
            condition: "Nublado",
            description: "Céu nublado",
            humidity: 65,
            windSpeed: 12
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (ClimaWeatherEntry) -> ()) {
        let entry = ClimaWeatherEntry(
            date: Date(),
            cityName: "São Paulo",
            temperature: 25,
            condition: "Nublado",
            description: "Céu nublado",
            humidity: 65,
            windSpeed: 12
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ClimaWeatherEntry>) -> ()) {
        // Buscar dados do UserDefaults (salvos pelo app principal)
        let defaults = UserDefaults(suiteName: "group.com.climaagora.widget")
        
        var entries: [ClimaWeatherEntry] = []
        
        let cityName = defaults?.string(forKey: "widget_city") ?? "São Paulo"
        let temperature = defaults?.double(forKey: "widget_temp") ?? 25
        let condition = defaults?.string(forKey: "widget_condition") ?? "Nublado"
        let description = defaults?.string(forKey: "widget_description") ?? "Céu nublado"
        let humidity = defaults?.integer(forKey: "widget_humidity") ?? 65
        let windSpeed = defaults?.double(forKey: "widget_wind") ?? 12
        
        // Criar entrada para cada hora nas próximas 12 horas
        for i in 0..<12 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: i, to: Date()) ?? Date()
            let entry = ClimaWeatherEntry(
                date: entryDate,
                cityName: cityName,
                temperature: temperature,
                condition: condition,
                description: description,
                humidity: humidity,
                windSpeed: windSpeed
            )
            entries.append(entry)
        }
        
        // Próxima atualização em 1 hora
        let nextRefresh = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        let timeline = Timeline(entries: entries, policy: .after(nextRefresh))
        completion(timeline)
    }
}

// MARK: - Small Widget View
struct ClimaWeatherSmallWidgetView: View {
    let entry: ClimaWeatherProvider.Entry
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(entry.cityName)
                    .font(.headline)
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.35))
                Spacer()
                Image(systemName: "cloud.sun.fill")
                    .foregroundColor(.orange)
            }
            
            HStack {
                Text("\(Int(entry.temperature))°")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.3))
                
                VStack(alignment: .leading) {
                    Text(entry.condition)
                        .font(.caption)
                        .foregroundColor(Color(red: 0.35, green: 0.35, blue: 0.5))
                    Text("\(entry.humidity)%")
                        .font(.caption2)
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                }
                Spacer()
            }
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.82, green: 0.90, blue: 1.0),
                    Color(red: 0.90, green: 0.88, blue: 1.0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

// MARK: - Medium Widget View
struct ClimaWeatherMediumWidgetView: View {
    let entry: ClimaWeatherProvider.Entry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.cityName)
                        .font(.headline)
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.35))
                    Text(entry.description.capitalized)
                        .font(.caption)
                        .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.55))
                }
                Spacer()
                Image(systemName: "cloud.sun.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.orange)
            }
            
            HStack(spacing: 16) {
                VStack(alignment: .leading) {
                    Text("Temp")
                        .font(.caption2)
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                    Text("\(Int(entry.temperature))°C")
                        .font(.headline)
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.35))
                }
                
                Divider()
                
                VStack(alignment: .leading) {
                    Text("Umidade")
                        .font(.caption2)
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                    Text("\(entry.humidity)%")
                        .font(.headline)
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.35))
                }
                
                Divider()
                
                VStack(alignment: .leading) {
                    Text("Vento")
                        .font(.caption2)
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                    Text("\(String(format: "%.0f", entry.windSpeed)) km/h")
                        .font(.headline)
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.35))
                }
                
                Spacer()
            }
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.82, green: 0.90, blue: 1.0),
                    Color(red: 0.90, green: 0.88, blue: 1.0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

// MARK: - Bundle & Widget
struct ClimaWeatherWidget: Widget {
    let kind: String = "ClimaWeatherWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ClimaWeatherProvider()) { entry in
            ClimaWeatherSmallWidgetView(entry: entry)
        }
        .configurationDisplayName("ClimaAgora")
        .description("Veja o clima da sua cidade no widget")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    ClimaWeatherWidget()
} timeline: {
    ClimaWeatherEntry(
        date: Date(),
        cityName: "São Paulo",
        temperature: 25,
        condition: "Ensolarado",
        description: "Céu limpo",
        humidity: 65,
        windSpeed: 12
    )
}
