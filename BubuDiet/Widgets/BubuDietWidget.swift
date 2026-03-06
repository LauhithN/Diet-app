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

struct BubuDietWidgetEntryView: View {
    var entry: BubuDietWidgetProvider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(entry.snapshot.displayName)
                .font(.headline.weight(.bold))
                .foregroundStyle(Color(red: 0.43, green: 0.30, blue: 0.30))

            Text("\(entry.snapshot.consumedCalories) / \(entry.snapshot.consumedCalories + entry.snapshot.remainingCalories) cal")
                .font(.title3.weight(.bold))
                .foregroundStyle(Color(red: 0.78, green: 0.42, blue: 0.52))

            Text("\(entry.snapshot.remainingCalories) calories remaining")
                .font(.caption)
                .foregroundStyle(.secondary)

            Divider()

            Text("\(entry.snapshot.mealsCompleted) of \(entry.snapshot.totalMeals) meals completed")
                .font(.footnote.weight(.semibold))

            Text("Weight: \(entry.snapshot.currentWeight.oneDecimalText) lbs • Goal \(entry.snapshot.goalWeight.oneDecimalText)")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.97, blue: 0.94),
                    Color(red: 0.97, green: 0.84, blue: 0.82)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

struct BubuDietWidget: Widget {
    let kind = "BubuDietWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BubuDietWidgetProvider()) { entry in
            BubuDietWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("BubuDiet Summary")
        .description("Calories, meals completed, and weight progress for today.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    BubuDietWidget()
} timeline: {
    BubuDietWidgetEntry(date: .now, snapshot: .placeholder)
}
