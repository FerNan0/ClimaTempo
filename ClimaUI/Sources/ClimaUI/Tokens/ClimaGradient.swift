import SwiftUI

// MARK: - ClimaGradient (gradientes de marca)
//
// Assinatura visual do app (headers e fundos pastel).

public enum ClimaGradient {

    /// Gradiente de marca (header) — azul → lavanda → blush.
    public static let brand = LinearGradient(
        colors: [ClimaColor.sky, ClimaColor.lavender, ClimaColor.blush],
        startPoint: .leading,
        endPoint: .trailing
    )

    /// Fundo pastel claro de telas.
    public static let surface = LinearGradient(
        colors: [
            Color(red: 0.82, green: 0.90, blue: 1.0),
            Color(red: 0.90, green: 0.88, blue: 1.0),
            Color(red: 0.95, green: 0.92, blue: 1.0)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}
