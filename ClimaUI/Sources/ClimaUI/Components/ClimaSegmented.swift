import SwiftUI

// MARK: - ClimaSegmented (controle segmentado em pills)
//
// Linha de opções selecionáveis, estilo pill. Usado para o seletor de período
// (3d/7d/10d), unidade de temperatura (C/F/K) e abas leves. Genérico sobre
// qualquer opção Hashable + Identifiable-por-label.

public struct ClimaSegmented<Option: Hashable>: View {

    private let options: [Option]
    private let label: (Option) -> String
    @Binding private var selection: Option

    public init(
        _ options: [Option],
        selection: Binding<Option>,
        label: @escaping (Option) -> String
    ) {
        self.options = options
        self._selection = selection
        self.label = label
    }

    public var body: some View {
        HStack(spacing: ClimaSpacing.xs + 2) {
            ForEach(options, id: \.self) { option in
                let isActive = option == selection
                Button {
                    withAnimation(.easeInOut(duration: 0.18)) { selection = option }
                } label: {
                    Text(label(option))
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(isActive ? Color.white : ClimaColor.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, ClimaSpacing.sm)
                        .background(
                            Capsule().fill(isActive ? AnyShapeStyle(ClimaColor.accent) : AnyShapeStyle(Color.clear))
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(ClimaSpacing.xs)
        .background(Capsule().fill(.ultraThinMaterial))
        .overlay(Capsule().stroke(ClimaColor.glassBorder, lineWidth: 1))
    }
}

// MARK: - ClimaStatTileMini (tile compacto de resumo)

/// Tile compacto para resumos (Máx. média, Mín. média, Dias de chuva; ou
/// métricas do Cognitive Sheet). Diferente de `ClimaStatTile`, empilha
/// valor grande + label pequena, sem ícone obrigatório.
public struct ClimaSummaryTile: View {
    private let value: String
    private let label: String
    private let tint: Color

    public init(value: String, label: String, tint: Color = ClimaColor.textPrimary) {
        self.value = value
        self.label = label
        self.tint = tint
    }

    public var body: some View {
        VStack(spacing: ClimaSpacing.xs) {
            Text(value)
                .font(.system(size: 20, weight: .heavy, design: .rounded))
                .foregroundStyle(tint)
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(ClimaColor.textTertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, ClimaSpacing.sm + 2)
        .climaGlass(cornerRadius: ClimaRadius.md)
    }
}
