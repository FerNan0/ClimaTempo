import SwiftUI

// MARK: - ClimaTextField
//
// Campo de texto com ícone e botão de limpar — estilo da busca de cidades.

public struct ClimaTextField: View {

    private let placeholder: String
    private let icon: String
    @Binding private var text: String

    public init(_ placeholder: String, text: Binding<String>, icon: String = "magnifyingglass") {
        self.placeholder = placeholder
        self._text = text
        self.icon = icon
    }

    public var body: some View {
        HStack(spacing: ClimaSpacing.sm) {
            Image(systemName: icon)
                .foregroundColor(ClimaColor.textTertiary)
                .font(.system(size: 16, weight: .semibold))

            TextField(placeholder, text: $text)
                .font(.system(size: 16, weight: .semibold))
                .autocorrectionDisabled()

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(ClimaColor.textTertiary)
                }
            }
        }
        .padding(ClimaSpacing.md - 4)
        .background(
            RoundedRectangle(cornerRadius: ClimaRadius.md)
                .fill(Color(.systemBackground).opacity(0.9))
        )
    }
}

#Preview {
    struct Demo: View {
        @State private var value = ""
        var body: some View {
            ClimaTextField("Digite a cidade...", text: $value)
                .padding()
                .background(ClimaGradient.surface)
        }
    }
    return Demo()
}
