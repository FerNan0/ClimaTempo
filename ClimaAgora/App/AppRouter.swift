import SwiftUI

// MARK: - AppRouter (raiz da composição em SwiftUI)
//
// Cria o RouterManager (composition root), monta o HomeViewModel a partir dele
// e injeta o router na tela de entrada para a navegação por eventos.

@MainActor
struct AppRouter: View {
    @StateObject private var router: RouterManager
    @StateObject private var homeViewModel: HomeViewModel
    @StateObject private var locationManager = LocationManager()

    init() {
        let manager = RouterManager()
        _router        = StateObject(wrappedValue: manager)
        _homeViewModel = StateObject(wrappedValue: manager.makeHomeViewModel())
    }

    var body: some View {
        ContentView(
            viewModel: homeViewModel,
            router: router,
            locationManager: locationManager
        )
    }
}
