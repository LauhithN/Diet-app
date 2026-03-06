import SwiftUI

struct SummaryCardView: View {
    let title: String
    let value: String
    let detail: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: systemImage)
                    .foregroundStyle(Theme.rose)
                Spacer()
                Text(title)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(Theme.cocoa)

            Text(detail)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .bubuCard()
    }
}

#Preview {
    SummaryCardView(title: "Goal", value: "180 lbs", detail: "45 lbs to go", systemImage: "flag")
        .padding()
        .background(Theme.cream)
}
