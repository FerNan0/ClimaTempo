import SwiftUI
import ClimaUI

// SettingsView não precisa de ViewModel — gerencia preferências locais
// diretamente via UserDefaults e CognitiveAccessibilityManager.

struct SettingsView: View {
    @ObservedObject var accessibility = CognitiveAccessibilityManager.shared
    @ObservedObject private var engine = AdaptiveEngine.shared
    @Environment(\.dismiss) var dismiss
    @State private var temperatureUnit    = UserDefaults.standard.string(forKey: "temperatureUnit") ?? "Celsius"
    @State private var notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.82, green: 0.90, blue: 1.0),
                        Color(red: 0.92, green: 0.86, blue: 0.98),
                        Color(red: 0.98, green: 0.90, blue: 0.95)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    headerView
                    contentView
                }
            }
        }
    }

    // MARK: - Header

    var headerView: some View {
        HStack(spacing: 14) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Circle())
            }
            Text("Configurações")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            Spacer()
        }
        .padding(.horizontal, 20).padding(.top, 12).padding(.bottom, 18)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.35, green: 0.55, blue: 0.95),
                    Color(red: 0.58, green: 0.48, blue: 0.92),
                    Color(red: 0.78, green: 0.52, blue: 0.85)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
    }

    // MARK: - Content

    var contentView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                unitCard
                notificationsCard
                adaptiveCard
                accessibilityCard
                aboutCard
            }
            .padding(.horizontal, 18).padding(.top, 20).padding(.bottom, 32)
        }
    }

    // MARK: - Temperatura

    var unitCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "thermometer.medium")
                    .font(.system(size: 16, weight: .semibold)).foregroundColor(.orange)
                    .frame(width: 32, height: 32).background(Color.orange.opacity(0.12)).clipShape(RoundedRectangle(cornerRadius: 8))
                Text("Temperatura")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.32))
            }
            Picker("Unidade", selection: $temperatureUnit) {
                Text("Celsius").tag("Celsius")
                Text("Fahrenheit").tag("Fahrenheit")
                Text("Kelvin").tag("Kelvin")
            }
            .pickerStyle(.segmented)
            .onChange(of: temperatureUnit) { _, newValue in
                UserDefaults.standard.setValue(newValue, forKey: "temperatureUnit")
            }
        }
        .padding(16).background(cardBackground)
    }

    // MARK: - Notificações

    var notificationsCard: some View {
        HStack(spacing: 14) {
            Image(systemName: notificationsEnabled ? "bell.badge.fill" : "bell.fill")
                .font(.system(size: 16, weight: .semibold)).foregroundColor(.green)
                .frame(width: 32, height: 32).background(Color.green.opacity(0.12)).clipShape(RoundedRectangle(cornerRadius: 8))
            VStack(alignment: .leading, spacing: 2) {
                Text("Notificações")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.32))
                Text(notificationsEnabled ? "Ativadas" : "Desativadas")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(notificationsEnabled ? .green : Color(red: 0.55, green: 0.55, blue: 0.65))
            }
            Spacer()
            Toggle("", isOn: $notificationsEnabled)
                .labelsHidden().tint(.green)
                .onChange(of: notificationsEnabled) { _, newValue in
                    UserDefaults.standard.setValue(newValue, forKey: "notificationsEnabled")
                    if newValue { NotificationManager.shared.requestAuthorization() }
                }
        }
        .padding(16).background(cardBackground)
    }

    // MARK: - Adaptação Automática (motor comportamental)

    var adaptiveCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: "wand.and.sparkles")
                    .font(.system(size: 16, weight: .semibold)).foregroundColor(.indigo)
                    .frame(width: 32, height: 32).background(Color.indigo.opacity(0.12)).clipShape(RoundedRectangle(cornerRadius: 8))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Adaptação Automática")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.28))
                    Text("O app percebe quando a tela está difícil e ajuda sozinho")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
            }
            .padding(.horizontal, 16).padding(.top, 16).padding(.bottom, 14)

            Rectangle().fill(Color.gray.opacity(0.12)).frame(height: 1).padding(.horizontal, 16)

            VStack(spacing: 0) {
                ClimaToggleRow(icon: "brain.filled.head.profile", iconColor: .indigo,
                               title: "Ativar adaptação automática",
                               subtitle: "Sugere simplificar quando percebe dificuldade",
                               isOn: $accessibility.automaticAdaptationEnabled)
                if accessibility.automaticAdaptationEnabled {
                    toggleDivider
                    ClimaToggleRow(icon: "bolt.badge.automatic", iconColor: .orange,
                                   title: "Simplificar sem perguntar",
                                   subtitle: "Em caso de muita dificuldade, adapta sozinho (sempre reversível)",
                                   isOn: $accessibility.allowAutoApply)
                }
            }
            .padding(.vertical, 4)

            Rectangle().fill(Color.gray.opacity(0.12)).frame(height: 1).padding(.horizontal, 16)

            // Métricas locais de validação — evidência empírica para o TCC.
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Carga cognitiva agora")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.5))
                    Spacer()
                    Text(String(format: "%.0f", engine.currentLoad))
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(engine.currentLoad >= 6 ? .orange : .green)
                }
                metricRow("Sinais de atrito", value: engine.telemetry.metrics.repeatedTaps + engine.telemetry.metrics.retries + engine.telemetry.metrics.errors + engine.telemetry.metrics.hesitations + engine.telemetry.metrics.backNavigations)
                metricRow("Sugestões mostradas", value: engine.telemetry.metrics.suggestionsShown)
                metricRow("Sugestões aceitas", value: engine.telemetry.metrics.suggestionsAccepted)
                metricRow("Adaptações automáticas", value: engine.telemetry.metrics.autoAdaptations)
            }
            .padding(.horizontal, 16).padding(.vertical, 12)

            Button(action: {
                HapticManager.shared.trigger(.light)
                engine.telemetry.resetMetrics()
            }) {
                Text("Zerar métricas da sessão")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.indigo)
                    .frame(maxWidth: .infinity).padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.indigo.opacity(0.1)))
            }
            .padding(.horizontal, 16).padding(.bottom, 16)
        }
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.55))
                .shadow(color: Color.indigo.opacity(0.08), radius: 12, x: 0, y: 4)
        )
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.indigo.opacity(0.18), lineWidth: 1))
    }

    private func metricRow(_ label: String, value: Int) -> some View {
        HStack {
            Text(label).font(.system(size: 13)).foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.55))
            Spacer()
            Text("\(value)").font(.system(size: 13, weight: .semibold, design: .monospaced))
                .foregroundColor(Color(red: 0.25, green: 0.25, blue: 0.38))
        }
    }

    // MARK: - Acessibilidade Cognitiva

    var accessibilityCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 16, weight: .semibold)).foregroundColor(.cyan)
                    .frame(width: 32, height: 32).background(Color.cyan.opacity(0.12)).clipShape(RoundedRectangle(cornerRadius: 8))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Acessibilidade Cognitiva")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.28))
                    Text("Facilita a compreensão das informações")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                }
                Spacer()
            }
            .padding(.horizontal, 16).padding(.top, 16).padding(.bottom, 14)

            Rectangle().fill(Color.gray.opacity(0.12)).frame(height: 1).padding(.horizontal, 16)

            VStack(spacing: 0) {
                ClimaToggleRow(icon: "textformat.abc",            iconColor: .green,  title: "Linguagem Simplificada", subtitle: "Textos mais curtos e fáceis de entender",  isOn: $accessibility.isSimplifiedMode)
                toggleDivider
                ClimaToggleRow(icon: "plus.magnifyingglass",      iconColor: .orange, title: "Ícones Grandes",          subtitle: "Aumenta ícones e áreas de toque",          isOn: $accessibility.useLargeIcons)
                toggleDivider
                ClimaToggleRow(icon: "circle.lefthalf.filled",    iconColor: .yellow, title: "Semáforo de Clima",       subtitle: "Mostra 🟢🟡🔴 se é seguro sair",          isOn: $accessibility.showVisualSummary)
                toggleDivider
                ClimaToggleRow(icon: "eye.slash",                 iconColor: .blue,   title: "Reduzir Informações",     subtitle: "Mostra só o essencial",                    isOn: $accessibility.reduceInformation)
                toggleDivider
                ClimaToggleRow(icon: "iphone.radiowaves.left.and.right", iconColor: .pink, title: "Vibração Reforçada", subtitle: "Vibra mais forte ao tocar nos botões",     isOn: $accessibility.enhancedHaptics)
            }
            .padding(.vertical, 4)

            Rectangle().fill(Color.gray.opacity(0.12)).frame(height: 1).padding(.horizontal, 16)

            HStack(spacing: 10) {
                Button(action: {
                    HapticManager.shared.trigger(.medium)
                    withAnimation(.easeInOut(duration: 0.2)) { accessibility.enableAll() }
                }) {
                    HStack(spacing: 5) {
                        Image(systemName: "checkmark.circle.fill").font(.system(size: 13))
                        Text("Ativar Tudo").font(.system(size: 13, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, 11)
                    .background(RoundedRectangle(cornerRadius: 10).fill(LinearGradient(colors: [Color.green.opacity(0.85), Color.green.opacity(0.65)], startPoint: .leading, endPoint: .trailing)))
                }
                Button(action: {
                    HapticManager.shared.trigger(.light)
                    withAnimation(.easeInOut(duration: 0.2)) { accessibility.disableAll() }
                }) {
                    HStack(spacing: 5) {
                        Image(systemName: "xmark.circle.fill").font(.system(size: 13))
                        Text("Desativar Tudo").font(.system(size: 13, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, 11)
                    .background(RoundedRectangle(cornerRadius: 10).fill(LinearGradient(colors: [Color.pink.opacity(0.75), Color.red.opacity(0.55)], startPoint: .leading, endPoint: .trailing)))
                }
            }
            .padding(.horizontal, 16).padding(.top, 12).padding(.bottom, 16)
        }
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.55))
                .shadow(color: Color.cyan.opacity(0.08), radius: 12, x: 0, y: 4)
        )
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.cyan.opacity(0.18), lineWidth: 1))
    }

    private var toggleDivider: some View {
        Rectangle().fill(Color.gray.opacity(0.08)).frame(height: 1).padding(.leading, 58).padding(.trailing, 16)
    }

    // MARK: - Sobre

    var aboutCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 16, weight: .semibold)).foregroundColor(.purple)
                    .frame(width: 32, height: 32).background(Color.purple.opacity(0.12)).clipShape(RoundedRectangle(cornerRadius: 8))
                Text("Sobre")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.32))
                Spacer()
            }
            .padding(.horizontal, 16).padding(.top, 16).padding(.bottom, 12)

            Rectangle().fill(Color.gray.opacity(0.1)).frame(height: 1).padding(.horizontal, 16)

            aboutRow(label: "Versão",          value: "1.0.0")
            Rectangle().fill(Color.gray.opacity(0.06)).frame(height: 1).padding(.leading, 58).padding(.trailing, 16)
            aboutRow(label: "Desenvolvido por", value: "ClimaAgora")
            Rectangle().fill(Color.gray.opacity(0.06)).frame(height: 1).padding(.leading, 58).padding(.trailing, 16)
            aboutRow(label: "Dados climáticos", value: "OpenWeather")
        }
        .padding(.bottom, 12).background(cardBackground)
    }

    private func aboutRow(label: String, value: String) -> some View {
        HStack {
            Text(label).font(.system(size: 14)).foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.55))
            Spacer()
            Text(value).font(.system(size: 14, weight: .medium)).foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.32))
        }
        .padding(.horizontal, 16).padding(.vertical, 10)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 18)
            .fill(Color.white.opacity(0.55))
            .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
    }
}
