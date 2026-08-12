import SwiftUI
import ClimaUI

struct ListRowPage: View {
    var body: some View {
        CatalogPage("ListRow") {
            Specimen("Resultados de busca") {
                VStack(spacing: ClimaSpacing.sm) {
                    ClimaListRow("São Paulo") {}
                    ClimaListRow("Rio de Janeiro") {}
                    ClimaListRow("Belo Horizonte") {}
                }
            }
            Specimen("Favoritos (ícone customizado)") {
                VStack(spacing: ClimaSpacing.sm) {
                    ClimaListRow("Curitiba", icon: "star.fill", iconColor: .orange) {}
                    ClimaListRow("Salvador", icon: "star.fill", iconColor: .orange) {}
                }
            }
            Specimen("Sem chevron") {
                ClimaListRow("Item informativo", showsChevron: false) {}
            }
        }
    }
}

#Preview { NavigationStack { ListRowPage() } }
