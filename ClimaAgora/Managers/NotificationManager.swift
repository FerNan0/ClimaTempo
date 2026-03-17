import Foundation
import UIKit
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    // MARK: - Solicitar Permissão
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("✅ Notificações autorizadas")
            } else if let error = error {
                print("❌ Erro ao solicitar notificações: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Agendador Notificação Diária
    func scheduleDailySummary(at hour: Int = 8, minute: Int = 0, weather: Weather) {
        let content = UNMutableNotificationContent()
        content.title = "☀️ Resumo do Clima"
        content.body = "Em \(weather.city): \(weather.description.capitalized), \(Int(weather.temperature))°C"
        content.sound = .default
        content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
        
        // Dados adicionais para ação customizada
        content.userInfo = [
            "city": weather.city,
            "temperature": weather.temperature,
            "condition": weather.condition
        ]
        
        // Agendador repetido diariamente
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_summary", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Erro ao agendar notificação diária: \(error.localizedDescription)")
            } else {
                print("✅ Notificação diária agendada para \(hour):\(String(format: "%02d", minute))")
            }
        }
    }
    
    // MARK: - Alerta de Chuva
    func scheduleRainAlert(for weather: Weather, in minutes: Int = 30) {
        let condition = weather.condition.lowercased()
        
        guard condition.contains("rain") || condition.contains("drizzle") else {
            print("⚠️ Não há previsão de chuva")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "☔ Alerta de Chuva"
        content.body = "Pode chover em \(weather.city). Leve um guarda-chuva!"
        content.sound = .default
        content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(minutes * 60), repeats: false)
        let request = UNNotificationRequest(identifier: "rain_alert_\(UUID().uuidString)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Erro ao agendar alerta de chuva: \(error.localizedDescription)")
            } else {
                print("✅ Alerta de chuva agendado em \(minutes) minutos")
            }
        }
    }
    
    // MARK: - Alerta de Temperatura Extrema
    func scheduleExtremeTemperatureAlert(for weather: Weather) {
        var shouldAlert = false
        var title = ""
        var message = ""
        
        if weather.temperature < 0 {
            shouldAlert = true
            title = "❄️ Alerta: Muito Frio"
            message = "Temperatura abaixo de 0°C em \(weather.city). Tome cuidado!"
        } else if weather.temperature > 35 {
            shouldAlert = true
            title = "🌡️ Alerta: Muito Quente"
            message = "Temperatura acima de 35°C em \(weather.city). Hidrate-se!"
        }
        
        guard shouldAlert else { return }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = .default
        content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "extreme_temp_\(UUID().uuidString)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Erro ao agendar alerta de temperatura: \(error.localizedDescription)")
            } else {
                print("✅ Alerta de temperatura agendado")
            }
        }
    }
    
    // MARK: - Cancelar Todas as Notificações
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("✅ Todas as notificações foram canceladas")
    }
    
    // MARK: - Cancelar Notificação Específica
    func cancelNotification(withIdentifier identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        print("✅ Notificação \(identifier) foi cancelada")
    }
}
