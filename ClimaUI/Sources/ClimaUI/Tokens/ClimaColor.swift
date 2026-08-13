import SwiftUI
import UIKit

// MARK: - ClimaColor (tokens de cor)
//
// Paleta (valores crus) → Semântica (uso). A UI deve usar SEMPRE a semântica,
// nunca a paleta direto. Trocar a marca = mudar só a paleta aqui.
//
// v2 (design handoff): paleta aprofundada/saturada para um visual mais ousado,
// mantendo a família sky/lavender/blush. Os nomes semânticos foram preservados
// para não quebrar quem já os consome.

public enum ClimaColor {

    // MARK: Paleta de marca (gradiente #3D5FE0 → #598CF2 → #A680E6 → #CC8CD9)

    /// Índigo profundo — início do gradiente de marca.
    public static let indigo   = Color(hex: 0x3D5FE0)
    /// Azul de marca (ação primária).
    public static let sky      = Color(hex: 0x598CF2)
    /// Lavanda.
    public static let lavender = Color(hex: 0xA680E6)
    /// Blush (fim do gradiente de marca).
    public static let blush    = Color(hex: 0xCC8CD9)
    /// Névoa clara.
    public static let mist     = Color(hex: 0xE6E0FF)
    /// Ciano de destaque (CTA de simplificar / sugestão do motor cognitivo).
    public static let cyan     = Color(hex: 0x2FB6D9)

    // MARK: Semântica — ação

    /// Cor de marca / ação primária.
    public static let accent = sky

    // MARK: Semântica — texto (adapta claro/escuro)

    /// Texto principal (#23233F no claro).
    public static let textPrimary = Color(
        light: Color(hex: 0x23233F),
        dark:  .white
    )
    /// Texto secundário (#63637F).
    public static let textSecondary = Color(
        light: Color(hex: 0x63637F),
        dark:  .white.opacity(0.72)
    )
    /// Texto terciário / rótulos discretos (#9494AA).
    public static let textTertiary = Color(
        light: Color(hex: 0x9494AA),
        dark:  .white.opacity(0.5)
    )

    // MARK: Semântica — superfícies de vidro (glassmorphism)

    /// Fundo de superfície (cards) — vidro translúcido.
    public static let surface = Color(
        light: .white.opacity(0.58),
        dark:  .white.opacity(0.12)
    )
    /// Fundo de vidro mais opaco (banners, sheets).
    public static let glassStrong = Color(
        light: .white.opacity(0.66),
        dark:  .white.opacity(0.16)
    )
    /// Borda de vidro (hairline clara sobre o card).
    public static let glassBorder = Color(
        light: .white.opacity(0.7),
        dark:  .white.opacity(0.18)
    )

    // MARK: Status (semáforo de clima 🟢🟡🔴)

    public static let safe    = Color(hex: 0x3FAE59)
    public static let caution = Color(hex: 0xE8A93A)
    public static let danger  = Color(hex: 0xE2555A)

    // MARK: - Carga cognitiva (cor dinâmica do motor de adaptação)

    /// Cor do sinal de carga cognitiva por faixa (0–10): baixa (verde),
    /// média (âmbar), alta (vermelho). Usada no pill 🧠 e nas barras.
    public static func cognitiveLoad(_ load: Int) -> Color {
        switch load {
        case ...3:  return safe
        case 4...6: return caution
        default:    return danger
        }
    }

    /// Fundo translúcido do pill do motor cognitivo, por faixa de carga.
    public static func cognitiveLoadFill(_ load: Int) -> Color {
        switch load {
        case ...3:  return safe.opacity(0.22)
        case 4...6: return caution.opacity(0.25)
        default:    return danger.opacity(0.28)
        }
    }
}

// MARK: - Cor a partir de hex

public extension Color {
    /// Cria uma cor a partir de um inteiro hexadecimal (ex.: `0x23233F`).
    init(hex: UInt32, alpha: Double = 1) {
        self.init(
            .sRGB,
            red:   Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue:  Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
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
