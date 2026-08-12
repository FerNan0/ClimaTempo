import SwiftUI

// MARK: - ClimaFont (tokens de tipografia)
//
// Escala fixa de estilos. O app usa `design: .rounded` como assinatura visual.

public enum ClimaFont {
    public static let display  = Font.system(size: 96, weight: .thin,     design: .rounded)
    public static let hero     = Font.system(size: 34, weight: .regular,  design: .rounded)
    public static let title    = Font.system(size: 28, weight: .bold,     design: .rounded)
    public static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)
    public static let body     = Font.system(size: 15, weight: .regular)
    public static let callout  = Font.system(size: 14, weight: .regular)
    public static let caption  = Font.system(size: 12, weight: .medium)
    public static let label    = Font.system(size: 11, weight: .semibold)
}
