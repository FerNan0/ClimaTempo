import SwiftUI

// MARK: - ClimaMarkdownText
//
// Renderizador leve de Markdown para textos gerados por IA (Apple Intelligence /
// nuvem), que voltam com `### títulos`, `**negrito**` e listas `- item`.
// O `Text` do SwiftUI só interpreta marcações *inline* (`**bold**`, `*itálico*`)
// e colapsa quebras de linha, então blocos (`###`, listas) apareciam CRUS na
// tela. Aqui quebramos por linha e estilizamos cada tipo de bloco no padrão
// visual do ClimaUI — sem depender de biblioteca externa.

public struct ClimaMarkdownText: View {

    private let markdown: String

    public init(_ markdown: String) {
        self.markdown = markdown
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: ClimaSpacing.sm) {
            ForEach(Array(blocks.enumerated()), id: \.offset) { _, block in
                view(for: block)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Modelo de blocos

    private enum Block {
        case heading(String)
        case bullet(String)
        case paragraph(String)
        case spacer
    }

    /// Classifica cada linha do texto em um bloco.
    private var blocks: [Block] {
        markdown
            .replacingOccurrences(of: "\r\n", with: "\n")
            .components(separatedBy: "\n")
            .map { raw -> Block in
                let line = raw.trimmingCharacters(in: .whitespaces)
                if line.isEmpty { return .spacer }
                if let h = strip(line, prefixes: ["###", "##", "#"]) { return .heading(h) }
                if let b = strip(line, prefixes: ["- ", "* ", "• "]) { return .bullet(b) }
                return .paragraph(line)
            }
    }

    /// Remove um dos prefixos (o primeiro que casar) e devolve o resto limpo.
    private func strip(_ line: String, prefixes: [String]) -> String? {
        for p in prefixes where line.hasPrefix(p) {
            return String(line.dropFirst(p.count)).trimmingCharacters(in: .whitespaces)
        }
        return nil
    }

    // MARK: - Render de cada bloco

    @ViewBuilder
    private func view(for block: Block) -> some View {
        switch block {
        case .heading(let text):
            styled(text)
                .font(.system(size: 15, weight: .heavy, design: .rounded))
                .foregroundStyle(ClimaColor.textPrimary)
                .padding(.top, ClimaSpacing.xs)

        case .bullet(let text):
            HStack(alignment: .top, spacing: ClimaSpacing.sm) {
                Circle()
                    .fill(ClimaColor.accent)
                    .frame(width: 6, height: 6)
                    .padding(.top, 7)
                styled(text)
                    .font(.system(size: 14))
                    .foregroundStyle(ClimaColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
            }

        case .paragraph(let text):
            styled(text)
                .font(.system(size: 14))
                .foregroundStyle(ClimaColor.textSecondary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)

        case .spacer:
            Color.clear.frame(height: 2)
        }
    }

    /// Interpreta marcações inline (`**negrito**`, `*itálico*`) via AttributedString,
    /// preservando o espaçamento. Se falhar, cai no texto puro.
    private func styled(_ line: String) -> Text {
        if let attributed = try? AttributedString(
            markdown: line,
            options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        ) {
            return Text(attributed)
        }
        return Text(line)
    }
}

#Preview {
    ScrollView {
        ClimaMarkdownText("""
        Com a temperatura de 16°C, mantenha-se confortável.

        ### O que vestir:
        - **Camisa de manga longa**: tecidos leves como algodão.
        - **Calça jeans**: confortável para o clima.
        - **Casaco leve**: útil para manter o corpo aquecido.
        """)
        .padding()
    }
    .background(ClimaGradient.surface)
}
