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
        HStack(spacing: ClimaSpacing.sm + 2) {
            Image(systemName: icon)
                .foregroundColor(ClimaColor.accent)
                .font(.system(size: 17, weight: .bold))

            TextField(placeholder, text: $text)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(ClimaColor.textPrimary)
                .autocorrectionDisabled()

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 17))
                        .foregroundColor(ClimaColor.textTertiary)
                }
            }
        }
        .padding(.horizontal, ClimaSpacing.md)
        .padding(.vertical, ClimaSpacing.md - 2)
        .climaGlass(cornerRadius: ClimaRadius.lg)
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
