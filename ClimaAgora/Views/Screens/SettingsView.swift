import SwiftUI
import ClimaUI

// SettingsView não precisa de ViewModel — gerencia preferências locais
// diretamente via UserDefaults e CognitiveAccessibilityManager.
// Redesign v2: usa o Design System ClimaUI (tokens + vidro + componentes).

struct SettingsView: View {
    @ObservedObject var accessibility = CognitiveAccessibilityManager.shared
    @ObservedObject private var engine = AdaptiveEngine.shared
    @Environment(\.dismiss) var dismiss
    @State private var temperatureUnit    = UserDefaults.standard.string(forKey: "temperatureUnit") ?? "Celsius"
    @State private var notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")

    private let units = ["Celsius", "Fahrenheit", "Kelvin"]

    var body: some View {
        NavigationStack {
            ZStack {
                ClimaGradient.surface.ignoresSafeArea()
                VStack(spacing: 0) {
                    header
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: ClimaSpacing.md) {
                            unitCard
                            notificationsCard
                            adaptiveCard
                            accessibilityCard
                            aboutCard
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, ClimaSpacing.lg)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }

    // MARK: - Header (gradiente de marca)

    private var header: some View {
        HStack(spacing: ClimaSpacing.md) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(.white.opacity(0.22)))
            }
            Text("Configurações")
                .font(.system(size: 26, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
            Spacer()
        }
        .padding(.horizontal, ClimaSpacing.lg).padding(.top, 12).padding(.bottom, 18)
        .background(ClimaGradient.brand)
    }

    // MARK: - Cabeçalho de card (ícone tintado + título + subtítulo)

    private func cardHeader(icon: String, tint: Color, title: String, subtitle: String? = nil) -> some View {
        HStack(spacing: ClimaSpacing.sm + 2) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold)).foregroundStyle(tint)
                .frame(width: 32, height: 32)
                .background(RoundedRectangle(cornerRadius: ClimaRadius.sm).fill(tint.opacity(0.14)))
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 16, weight: .bold, design: .rounded)).foregroundStyle(ClimaColor.textPrimary)
                if let subtitle {
                    Text(subtitle).font(.system(size: 11, weight: .medium)).foregroundStyle(ClimaColor.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Spacer()
        }
    }

    private var divider: some View {
        Rectangle().fill(ClimaColor.textTertiary.opacity(0.15)).frame(height: 1)
    }

    // MARK: - Temperatura

    private var unitCard: some View {
        ClimaGlassCard {
            VStack(alignment: .leading, spacing: ClimaSpacing.md) {
                cardHeader(icon: "thermometer.medium", tint: .orange, title: "Temperatura")
                ClimaSegmented(units, selection: $temperatureUnit) { $0 }
                    .onChange(of: temperatureUnit) { _, v in UserDefaults.standard.setValue(v, forKey: "temperatureUnit") }
            }
        }
    }

    // MARK: - Notificações

    private var notificationsCard: some View {
        ClimaGlassCard {
            HStack(spacing: ClimaSpacing.sm + 2) {
                cardHeader(icon: notificationsEnabled ? "bell.badge.fill" : "bell.fill",
                           tint: ClimaColor.safe,
                           title: "Notificações",
                           subtitle: notificationsEnabled ? "Ativadas" : "Desativadas")
                Toggle("", isOn: $notificationsEnabled)
                    .labelsHidden().tint(ClimaColor.safe)
                    .onChange(of: notificationsEnabled) { _, v in
                        UserDefaults.standard.setValue(v, forKey: "notificationsEnabled")
                        if v { NotificationManager.shared.requestAuthorization() }
                    }
            }
        }
    }

    // MARK: - Adaptação Automática (motor comportamental — diferencial do app)

    private var adaptiveCard: some View {
        ClimaGlassCard {
            VStack(alignment: .leading, spacing: ClimaSpacing.md) {
                cardHeader(icon: "wand.and.sparkles", tint: ClimaColor.indigo,
                           title: "Adaptação Automática",
                           subtitle: "O app percebe quando a tela está difícil e ajuda sozinho")
                divider
                VStack(spacing: ClimaSpacing.sm) {
                    ClimaToggleRow(icon: "brain.filled.head.profile", iconColor: ClimaColor.indigo,
                                   title: "Ativar adaptação automática",
                                   subtitle: "Sugere simplificar quando percebe dificuldade",
                                   isOn: $accessibility.automaticAdaptationEnabled)
                    if accessibility.automaticAdaptationEnabled {
                        ClimaToggleRow(icon: "bolt.badge.automatic", iconColor: .orange,
                                       title: "Simplificar sem perguntar",
                                       subtitle: "Em caso de muita dificuldade, adapta sozinho (sempre reversível)",
                                       isOn: $accessibility.allowAutoApply)
                    }
                }
                divider
                // Métricas locais de validação — evidência empírica para o TCC.
                VStack(spacing: ClimaSpacing.sm) {
                    HStack {
                        Text("Carga cognitiva agora").font(.system(size: 13, weight: .medium)).foregroundStyle(ClimaColor.textSecondary)
                        Spacer()
                        Text(String(format: "%.0f", engine.currentLoad))
                            .font(.system(size: 14, weight: .heavy, design: .monospaced))
                            .foregroundStyle(ClimaColor.cognitiveLoad(min(10, Int(engine.currentLoad.rounded()))))
                    }
                    let m = engine.telemetry.metrics
                    metricRow("Sinais de atrito", m.repeatedTaps + m.retries + m.errors + m.hesitations + m.backNavigations)
                    metricRow("Sugestões mostradas", m.suggestionsShown)
                    metricRow("Sugestões aceitas", m.suggestionsAccepted)
                    metricRow("Adaptações automáticas", m.autoAdaptations)
                }
                ClimaButton("Zerar métricas da sessão", variant: .secondary, size: .small) {
                    HapticManager.shared.trigger(.light)
                    engine.telemetry.resetMetrics()
                }
            }
        }
    }

    private func metricRow(_ label: String, _ value: Int) -> some View {
        HStack {
            Text(label).font(.system(size: 13)).foregroundStyle(ClimaColor.textSecondary)
            Spacer()
            Text("\(value)").font(.system(size: 13, weight: .semibold, design: .monospaced)).foregroundStyle(ClimaColor.textPrimary)
        }
    }

    // MARK: - Acessibilidade Cognitiva

    private var accessibilityCard: some View {
        ClimaGlassCard {
            VStack(alignment: .leading, spacing: ClimaSpacing.md) {
                cardHeader(icon: "brain.head.profile", tint: ClimaColor.cyan,
                           title: "Acessibilidade Cognitiva",
                           subtitle: "Facilita a compreensão das informações")
                divider
                VStack(spacing: ClimaSpacing.sm) {
                    ClimaToggleRow(icon: "textformat.abc", iconColor: ClimaColor.safe, title: "Linguagem Simplificada", subtitle: "Textos mais curtos e fáceis de entender", isOn: $accessibility.isSimplifiedMode)
                    ClimaToggleRow(icon: "plus.magnifyingglass", iconColor: .orange, title: "Ícones Grandes", subtitle: "Aumenta ícones e áreas de toque", isOn: $accessibility.useLargeIcons)
                    ClimaToggleRow(icon: "circle.lefthalf.filled", iconColor: ClimaColor.caution, title: "Semáforo de Clima", subtitle: "Mostra 🟢🟡🔴 se é seguro sair", isOn: $accessibility.showVisualSummary)
                    ClimaToggleRow(icon: "eye.slash", iconColor: ClimaColor.sky, title: "Reduzir Informações", subtitle: "Mostra só o essencial", isOn: $accessibility.reduceInformation)
                    ClimaToggleRow(icon: "iphone.radiowaves.left.and.right", iconColor: ClimaColor.blush, title: "Vibração Reforçada", subtitle: "Vibra mais forte ao tocar nos botões", isOn: $accessibility.enhancedHaptics)
                }
                divider
                HStack(spacing: ClimaSpacing.sm) {
                    ClimaButton("Ativar Tudo", icon: "checkmark.circle.fill", size: .small) {
                        HapticManager.shared.trigger(.medium)
                        withAnimation(.easeInOut(duration: 0.2)) { accessibility.enableAll() }
                    }
                    ClimaButton("Desativar Tudo", icon: "xmark.circle.fill", variant: .secondary, size: .small) {
                        HapticManager.shared.trigger(.light)
                        withAnimation(.easeInOut(duration: 0.2)) { accessibility.disableAll() }
                    }
                }
            }
        }
    }

    // MARK: - Sobre

    private var aboutCard: some View {
        ClimaGlassCard {
            VStack(alignment: .leading, spacing: ClimaSpacing.sm) {
                cardHeader(icon: "info.circle.fill", tint: ClimaColor.lavender, title: "Sobre")
                divider
                aboutRow("Versão", "1.0.0")
                aboutRow("Desenvolvido por", "ClimaAgora")
                aboutRow("Dados climáticos", "OpenWeather")
            }
        }
    }

    private func aboutRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).font(.system(size: 14)).foregroundStyle(ClimaColor.textSecondary)
            Spacer()
            Text(value).font(.system(size: 14, weight: .medium)).foregroundStyle(ClimaColor.textPrimary)
        }
        .padding(.vertical, 2)
    }
}
