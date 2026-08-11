import SwiftUI
import ClimaUI

struct SpacingPage: View {
    private let steps: [(String, CGFloat)] = [
        ("xs", ClimaSpacing.xs),
        ("sm", ClimaSpacing.sm),
        ("md", ClimaSpacing.md),
        ("lg", ClimaSpacing.lg),
        ("xl", ClimaSpacing.xl),
    ]

    var body: some View {
        CatalogPage("Espaçamento") {
            ForEach(steps, id: \.0) { name, value in
                HStack(spacing: ClimaSpacing.md) {
                    Text(name)
                        .font(ClimaFont.body)
                        .foregroundColor(ClimaColor.textPrimary)
                        .frame(width: 32, alignment: .leading)
                    Rectangle()
                        .fill(ClimaColor.accent)
                        .frame(width: value, height: 16)
                    Text("\(Int(value)) pt")
                        .font(ClimaFont.caption)
                        .foregroundColor(ClimaColor.textTertiary)
                    Spacer()
                }
            }
        }
    }
}

#Preview { NavigationStack { SpacingPage() } }
