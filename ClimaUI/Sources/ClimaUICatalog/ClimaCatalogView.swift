import SwiftUI
import ClimaUI

// MARK: - ClimaCatalogView (raiz do Component Playground)
//
// Lista navegável estilo "Storybook para iOS": Fundamentos (tokens) +
// Componentes, cada item abrindo sua própria página.
//
// Uso no app:  ClimaCatalogView()   (ex.: numa tela de debug/dev)

public struct ClimaCatalogView: View {

    public init() {}

    public var body: some View {
        NavigationStack {
            List {
                Section("Fundamentos") {
                    NavigationLink("Cores")      { ColorsPage() }
                    NavigationLink("Tipografia") { TypographyPage() }
                    NavigationLink("Espaçamento") { SpacingPage() }
                }

                Section("Componentes") {
                    NavigationLink("Button")        { ButtonPage() }
                    NavigationLink("Card")          { CardPage() }
                    NavigationLink("Tag / Status")  { TagPage() }
                    NavigationLink("TextField")     { TextFieldPage() }
                    NavigationLink("ToggleRow")     { TogglePage() }
                    NavigationLink("StatTile")      { StatTilePage() }
                    NavigationLink("ListRow")       { ListRowPage() }
                    NavigationLink("SectionHeader") { SectionHeaderPage() }
                }
            }
            .navigationTitle("ClimaUI")
        }
    }
}

#Preview {
    ClimaCatalogView()
}
