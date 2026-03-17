import SwiftUI

// MARK: - Animated Weather Icon
struct AnimatedWeatherIcon: View {
    let iconName: String
    let size: CGFloat
    var color: Color = Color(red: 0.3, green: 0.3, blue: 0.45)
    @State private var isAnimating = false
    
    var body: some View {
        Image(systemName: iconName)
            .font(.system(size: size, weight: .regular))
            .foregroundColor(color)
            .scaleEffect(isAnimating ? 1.1 : 1.0)
            .opacity(isAnimating ? 1.0 : 0.8)
            .animation(
                Animation.easeInOut(duration: 2.0)
                    .repeatForever(autoreverses: true),
                value: isAnimating
            )
            .onAppear { isAnimating = true }
    }
}

// MARK: - Weather Condition Animation
struct AnimatedConditionView: View {
    let condition: String
    @State private var rotation: Double = 0
    @State private var offset: CGFloat = 0
    @State private var isAnimating: Bool = false
    
    var body: some View {
        Group {
            switch condition.lowercased() {
            case "clear", "sunny":
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 60)).foregroundColor(.yellow)
                    .rotationEffect(.degrees(rotation))
                    .onAppear {
                        withAnimation(Animation.linear(duration: 20).repeatForever(autoreverses: false)) { rotation = 360 }
                    }
            case "cloudy", "overcast", "clouds":
                HStack(spacing: -10) {
                    Image(systemName: "cloud.fill").font(.system(size: 50)).foregroundColor(.gray)
                        .offset(x: offset)
                        .onAppear {
                            withAnimation(Animation.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) { offset = 10 }
                        }
                }
            case "rain", "drizzle", "rainy":
                VStack(spacing: 2) {
                    Image(systemName: "cloud.rain.fill").font(.system(size: 50)).foregroundColor(.blue)
                    HStack(spacing: 4) {
                        Image(systemName: "drop.fill").font(.caption).foregroundColor(.blue).offset(y: offset)
                        Image(systemName: "drop.fill").font(.caption).foregroundColor(.blue).offset(y: offset + 5)
                        Image(systemName: "drop.fill").font(.caption).foregroundColor(.blue).offset(y: offset + 10)
                    }
                }
                .onAppear {
                    withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) { offset = 15 }
                }
            case "snow":
                Image(systemName: "snow").font(.system(size: 60)).foregroundColor(.cyan)
                    .opacity(isAnimating ? 0.5 : 1.0)
                    .onAppear {
                        withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) { offset = 5 }
                    }
            case "thunderstorm", "thunder":
                VStack(spacing: 5) {
                    Image(systemName: "cloud.bolt.fill").font(.system(size: 50)).foregroundColor(.yellow)
                    Image(systemName: "bolt.fill").font(.caption).foregroundColor(.yellow)
                }
                .opacity(offset > 0 ? 1.0 : 0.5)
                .onAppear {
                    withAnimation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) { offset = 1 }
                }
            default:
                Image(systemName: "cloud.fill").font(.system(size: 60)).foregroundColor(.gray)
            }
        }
    }
}
