import SwiftUI

// MARK: - ClimaFlowLayout
//
// Layout de "fluxo": posiciona os filhos em linha e quebra para a próxima
// quando não cabem na largura disponível — o comportamento dos chips de
// "Recentes" e "Quero visitar" na busca. Usa o protocolo `Layout` (iOS 16+),
// sem dependência externa nem truques de GeometryReader.

public struct ClimaFlowLayout: Layout {

    private let spacing: CGFloat       // espaço horizontal entre chips
    private let lineSpacing: CGFloat   // espaço vertical entre linhas

    public init(spacing: CGFloat = ClimaSpacing.sm, lineSpacing: CGFloat = ClimaSpacing.sm) {
        self.spacing = spacing
        self.lineSpacing = lineSpacing
    }

    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var widthUsed: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {   // não cabe → nova linha
                x = 0
                y += rowHeight + lineSpacing
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
            widthUsed = max(widthUsed, x - spacing)
        }
        let totalWidth = maxWidth == .infinity ? widthUsed : maxWidth
        return CGSize(width: totalWidth, height: y + rowHeight)
    }

    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {   // quebra de linha
                x = bounds.minX
                y += rowHeight + lineSpacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), anchor: .topLeading, proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
