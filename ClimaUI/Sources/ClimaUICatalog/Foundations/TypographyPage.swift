import SwiftUI
import ClimaUI

struct TypographyPage: View {
    private let styles: [(String, Font)] = [
        ("hero", ClimaFont.hero),
        ("title", ClimaFont.title),
        ("headline", ClimaFont.headline),
        ("body", ClimaFont.body),
        ("callout", ClimaFont.callout),
        ("caption", ClimaFont.caption),
        ("label", ClimaFont.label),
    ]

    var body: some View {
        CatalogPage("Tipografia") {
            ForEach(styles, id: \.0) { name, font in
                Specimen(name) {
                    Text("Clima agora em São Paulo")
                        .font(font)
                        .foregroundColor(ClimaColor.textPrimary)
                }
            }
        }
    }
}

#Preview { NavigationStack { TypographyPage() } }
