import SwiftUI
import ClimaUI

struct TogglePage: View {
    @State private var simplified = true
    @State private var largeIcons = false
    @State private var semaphore = true

    var body: some View {
        CatalogPage("ToggleRow") {
            Specimen("Linhas de configuração") {
                ClimaCard(padding: ClimaSpacing.sm) {
                    VStack(spacing: 0) {
                        ClimaToggleRow(icon: "textformat.abc", iconColor: .green,
                                       title: "Linguagem Simplificada",
                                       subtitle: "Textos mais curtos e fáceis de entender",
                                       isOn: $simplified)
                        ClimaToggleRow(icon: "plus.magnifyingglass", iconColor: .orange,
                                       title: "Ícones Grandes",
                                       subtitle: "Aumenta ícones e áreas de toque",
                                       isOn: $largeIcons)
                        ClimaToggleRow(icon: "circle.lefthalf.filled", iconColor: .yellow,
                                       title: "Semáforo de Clima",
                                       subtitle: "Mostra 🟢🟡🔴 se é seguro sair",
                                       isOn: $semaphore)
                    }
                }
            }
        }
    }
}

#Preview { NavigationStack { TogglePage() } }
