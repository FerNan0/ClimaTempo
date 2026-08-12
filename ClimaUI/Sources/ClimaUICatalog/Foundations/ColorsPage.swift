import SwiftUI
import ClimaUI

struct ColorsPage: View {
    private let palette: [(String, Color)] = [
        ("sky", ClimaColor.sky),
        ("lavender", ClimaColor.lavender),
        ("blush", ClimaColor.blush),
        ("mist", ClimaColor.mist),
    ]
    private let semantic: [(String, Color)] = [
        ("accent", ClimaColor.accent),
        ("textPrimary", ClimaColor.textPrimary),
        ("textSecondary", ClimaColor.textSecondary),
        ("textTertiary", ClimaColor.textTertiary),
    ]
    private let status: [(String, Color)] = [
        ("safe", ClimaColor.safe),
        ("caution", ClimaColor.caution),
        ("danger", ClimaColor.danger),
    ]

    var body: some View {
        CatalogPage("Cores") {
            Specimen("Paleta")  { swatches(palette) }
            Specimen("Semântica") { swatches(semantic) }
            Specimen("Status (semáforo)") { swatches(status) }
        }
    }

    private func swatches(_ items: [(String, Color)]) -> some View {
        VStack(spacing: ClimaSpacing.sm) {
            ForEach(items, id: \.0) { name, color in
                HStack(spacing: ClimaSpacing.md) {
                    RoundedRectangle(cornerRadius: ClimaRadius.sm)
                        .fill(color)
                        .frame(width: 44, height: 44)
                        .overlay(RoundedRectangle(cornerRadius: ClimaRadius.sm).stroke(.white.opacity(0.4)))
                    Text(name).font(ClimaFont.body).foregroundColor(ClimaColor.textPrimary)
                    Spacer()
                }
            }
        }
    }
}

#Preview { NavigationStack { ColorsPage() } }
