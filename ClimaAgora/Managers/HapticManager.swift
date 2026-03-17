import SwiftUI

class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    // MARK: - Tipos de Feedback
    enum FeedbackType {
        case light
        case medium
        case heavy
        case success
        case warning
        case error
        case selection
    }
    
    // MARK: - Disparar Haptic Feedback
    func trigger(_ type: FeedbackType) {
        switch type {
        case .light:
            let feedback = UIImpactFeedbackGenerator(style: .light)
            feedback.impactOccurred()
            
        case .medium:
            let feedback = UIImpactFeedbackGenerator(style: .medium)
            feedback.impactOccurred()
            
        case .heavy:
            let feedback = UIImpactFeedbackGenerator(style: .heavy)
            feedback.impactOccurred()
            
        case .success:
            let feedback = UINotificationFeedbackGenerator()
            feedback.notificationOccurred(.success)
            
        case .warning:
            let feedback = UINotificationFeedbackGenerator()
            feedback.notificationOccurred(.warning)
            
        case .error:
            let feedback = UINotificationFeedbackGenerator()
            feedback.notificationOccurred(.error)
            
        case .selection:
            let feedback = UISelectionFeedbackGenerator()
            feedback.selectionChanged()
        }
    }
}

// MARK: - View Extension para Feedback
extension View {
    func hapticFeedback(_ type: HapticManager.FeedbackType = .light) -> some View {
        self.onTapGesture {
            HapticManager.shared.trigger(type)
        }
    }
}
