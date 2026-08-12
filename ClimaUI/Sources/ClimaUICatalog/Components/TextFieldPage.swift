import SwiftUI
import ClimaUI

struct TextFieldPage: View {
    @State private var city = ""
    @State private var name = "São Paulo"

    var body: some View {
        CatalogPage("TextField") {
            Specimen("Vazio") {
                ClimaTextField("Digite a cidade...", text: $city)
            }
            Specimen("Preenchido (com limpar)") {
                ClimaTextField("Cidade", text: $name)
            }
            Specimen("Ícone customizado") {
                ClimaTextField("Buscar", text: $city, icon: "location.magnifyingglass")
            }
        }
    }
}

#Preview { NavigationStack { TextFieldPage() } }
