import SwiftUI

// MARK: - ClimaGradient (gradientes de marca)
//
// Assinatura visual do app (headers e fundos pastel).
// v2: gradiente de marca mais profundo (4 stops, 135°) e fundo de página
// azul → lavanda, conforme o design handoff.

public enum ClimaGradient {

    /// Gradiente de marca (headers) — índigo → azul → lavanda → blush, 135°.
    public static let brand = LinearGradient(
        stops: [
            .init(color: ClimaColor.indigo,   location: 0.00),
            .init(color: ClimaColor.sky,      location: 0.30),
            .init(color: ClimaColor.lavender, location: 0.65),
            .init(color: ClimaColor.blush,    location: 1.00)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Fundo pastel claro de telas (azul → lavanda → lilás).
    public static let surface = LinearGradient(
        colors: [
            Color(hex: 0xD6E8FF),
            Color(hex: 0xE6E0FF),
            Color(hex: 0xF2EBFF)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}
