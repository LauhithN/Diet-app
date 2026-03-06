import Charts
import SwiftUI

struct ProgressChartsView: View {
    let weightEntries: [WeightEntry]
    let weeklyAverages: [WeeklyAverage]
    let calorieTarget: Int
    let dailyPlans: [DailyPlan]
    let goalWeight: Double

    private var todayPlan: DailyPlan? {
        dailyPlans.first { Calendar.current.isDateInToday($0.date) } ?? dailyPlans.sorted { $0.date > $1.date }.first
    }

    private var todayConsumed: Int {
        todayPlan?.totalConsumedCalories ?? 0
    }

    private var todayRemaining: Int {
        max(calorieTarget - todayConsumed, 0)
    }

    private var calorieProgress: Double {
        min(max(Double(todayConsumed) / Double(max(calorieTarget, 1)), 0), 1)
    }

    private var averageCalories: Int {
        guard !dailyPlans.isEmpty else { return 0 }
        return Int((Double(dailyPlans.reduce(0) { $0 + $1.totalConsumedCalories }) / Double(dailyPlans.count)).rounded())
    }

    private var sevenDayWeightChange: Double {
        let ordered = weightEntries.sorted { $0.date < $1.date }
        guard let first = ordered.first, let last = ordered.last else { return 0 }
        return last.weight - first.weight
    }

    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            overviewCard
            weightHistoryCard
            calorieTrendCard
            weeklyTrendCard
        }
    }

    private var overviewCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            BubuSectionHeader(
                eyebrow: "Dashboard",
                title: "Daily progress at a glance",
                subtitle: "A soft dashboard for calories, weight, and weekly direction without turning the experience into a harsh tracker."
            )

            ViewThatFits(in: .horizontal) {
                HStack(spacing: Theme.Spacing.lg) {
                    CalorieRingView(
                        progress: calorieProgress,
                        consumed: todayConsumed,
                        remaining: todayRemaining
                    )

                    VStack(spacing: Theme.Spacing.xs) {
                        BubuMetricPill(title: "Target", value: calorieTarget.calorieText, icon: "target")
                        BubuMetricPill(title: "Weekly average", value: averageCalories.calorieText, icon: "chart.bar.fill", accent: Theme.Palette.sage)
                        BubuMetricPill(
                            title: "Weight change",
                            value: "\(sevenDayWeightChange < 0 ? "" : "+")\(sevenDayWeightChange.oneDecimalText) lbs",
                            icon: "arrow.up.forward.circle.fill",
                            accent: sevenDayWeightChange <= 0 ? Theme.Palette.sage : Theme.Palette.warning
                        )
                    }
                }

                VStack(spacing: Theme.Spacing.md) {
                    CalorieRingView(
                        progress: calorieProgress,
                        consumed: todayConsumed,
                        remaining: todayRemaining
                    )

                    HStack(spacing: Theme.Spacing.xs) {
                        BubuMetricPill(title: "Target", value: calorieTarget.calorieText, icon: "target")
                        BubuMetricPill(title: "Weekly average", value: averageCalories.calorieText, icon: "chart.bar.fill", accent: Theme.Palette.sage)
                    }

                    BubuMetricPill(
                        title: "Weight change",
                        value: "\(sevenDayWeightChange < 0 ? "" : "+")\(sevenDayWeightChange.oneDecimalText) lbs",
                        icon: "arrow.up.forward.circle.fill",
                        accent: sevenDayWeightChange <= 0 ? Theme.Palette.sage : Theme.Palette.warning
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .bubuCard(tint: Theme.Palette.surface)
    }

    private var weightHistoryCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Weight history")
                .font(Theme.Typography.section)
                .foregroundStyle(Theme.Palette.cocoa)

            WeightChartView(entries: weightEntries, goalWeight: goalWeight)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .bubuCard(tint: Theme.Palette.surface)
    }

    private var calorieTrendCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Calorie intake")
                .font(Theme.Typography.section)
                .foregroundStyle(Theme.Palette.cocoa)

            CalorieTrendChartView(plans: dailyPlans, targetCalories: calorieTarget)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .bubuCard(tint: Theme.Palette.surface)
    }

    private var weeklyTrendCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Weekly trend")
                .font(Theme.Typography.section)
                .foregroundStyle(Theme.Palette.cocoa)

            if weeklyAverages.isEmpty {
                ContentUnavailableView("Log a few entries to unlock the weekly trend.", systemImage: "calendar")
                    .frame(maxWidth: .infinity, minHeight: 220)
            } else {
                Chart {
                    ForEach(weeklyAverages) { average in
                        BarMark(
                            x: .value("Week", average.weekStart, unit: .weekOfYear),
                            y: .value("Average Weight", average.averageWeight)
                        )
                        .foregroundStyle(Theme.Palette.sage.opacity(0.85))
                        .cornerRadius(8)

                        RuleMark(y: .value("Goal", goalWeight))
                            .foregroundStyle(Theme.Palette.rose.opacity(0.35))
                            .lineStyle(.init(lineWidth: 1.5, dash: [5, 4]))
                    }
                }
                .chartXAxis {
                    AxisMarks(values: weeklyAverages.map(\.weekStart)) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(Theme.Palette.border.opacity(0.6))
                        AxisValueLabel {
                            if let date = value.as(Date.self) {
                                Text(date.shortDateLabel)
                                    .font(Theme.Typography.caption)
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(Theme.Palette.border.opacity(0.6))
                        AxisValueLabel()
                            .font(Theme.Typography.caption)
                    }
                }
                .chartLegend(.hidden)
                .frame(height: 240)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .bubuCard(tint: Theme.Palette.surface)
    }
}

#Preview {
    ProgressChartsView(
        weightEntries: SampleData.weightEntries(),
        weeklyAverages: [
            WeeklyAverage(weekStart: Calendar.current.date(byAdding: .day, value: -21, to: Date()) ?? Date(), averageWeight: 223.7),
            WeeklyAverage(weekStart: Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date(), averageWeight: 220.4),
            WeeklyAverage(weekStart: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date(), averageWeight: 217.6)
        ],
        calorieTarget: AppConstants.defaultCalorieTarget,
        dailyPlans: SampleData.weeklyPlan().days,
        goalWeight: 180
    )
    .padding()
    .background(BubuScreenBackground())
}
