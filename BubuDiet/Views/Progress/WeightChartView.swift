import Charts
import SwiftUI

struct WeightChartView: View {
    let entries: [WeightEntry]
    let goalWeight: Double

    private let milestones: [Double] = [220, 210, 200, 190, 180]

    var body: some View {
        if entries.isEmpty {
            ContentUnavailableView("No weights logged yet", systemImage: "chart.line.uptrend.xyaxis")
        } else {
            Chart {
                ForEach(entries.sorted { $0.date < $1.date }) { entry in
                    LineMark(
                        x: .value("Date", entry.date),
                        y: .value("Weight", entry.weight)
                    )
                    .foregroundStyle(Theme.rose)
                    .lineStyle(.init(lineWidth: 3))

                    AreaMark(
                        x: .value("Date", entry.date),
                        y: .value("Weight", entry.weight)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Theme.blush.opacity(0.35), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                    PointMark(
                        x: .value("Date", entry.date),
                        y: .value("Weight", entry.weight)
                    )
                    .foregroundStyle(Theme.cocoa)
                }

                RuleMark(y: .value("Goal", goalWeight))
                    .foregroundStyle(Theme.mint)
                    .lineStyle(.init(lineWidth: 2, dash: [6, 6]))
                    .annotation(position: .topLeading) {
                        Text("Goal \(goalWeight.oneDecimalText)")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(Theme.cocoa)
                    }

                ForEach(milestones.filter { $0 != goalWeight }, id: \.self) { value in
                    RuleMark(y: .value("Milestone", value))
                        .foregroundStyle(Theme.beige.opacity(0.5))
                        .lineStyle(.init(lineWidth: 1, dash: [2, 4]))
                }
            }
            .frame(height: 240)
        }
    }
}

#Preview {
    WeightChartView(entries: SampleData.weightEntries(), goalWeight: 180)
        .padding()
}
