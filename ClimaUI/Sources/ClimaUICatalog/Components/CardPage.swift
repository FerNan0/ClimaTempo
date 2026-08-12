import SwiftUI
import ClimaUI

struct CardPage: View {
    var body: some View {
        CatalogPage("Card") {
            Specimen("Simples") {
                ClimaCard {
                    Text("Conteúdo de um card")
                        .font(ClimaFont.headline)
                        .foregroundColor(ClimaColor.textPrimary)
                }
            }
            Specimen("Com título e corpo") {
                ClimaCard {
                    VStack(alignment: .leading, spacing: ClimaSpacing.sm) {
                        Text("Recomendações")
                            .font(ClimaFont.headline)
                            .foregroundColor(ClimaColor.textPrimary)
                        Text("Use roupas leves e leve protetor solar. Bom dia para caminhar.")
                            .font(ClimaFont.callout)
                            .foregroundColor(ClimaColor.textSecondary)
                    }
                }
            }
        }
    }
}

#Preview { NavigationStack { CardPage() } }
