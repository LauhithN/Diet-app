import SwiftUI

struct CalorieRingView: View {
    let progress: Double
    let consumed: Int
    let remaining: Int

    @State private var animatedProgress = 0.0

    var body: some View {
        ZStack {
            Circle()
                .stroke(Theme.Palette.border.opacity(0.45), lineWidth: 18)

            Circle()
                .trim(from: 0, to: min(max(animatedProgress, 0), 1))
                .stroke(
                    Theme.Gradients.ring,
                    style: StrokeStyle(lineWidth: 18, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: Theme.Palette.rose.opacity(0.18), radius: 12, x: 0, y: 8)

            VStack(spacing: Theme.Spacing.xxs) {
                Text("\(Int((progress * 100).rounded()))%")
                    .font(Theme.Typography.stat)
                    .foregroundStyle(Theme.Palette.cocoa)
                    .minimumScaleFactor(0.8)

                Text("\(consumed) consumed")
                    .font(Theme.Typography.bodyStrong)
                    .foregroundStyle(Theme.Palette.mist)

                Text("\(remaining) left today")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Theme.Palette.rose)
            }
        }
        .frame(width: 176, height: 176)
        .padding(.vertical, Theme.Spacing.xs)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Calorie progress")
        .accessibilityValue("\(consumed) consumed, \(remaining) remaining")
        .onAppear {
            animatedProgress = 0
            withAnimation(.spring(response: 0.8, dampingFraction: 0.82).delay(0.08)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.spring(response: 0.8, dampingFraction: 0.82)) {
                animatedProgress = newValue
            }
        }
    }
}

#Preview {
    CalorieRingView(progress: 0.62, consumed: 930, remaining: 570)
        .padding()
        .background(BubuScreenBackground())
}
