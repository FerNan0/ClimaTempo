// filepath: ClimaAgora/Views/Components/LoadingOverlay.swift
import SwiftUI

/// Spinner centralizado na tela com fundo semi-transparente.
/// Usado como overlay em qualquer tela que esteja carregando dados.
struct LoadingOverlay: View {
    var message: String = "Carregando..."
    
    var body: some View {
        ZStack {
            Color.white.opacity(0.35)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 0.4, green: 0.4, blue: 0.7)))
                    .scaleEffect(1.5)
                
                Text(message)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(red: 0.25, green: 0.25, blue: 0.35))
                    .multilineTextAlignment(.center)
            }
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .shadow(color: Color.black.opacity(0.1), radius: 16, x: 0, y: 8)
            )
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message)
    }
}

/// View modifier para aplicar o overlay de loading facilmente.
struct LoadingModifier: ViewModifier {
    let isLoading: Bool
    let message: String
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isLoading {
                LoadingOverlay(message: message)
                    .transition(.opacity.animation(.easeInOut(duration: 0.2)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isLoading)
    }
}

extension View {
    /// Mostra um spinner centralizado na tela quando `isLoading` for true.
    func loadingOverlay(isLoading: Bool, message: String = "Carregando...") -> some View {
        modifier(LoadingModifier(isLoading: isLoading, message: message))
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [
                Color(red: 0.82, green: 0.90, blue: 1.0),
                Color(red: 0.90, green: 0.88, blue: 1.0)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        Text("Conteúdo da tela")
            .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.3))
    }
    .loadingOverlay(isLoading: true, message: "Buscando clima...")
}
