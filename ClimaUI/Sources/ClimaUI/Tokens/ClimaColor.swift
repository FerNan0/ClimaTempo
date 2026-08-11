import SwiftUI
import UIKit

// MARK: - ClimaColor (tokens de cor)
//
// Paleta (valores crus) → Semântica (uso). A UI deve usar SEMPRE a semântica,
// nunca a paleta direto. Trocar a marca = mudar só a paleta aqui.

public enum ClimaColor {

    // MARK: Paleta

    public static let sky      = Color(red: 0.35, green: 0.55, blue: 0.95)
    public static let lavender = Color(red: 0.65, green: 0.50, blue: 0.90)
    public static let blush    = Color(red: 0.80, green: 0.55, blue: 0.85)
    public static let mist     = Color(red: 0.90, green: 0.92, blue: 1.0)

    // MARK: Semântica

    /// Cor de marca / ação primária.
    public static let accent = sky

    /// Texto principal — adapta a claro/escuro.
    public static let textPrimary = Color(
        light: Color(red: 0.15, green: 0.15, blue: 0.25),
        dark:  .white
    )

    /// Texto secundário (legendas, subtítulos).
    public static let textSecondary = Color(
        light: Color(red: 0.40, green: 0.40, blue: 0.50),
        dark:  .white.opacity(0.7)
    )

    /// Texto terciário (rótulos discretos).
    public static let textTertiary = Color(
        light: Color(red: 0.55, green: 0.55, blue: 0.65),
        dark:  .white.opacity(0.5)
    )

    /// Fundo de superfície (cards).
    public static let surface = Color(
        light: .white.opacity(0.55),
        dark:  .white.opacity(0.12)
    )

    // MARK: Status (semáforo de clima 🟢🟡🔴)

    public static let safe    = Color(red: 0.30, green: 0.72, blue: 0.40)
    public static let caution = Color(red: 0.95, green: 0.72, blue: 0.20)
    public static let danger  = Color(red: 0.90, green: 0.35, blue: 0.35)
}

// MARK: - Cor adaptativa (claro/escuro) só com SwiftUI/UIKit

public extension Color {
    /// Cria uma cor que muda conforme o modo claro/escuro do sistema.
    init(light: Color, dark: Color) {
        self = Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}
