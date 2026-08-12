import SwiftUI
import ClimaUI

struct SectionHeaderPage: View {
    var body: some View {
        CatalogPage("SectionHeader") {
            Specimen("Com ícone") {
                VStack(alignment: .leading, spacing: ClimaSpacing.md) {
                    ClimaSectionHeader("Previsão de 5 dias", systemImage: "calendar")
                    ClimaSectionHeader("Sugestões IA", systemImage: "sparkles")
                }
            }
            Specimen("Sem ícone") {
                ClimaSectionHeader("Informações")
            }
        }
    }
}

#Preview { NavigationStack { SectionHeaderPage() } }
