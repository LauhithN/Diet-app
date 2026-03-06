import SwiftUI

enum ProgressWidgetPalette {
    static let title = Color(red: 0.49, green: 0.29, blue: 0.35)
    static let headline = Color(red: 0.20, green: 0.14, blue: 0.17)
    static let accent = Color(red: 0.65, green: 0.36, blue: 0.43)
    static let accentSoft = Color(red: 0.90, green: 0.64, blue: 0.70)
}

struct ProgressWidgetBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 1.0, green: 0.97, blue: 0.95),
                Color(red: 0.97, green: 0.90, blue: 0.91)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct ProgressWidgetBar: View {
    let value: Double

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule(style: .continuous)
                    .fill(Color.black.opacity(0.08))

                Capsule(style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                ProgressWidgetPalette.accent,
                                ProgressWidgetPalette.accentSoft
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: proxy.size.width * min(max(value, 0), 1))
            }
        }
        .frame(height: 12)
    }
}

struct ProgressWidgetRing: View {
    let value: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.black.opacity(0.08), lineWidth: 10)

            Circle()
                .trim(from: 0, to: min(max(value, 0), 1))
                .stroke(
                    LinearGradient(
                        colors: [
                            ProgressWidgetPalette.accent,
                            ProgressWidgetPalette.accentSoft
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
        }
    }
}
