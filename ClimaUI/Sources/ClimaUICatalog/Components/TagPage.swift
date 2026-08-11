import SwiftUI
import ClimaUI

struct TagPage: View {
    var body: some View {
        CatalogPage("Tag / Status") {
            Specimen("Semáforo de clima") {
                VStack(alignment: .leading, spacing: ClimaSpacing.sm) {
                    ClimaTag("Bom para sair", icon: "checkmark.circle.fill", status: .safe)
                    ClimaTag("Atenção ao sair", icon: "exclamationmark.triangle.fill", status: .caution)
                    ClimaTag("Melhor ficar em casa", icon: "house.fill", status: .danger)
                }
            }
            Specimen("Neutro") {
                ClimaTag("Rótulo", status: .neutral)
            }
        }
    }
}

#Preview { NavigationStack { TagPage() } }
