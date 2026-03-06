import SwiftUI

struct SummaryCardView: View {
    let title: String
    let value: String
    let detail: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack {
                Image(systemName: systemImage)
                    .font(.headline)
                    .foregroundStyle(Theme.Palette.rose)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(Theme.Palette.blush.opacity(0.55))
                    )

                Spacer(minLength: Theme.Spacing.xs)

                Text(title)
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Theme.Palette.mist)
                    .multilineTextAlignment(.trailing)
            }

            Text(value)
                .font(Theme.Typography.section)
                .foregroundStyle(Theme.Palette.cocoa)
                .minimumScaleFactor(0.8)

            Text(detail)
                .font(Theme.Typography.footnote)
                .foregroundStyle(Theme.Palette.mist)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, minHeight: 154, alignment: .leading)
        .bubuCard(tint: Theme.Palette.surface)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    SummaryCardView(title: "Goal", value: "180 lbs", detail: "45 lbs to go", systemImage: "flag")
        .padding()
        .background(BubuScreenBackground())
}
