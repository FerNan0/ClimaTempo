import SwiftUI

struct SearchView: View {
    @ObservedObject var viewModel: WeatherViewModel
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    @State private var searchResults: [String] = []
    @State private var hasSearched = false
    
    let popularCities = ["São Paulo", "Rio de Janeiro", "Brasília", "Salvador", "Curitiba", "Manaus", "Fortaleza", "Belo Horizonte", "Porto Alegre", "Recife"]
    
    /// Remove duplicatas mantendo a ordem original
    private var uniqueSearchResults: [String] {
        var seen = Set<String>()
        return searchResults.filter { seen.insert($0).inserted }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Fundo gradiente pastel azul/lavanda
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.82, green: 0.90, blue: 1.0),
                        Color(red: 0.90, green: 0.88, blue: 1.0),
                        Color(red: 0.95, green: 0.92, blue: 1.0)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
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
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Procurar Cidade")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                }
            }
        }
        .padding(16)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.35, green: 0.55, blue: 0.95),
                    Color(red: 0.65, green: 0.50, blue: 0.90),
                    Color(red: 0.80, green: 0.55, blue: 0.85)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
    }
    
    // MARK: - Search Bar
    
    private var searchBarView: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .font(.system(size: 16, weight: .semibold))
            
            TextField("Digite a cidade... (mín. 3 caracteres)", text: $searchText)
                .font(.system(size: 16, weight: .semibold))
                .autocorrectionDisabled()
                .onChange(of: searchText) { _, newValue in
                    if newValue.count >= 3 {
                        viewModel.searchCities(newValue) { results in
                            // Deduplica resultados
                            var seen = Set<String>()
                            searchResults = results.filter { seen.insert($0).inserted }
                            hasSearched = true
                        }
                    } else {
                        searchResults = []
                        hasSearched = newValue.count > 0 && newValue.count < 3 ? false : false
                    }
                }
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                    searchResults = []
                    hasSearched = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(12)
        .background(Color(.systemBackground).opacity(0.9))
        .cornerRadius(12)
        .padding(16)
    }
    
    // MARK: - Results
    
    private var resultsView: some View {
        ScrollView {
            VStack(spacing: 12) {
                if searchText.count >= 3 && uniqueSearchResults.isEmpty && hasSearched {
                    // Nenhum resultado encontrado
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 40, weight: .thin))
                            .foregroundColor(.gray.opacity(0.5))
                        Text("Nenhuma cidade encontrada")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.gray)
                        Text("Tente outro nome")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.gray.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(32)
                    
                } else if !uniqueSearchResults.isEmpty {
                    // Resultados da busca (sem duplicatas)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Resultados da Busca")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.5))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                        
                        ForEach(uniqueSearchResults, id: \.self) { city in
                            CitySearchResultRow(city: city, viewModel: viewModel, dismiss: dismiss)
                        }
                        .padding(.horizontal, 16)
                    }
                    
                } else {
                    // Cidades populares (estado inicial)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Cidades Populares")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.5))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        ForEach(popularCities, id: \.self) { city in
                            CitySearchResultRow(city: city, viewModel: viewModel, dismiss: dismiss)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
                Spacer().frame(height: 16)
            }
            .padding(.top, 8)
        }
    }
}

// MARK: - City Row

struct CitySearchResultRow: View {
    let city: String
    @ObservedObject var viewModel: WeatherViewModel
    let dismiss: DismissAction
    
    var body: some View {
        Button(action: {
            HapticManager.shared.trigger(.light)
            viewModel.cityName = city
            viewModel.loadWeather(for: city)
            dismiss()
        }) {
            HStack(spacing: 12) {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 16, weight: .semibold))
                Text(city)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray.opacity(0.4))
                    .font(.system(size: 14, weight: .semibold))
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6).opacity(0.8))
            )
        }
    }
}
