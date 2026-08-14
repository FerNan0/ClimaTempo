import SwiftUI
import ClimaUI

// MARK: - SearchView — redesign v2 (handoff "buscar cidade")
//
// Sem header gradiente: campo de busca + "Cancelar" no topo, e abaixo três
// blocos de descoberta — Recentes (chips), Favoritas (linha de vidro com o
// clima atual) e "Quero visitar" (chips tracejados). Ao digitar 3+ letras,
// o conteúdo dá lugar aos resultados da busca.

struct SearchView: View {
    @StateObject var viewModel: SearchViewModel
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""

    private var isSearching: Bool { searchText.trimmingCharacters(in: .whitespaces).count >= 3 }

    var body: some View {
        ZStack {
            ClimaGradient.surface.ignoresSafeArea()

            VStack(spacing: 0) {
                searchBar
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: ClimaSpacing.lg) {
                        if isSearching {
                            resultsSection
                        } else {
                            if !viewModel.recents.isEmpty { recentsSection }
                            if !viewModel.favorites.isEmpty { favoritesSection }
                            wishlistSection
                        }
                    }
                    .padding(.horizontal, ClimaSpacing.md)
                    .padding(.top, ClimaSpacing.sm)
                    .padding(.bottom, ClimaSpacing.xl)
                }
            }
        }
        .onAppear { viewModel.onAppear() }
    }

    // MARK: - Barra de busca (campo + Cancelar)

    private var searchBar: some View {
        HStack(spacing: ClimaSpacing.sm + 2) {
            ClimaTextField("Buscar cidade", text: $searchText)
                .onChange(of: searchText) { _, newValue in viewModel.search(newValue) }
            Button("Cancelar") {
                HapticManager.shared.trigger(.light)
                dismiss()
            }
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundStyle(ClimaColor.accent)
        }
        .padding(.horizontal, ClimaSpacing.md)
        .padding(.top, ClimaSpacing.sm)
        .padding(.bottom, ClimaSpacing.sm)
    }

    // MARK: - Recentes (chips)

    private var recentsSection: some View {
        VStack(alignment: .leading, spacing: ClimaSpacing.sm + 2) {
            sectionLabel("RECENTES")
            ClimaFlowLayout(spacing: ClimaSpacing.sm, lineSpacing: ClimaSpacing.sm) {
                ForEach(viewModel.recents, id: \.self) { city in
                    ClimaPill(city) { select(city) }
                }
            }
        }
    }

    // MARK: - Favoritas (linha de vidro com o clima atual)

    private var favoritesSection: some View {
        VStack(alignment: .leading, spacing: ClimaSpacing.sm + 2) {
            sectionLabel("FAVORITAS", emoji: "❤️")
            VStack(spacing: ClimaSpacing.sm) {
                ForEach(viewModel.favorites) { favoriteRow($0) }
            }
        }
    }

    private func favoriteRow(_ fav: SearchViewModel.FavoriteWeather) -> some View {
        Button { select(fav.city) } label: {
            HStack(spacing: ClimaSpacing.sm + 2) {
                Text(weatherEmoji(for: fav.condition ?? "")).font(.system(size: 22))
                Text(fav.city)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(ClimaColor.textPrimary)
                Spacer()
                if let temp = fav.temperature {
                    Text("\(temp)°")
                        .font(.system(size: 17, weight: .heavy, design: .rounded))
                        .foregroundStyle(ClimaColor.textPrimary)
                } else {
                    ProgressView().scaleEffect(0.7)
                }
            }
            .padding(.horizontal, ClimaSpacing.md)
            .padding(.vertical, ClimaSpacing.md - 2)
            .climaGlass(cornerRadius: ClimaRadius.lg)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Quero visitar (chips tracejados)

    private var wishlistSection: some View {
        VStack(alignment: .leading, spacing: ClimaSpacing.sm + 2) {
            sectionLabel("QUERO VISITAR", emoji: "🧭")
            ClimaFlowLayout(spacing: ClimaSpacing.sm, lineSpacing: ClimaSpacing.sm) {
                ForEach(viewModel.wishlist, id: \.self) { city in
                    Button { select(city) } label: { ClimaDashedPill(city) }
                        .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Resultados da busca

    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: ClimaSpacing.sm + 2) {
            if viewModel.searchResults.isEmpty && viewModel.state != .loading {
                emptyState
            } else {
                sectionLabel("RESULTADOS")
                ForEach(viewModel.searchResults, id: \.self) { city in
                    ClimaListRow(city, icon: "location.fill") { select(city) }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: ClimaSpacing.sm + 4) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40, weight: .thin))
                .foregroundColor(ClimaColor.textTertiary.opacity(0.6))
            Text("Nenhuma cidade encontrada")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(ClimaColor.textSecondary)
            Text("Tente outro nome")
                .font(.system(size: 13))
                .foregroundColor(ClimaColor.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, ClimaSpacing.xl)
    }

    // MARK: - Helpers

    private func select(_ city: String) {
        HapticManager.shared.trigger(.light)
        viewModel.selectCity(city)
        dismiss()
    }

    private func sectionLabel(_ text: String, emoji: String? = nil) -> some View {
        HStack(spacing: 6) {
            if let emoji { Text(emoji).font(.system(size: 13)) }
            Text(text)
                .font(.system(size: 13, weight: .heavy, design: .rounded))
                .foregroundStyle(ClimaColor.textTertiary)
                .tracking(0.5)
        }
    }
}
