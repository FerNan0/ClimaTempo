import Foundation

// MARK: - StructuredActivity (resultado estruturado da IA — domínio puro)
//
// Antes, a resposta da IA vinha como TEXTO solto e era desmontada por parsing
// frágil de string (`AccessibilityHelper.parseActivitiesFromAI`: split em " - ",
// regex de emoji). Com Guided Generation (@Generable) do Foundation Models, o
// modelo devolve dados já ESTRUTURADOS e tipados — este é o modelo de domínio
// puro que atravessa as camadas (protocolo → use case → view), sem depender de
// SwiftUI nem do framework da Apple.
//
// A conversão para o card visual (`AccessibleActivity`) acontece na camada de UI.

struct StructuredActivity: Equatable {
    /// Nome curto da atividade (ex.: "Caminhada no parque").
    let name: String
    /// Explicação em uma frase simples (Plain Language).
    let explanation: String
    /// Categoria em texto (ex.: "Ao Ar Livre"). Mapeada para `ActivityCategory` na UI.
    let category: String
    /// Nível de esforço em texto ("Fácil"/"Moderado"/"Intenso"). Mapeado na UI.
    let difficulty: String
}
