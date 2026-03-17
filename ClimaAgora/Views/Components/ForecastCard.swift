import SwiftUI

struct ForecastCard: View {
    let day: DailyForecast
    let viewModel: WeatherViewModel
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            // Day of week
            Text(formatDate(day.date))
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.4))
                .accessibilityLabel("Dia: \(formatDate(day.date))")
            
            // Weather icon
            AnimatedConditionView(condition: day.condition)
                .frame(width: 40, height: 40)
            
            // Temperature
            HStack(spacing: 4) {
                Text("\(Int(viewModel.convertTemperature(day.tempMax)))°")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.3))
                
                Text("\(Int(viewModel.convertTemperature(day.tempMin)))°")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
            }
            .accessibilityLabel("Temperatura máxima \(Int(viewModel.convertTemperature(day.tempMax))) graus, mínima \(Int(viewModel.convertTemperature(day.tempMin))) graus")
            
            // Condition
            Text(day.description.prefix(10))
                .font(.system(size: 11))
                .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.55))
                .lineLimit(1)
                .accessibilityLabel("Condição: \(day.description)")
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
        .frame(width: 100)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Previsão para \(formatDate(day.date))")
        .accessibilityHint("Máxima \(Int(viewModel.convertTemperature(day.tempMax)))°, mínima \(Int(viewModel.convertTemperature(day.tempMin)))°")
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).capitalized
    }
}
