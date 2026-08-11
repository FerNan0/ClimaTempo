import SwiftUI
import ClimaUI

struct ButtonPage: View {
    var body: some View {
        CatalogPage("Button") {
            Specimen("Variantes") {
                VStack(spacing: ClimaSpacing.sm) {
                    ClimaButton("Primary", icon: "sparkles") {}
                    ClimaButton("Secondary", variant: .secondary) {}
                    ClimaButton("Ghost", variant: .ghost) {}
                }
            }
            Specimen("Tamanhos") {
                VStack(spacing: ClimaSpacing.sm) {
                    ClimaButton("Small", size: .small) {}
                    ClimaButton("Medium", size: .medium) {}
                    ClimaButton("Large", size: .large) {}
                }
            }
            Specimen("Estados") {
                VStack(spacing: ClimaSpacing.sm) {
                    ClimaButton("Carregando", isLoading: true) {}
                    ClimaButton("Desabilitado") {}.disabled(true)
                }
            }
        }
    }
}

#Preview { NavigationStack { ButtonPage() } }
