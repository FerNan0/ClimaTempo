import SwiftUI

// MARK: - ClimaSectionHeader
//
// Cabeçalho de seção em caixa-alta com ícone (ex.: "PREVISÃO DE 5 DIAS").

public struct ClimaSectionHeader: View {

    private let title: String
    private let systemImage: String?

    public init(_ title: String, systemImage: String? = nil) {
        self.title = title
        self.systemImage = systemImage
    }

    public var body: some View {
        Label {
            Text(title.uppercased())
                .font(.system(size: 12, weight: .semibold))
        } icon: {
            if let systemImage {
                Image(systemName: systemImage)
            }
        }
        .foregroundColor(ClimaColor.textTertiary)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: ClimaSpacing.md) {
        ClimaSectionHeader("Previsão de 5 dias", systemImage: "calendar")
        ClimaSectionHeader("Sugestões IA", systemImage: "sparkles")
        ClimaSectionHeader("Sem ícone")
    }
    .padding()
    .background(ClimaGradient.surface)
}
