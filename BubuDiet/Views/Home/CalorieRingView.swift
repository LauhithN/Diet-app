import SwiftUI

struct CalorieRingView: View {
    let progress: Double
    let consumed: Int
    let remaining: Int

    var body: some View {
        ZStack {
            Circle()
                .stroke(Theme.beige.opacity(0.4), lineWidth: 20)

            Circle()
                .trim(from: 0, to: min(max(progress, 0), 1))
                .stroke(
                    AngularGradient(colors: [Theme.rose, Theme.blush, Theme.peach], center: .center),
                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            VStack(spacing: 6) {
                Text("\(consumed)")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.cocoa)
                Text("consumed")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                Text("\(remaining) left")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Theme.rose)
            }
        }
        .frame(width: 180, height: 180)
        .padding(.vertical, 8)
    }
}

#Preview {
    CalorieRingView(progress: 0.62, consumed: 930, remaining: 570)
}
