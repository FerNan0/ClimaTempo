import SwiftUI
import ClimaUI

// MARK: - Scaffold das páginas do catálogo
//
// Estrutura comum de uma "página por componente": fundo de marca + scroll
// com blocos rotulados (cada bloco mostra uma variação do componente).

struct CatalogPage<Content: View>: View {
    let title: String
    let content: Content

    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        ZStack {
            ClimaGradient.surface.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: ClimaSpacing.lg) {
                    content
                }
                .padding(ClimaSpacing.md)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Bloco rotulado (um "specimen")

struct Specimen<Content: View>: View {
    let label: String
    let content: Content

    init(_ label: String, @ViewBuilder content: () -> Content) {
        self.label = label
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: ClimaSpacing.sm) {
            Text(label)
                .font(ClimaFont.label)
                .foregroundColor(ClimaColor.textTertiary)
            content
        }
    }
}
