import SwiftUI
import ClimaUI

struct StatTilePage: View {
    var body: some View {
        CatalogPage("StatTile") {
            Specimen("Linha de métricas (como na Home)") {
                ClimaCard {
                    HStack(spacing: 0) {
                        ClimaStatTile(icon: "drop.fill", value: "65%", label: "Umidade", tint: .cyan)
                        Divider().frame(height: 36)
                        ClimaStatTile(icon: "wind", value: "12 km/h", label: "Vento", tint: .mint)
                        Divider().frame(height: 36)
                        ClimaStatTile(icon: "sun.max.fill", value: "7", label: "UV", tint: .orange)
                    }
                }
            }
            Specimen("Individual") {
                ClimaCard {
                    ClimaStatTile(icon: "thermometer.medium", value: "25°", label: "Temperatura", tint: .red)
                }
            }
        }
    }
}

#Preview { NavigationStack { StatTilePage() } }
