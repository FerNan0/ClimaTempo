import SwiftUI
import ClimaUI

struct SearchView: View {
    @StateObject var viewModel: SearchViewModel
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""

    let popularCities = ["São Paulo", "Rio de Janeiro", "Brasília", "Salvador", "Curitiba",
                         "Manaus", "Fortaleza", "Belo Horizonte", "Porto Alegre", "Recife"]

    var body: some View {
        NavigationStack {
            ZStack {
                ClimaGradient.surface.ignoresSafeArea()

                VStack(spacing: 0) {
                    headerView
                    searchBarView
                    resultsView
                }
            }
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            Text("Procurar Cidade")
                .font(ClimaFont.title)
                .foregroundColor(.white)
            Spacer()
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(Color.white.opacity(0.22)))
            }
        }
        .padding(ClimaSpacing.md)
        .background(ClimaGradient.brand)
    }

    // MARK: - Search Bar

    private var searchBarView: some View {
        ClimaTextField("Digite a cidade... (mín. 3 caracteres)", text: $searchText)
            .padding(.horizontal, ClimaSpacing.md)
            .padding(.top, ClimaSpacing.md)
            .onChange(of: searchText) { _, newValue in
                viewModel.search(newValue)
            }
    }

    // MARK: - Results

    private var resultsView: some View {
        ScrollView {
            VStack(spacing: ClimaSpacing.sm + 4) {
                if searchText.count >= 3 && viewModel.searchResults.isEmpty && viewModel.state != .loading {
                    emptyState
                } else if !viewModel.searchResults.isEmpty {
                    resultsList(title: "Resultados da Busca", cities: viewModel.searchResults)
                } else {
                    resultsList(title: "Cidades Populares", cities: popularCities)
                }
                Spacer().frame(height: ClimaSpacing.md)
            }
            .padding(.top, ClimaSpacing.sm)
        }
    }

    private func resultsList(title: String, cities: [String]) -> some View {
        VStack(alignment: .leading, spacing: ClimaSpacing.sm + 2) {
            ClimaSectionHeader(title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, ClimaSpacing.md)

            ForEach(cities, id: \.self) { city in
                ClimaListRow(city, icon: "location.fill") {
                    HapticManager.shared.trigger(.light)
                    viewModel.selectCity(city)
                    dismiss()
                }
            }
            .padding(.horizontal, ClimaSpacing.md)
        }
    }

    private var emptyState: some View {
        VStack(spacing: ClimaSpacing.sm + 4) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40, weight: .thin))
                .foregroundColor(ClimaColor.textTertiary.opacity(0.6))
            Text("Nenhuma cidade encontrada")
                .font(ClimaFont.headline)
                .foregroundColor(ClimaColor.textSecondary)
            Text("Tente outro nome")
                .font(ClimaFont.callout)
                .foregroundColor(ClimaColor.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(ClimaSpacing.xl)
    }
}
