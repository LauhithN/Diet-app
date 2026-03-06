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

private struct CalorieProgressWidgetEntryView: View {
    let entry: BubuDietWidgetEntry

    private var progress: Double {
        let total = entry.snapshot.consumedCalories + entry.snapshot.remainingCalories
        guard total > 0 else { return 0 }
        return Double(entry.snapshot.consumedCalories) / Double(total)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daily calorie progress")
                .font(.caption.weight(.semibold))
                .foregroundStyle(ProgressWidgetPalette.title)

            HStack(spacing: 14) {
                ZStack {
                    ProgressWidgetRing(value: progress)
                    Text("\(Int((progress * 100).rounded()))%")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(ProgressWidgetPalette.headline)
                }
                .frame(width: 62, height: 62)

                VStack(alignment: .leading, spacing: 4) {
                    Text("\(entry.snapshot.consumedCalories) / \(entry.snapshot.consumedCalories + entry.snapshot.remainingCalories)")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(ProgressWidgetPalette.headline)

                    Text("calories today")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            HStack {
                Text("\(entry.snapshot.remainingCalories) left")
                Spacer()
                Text("\(entry.snapshot.mealsCompleted)/\(entry.snapshot.totalMeals) meals")
            }
            .font(.caption2.weight(.medium))
            .foregroundStyle(ProgressWidgetPalette.title)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .containerBackground(for: .widget) {
            ProgressWidgetBackground()
        }
    }
}

private struct MealReminderWidgetEntryView: View {
    let entry: BubuDietWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Meal reminder")
                .font(.caption.weight(.semibold))
                .foregroundStyle(ProgressWidgetPalette.title)

            Text(entry.snapshot.nextReminderTitle)
                .font(.title3.weight(.semibold))
                .foregroundStyle(ProgressWidgetPalette.headline)

            Text(entry.snapshot.nextReminderTimeText)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(ProgressWidgetPalette.accent)

            Spacer(minLength: 0)

            Text("\(entry.snapshot.mealsCompleted) of \(entry.snapshot.totalMeals) meals completed today")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .containerBackground(for: .widget) {
            ProgressWidgetBackground()
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
                .foregroundStyle(ProgressWidgetPalette.title)

            HStack(alignment: .firstTextBaseline) {
                Text(entry.snapshot.currentWeight.oneDecimalText)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(ProgressWidgetPalette.headline)
                Text("lbs")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            ProgressWidgetBar(value: progress)

            HStack {
                Text("Lost \(entry.snapshot.poundsLost.oneDecimalText) lbs")
                Spacer()
                Text("Goal \(entry.snapshot.goalWeight.oneDecimalText)")
            }
            .font(.caption2.weight(.medium))
            .foregroundStyle(ProgressWidgetPalette.title)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .containerBackground(for: .widget) {
            ProgressWidgetBackground()
        }
    }
}

private struct RomanticMotivationWidgetEntryView: View {
    let entry: BubuDietWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("For \(entry.snapshot.displayName)")
                .font(.caption.weight(.semibold))
                .foregroundStyle(ProgressWidgetPalette.title)

            Text(entry.snapshot.motivationLine)
                .font(.headline.weight(.semibold))
                .foregroundStyle(ProgressWidgetPalette.headline)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)

            Text("Updated \(entry.date.timeLabel)")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .containerBackground(for: .widget) {
            ProgressWidgetBackground()
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
