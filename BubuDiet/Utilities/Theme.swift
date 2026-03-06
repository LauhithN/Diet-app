import SwiftUI

enum Theme {
    static let blush = Color(hex: "F5B8C9")
    static let peach = Color(hex: "F9D1BE")
    static let cream = Color(hex: "FFF8F1")
    static let beige = Color(hex: "F0E1D4")
    static let rose = Color(hex: "C86B85")
    static let cocoa = Color(hex: "6E4C4C")
    static let mint = Color(hex: "BFD8C8")

    static let heroGradient = LinearGradient(
        colors: [blush, peach, cream],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

struct BubuCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.white.opacity(0.92))
                    .shadow(color: .black.opacity(0.08), radius: 18, x: 0, y: 10)
            )
    }
}

extension View {
    func bubuCard() -> some View {
        modifier(BubuCardModifier())
    }
}
