import Charts
import SwiftUI

struct WeightChartView: View {
    let entries: [WeightEntry]
    let goalWeight: Double

    var body: some View {
        if entries.isEmpty {
            ContentUnavailableView("No weights logged yet", systemImage: "chart.line.uptrend.xyaxis")
        } else {
            Chart {
                ForEach(entries.sorted { $0.date < $1.date }) { entry in
                    AreaMark(
                        x: .value("Date", entry.date),
                        y: .value("Weight", entry.weight)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Theme.Palette.blush.opacity(0.45), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                    LineMark(
                        x: .value("Date", entry.date),
                        y: .value("Weight", entry.weight)
                    )
                    .foregroundStyle(Theme.Palette.rose)
                    .lineStyle(.init(lineWidth: 3.5, lineCap: .round))

                    PointMark(
                        x: .value("Date", entry.date),
                        y: .value("Weight", entry.weight)
                    )
                    .foregroundStyle(Theme.Palette.cocoa)
                }

                RuleMark(y: .value("Goal", goalWeight))
                    .foregroundStyle(Theme.Palette.sage)
                    .lineStyle(.init(lineWidth: 2, dash: [6, 5]))
                    .annotation(position: .topLeading) {
                        Text("Goal \(goalWeight.oneDecimalText)")
                            .font(Theme.Typography.caption)
                            .foregroundStyle(Theme.Palette.cocoa)
                    }
            }
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 4))
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .chartLegend(.hidden)
            .frame(height: 260)
        }
    }
}

#Preview {
    WeightChartView(entries: SampleData.weightEntries(), goalWeight: 180)
        .padding()
}
