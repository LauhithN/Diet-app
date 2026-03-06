import SwiftUI
import WidgetKit

struct BubuDietWidgetEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot
}

struct BubuDietWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> BubuDietWidgetEntry {
        BubuDietWidgetEntry(date: Date(), snapshot: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (BubuDietWidgetEntry) -> Void) {
        completion(BubuDietWidgetEntry(date: Date(), snapshot: loadSnapshot()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<BubuDietWidgetEntry>) -> Void) {
        let entry = BubuDietWidgetEntry(date: Date(), snapshot: loadSnapshot())
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date().addingTimeInterval(1800)
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    private func loadSnapshot() -> WidgetSnapshot {
        let defaults = UserDefaults(suiteName: AppConstants.appGroupIdentifier) ?? .standard
        guard let data = defaults.data(forKey: StorageKeys.widgetSnapshot) else {
            return .placeholder
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode(WidgetSnapshot.self, from: data)) ?? .placeholder
    }
}

private struct BubuWidgetBackground: View {
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

private struct WidgetProgressBar: View {
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
                                Color(red: 0.65, green: 0.36, blue: 0.43),
                                Color(red: 0.90, green: 0.64, blue: 0.70)
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

private struct CalorieProgressWidgetEntryView: View {
    let entry: BubuDietWidgetEntry

    private var progress: Double {
        let total = entry.snapshot.consumedCalories + entry.snapshot.remainingCalories
        guard total > 0 else { return 0 }
        return Double(entry.snapshot.consumedCalories) / Double(total)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Calorie progress")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color(red: 0.49, green: 0.29, blue: 0.35))

            Text("\(entry.snapshot.consumedCalories) / \(entry.snapshot.consumedCalories + entry.snapshot.remainingCalories)")
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color(red: 0.20, green: 0.14, blue: 0.17))

            Text("calories today")
                .font(.caption)
                .foregroundStyle(.secondary)

            WidgetProgressBar(value: progress)

            HStack {
                Text("\(entry.snapshot.remainingCalories) left")
                Spacer()
                Text("\(entry.snapshot.mealsCompleted)/\(entry.snapshot.totalMeals) meals")
            }
            .font(.caption2.weight(.medium))
            .foregroundStyle(Color(red: 0.49, green: 0.29, blue: 0.35))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .containerBackground(for: .widget) {
            BubuWidgetBackground()
        }
    }
}

private struct MealReminderWidgetEntryView: View {
    let entry: BubuDietWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Next reminder")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color(red: 0.49, green: 0.29, blue: 0.35))

            Text(entry.snapshot.nextReminderTitle)
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color(red: 0.20, green: 0.14, blue: 0.17))

            Text(entry.snapshot.nextReminderTimeText)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color(red: 0.65, green: 0.36, blue: 0.43))

            Spacer(minLength: 0)

            Text("\(entry.snapshot.mealsCompleted) of \(entry.snapshot.totalMeals) meals completed today")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .containerBackground(for: .widget) {
            BubuWidgetBackground()
        }
    }
}

private struct WeightProgressWidgetEntryView: View {
    let entry: BubuDietWidgetEntry

    private var progress: Double {
        let totalNeeded = max(entry.snapshot.currentWeight + entry.snapshot.poundsLost - entry.snapshot.goalWeight, 1)
        return min(max(entry.snapshot.poundsLost / totalNeeded, 0), 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weight progress")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color(red: 0.49, green: 0.29, blue: 0.35))

            HStack(alignment: .firstTextBaseline) {
                Text(entry.snapshot.currentWeight.oneDecimalText)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Color(red: 0.20, green: 0.14, blue: 0.17))
                Text("lbs")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            WidgetProgressBar(value: progress)

            HStack {
                Text("Lost \(entry.snapshot.poundsLost.oneDecimalText) lbs")
                Spacer()
                Text("Goal \(entry.snapshot.goalWeight.oneDecimalText)")
            }
            .font(.caption2.weight(.medium))
            .foregroundStyle(Color(red: 0.49, green: 0.29, blue: 0.35))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .containerBackground(for: .widget) {
            BubuWidgetBackground()
        }
    }
}

private struct RomanticMotivationWidgetEntryView: View {
    let entry: BubuDietWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("For \(entry.snapshot.displayName)")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color(red: 0.49, green: 0.29, blue: 0.35))

            Text(entry.snapshot.motivationLine)
                .font(.headline.weight(.semibold))
                .foregroundStyle(Color(red: 0.20, green: 0.14, blue: 0.17))
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)

            Text("Updated \(entry.date.timeLabel)")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .containerBackground(for: .widget) {
            BubuWidgetBackground()
        }
    }
}

struct CalorieProgressWidget: Widget {
    let kind = "CalorieProgressWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BubuDietWidgetProvider()) { entry in
            CalorieProgressWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Calorie Progress")
        .description("Track calories and meals completed at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct DailyMealReminderWidget: Widget {
    let kind = "DailyMealReminderWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BubuDietWidgetProvider()) { entry in
            MealReminderWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Daily Meal Reminder")
        .description("See the next reminder time and meal completion status.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct WeightProgressWidget: Widget {
    let kind = "WeightProgressWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BubuDietWidgetProvider()) { entry in
            WeightProgressWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Weight Progress")
        .description("Watch the current weight trend and goal progress.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct RomanticMotivationalWidget: Widget {
    let kind = "RomanticMotivationalWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BubuDietWidgetProvider()) { entry in
            RomanticMotivationWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Romantic Motivation")
        .description("A gentle supportive line for Bubu throughout the day.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    CalorieProgressWidget()
} timeline: {
    BubuDietWidgetEntry(date: .now, snapshot: .placeholder)
}
