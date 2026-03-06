import Foundation

struct NotificationPreferences: Codable, Equatable {
    var notificationsEnabled: Bool
    var breakfastEnabled: Bool
    var lunchEnabled: Bool
    var dinnerEnabled: Bool
    var weighInEnabled: Bool
    var breakfastTime: Date
    var lunchTime: Date
    var dinnerTime: Date
    var weighInTime: Date

    static var `default`: NotificationPreferences {
        NotificationPreferences(
            notificationsEnabled: true,
            breakfastEnabled: true,
            lunchEnabled: true,
            dinnerEnabled: true,
            weighInEnabled: true,
            breakfastTime: Calendar.current.date(from: DateComponents(hour: 8, minute: 0)) ?? Date(),
            lunchTime: Calendar.current.date(from: DateComponents(hour: 13, minute: 0)) ?? Date(),
            dinnerTime: Calendar.current.date(from: DateComponents(hour: 19, minute: 0)) ?? Date(),
            weighInTime: Calendar.current.date(from: DateComponents(hour: 21, minute: 0)) ?? Date()
        )
    }

    func nextReminder(after date: Date = Date()) -> (title: String, date: Date)? {
        guard notificationsEnabled else { return nil }

        let calendar = Calendar.current
        let reminderPairs: [(String, Bool, Date)] = [
            ("Breakfast", breakfastEnabled, breakfastTime),
            ("Lunch", lunchEnabled, lunchTime),
            ("Dinner", dinnerEnabled, dinnerTime),
            ("Weigh-in", weighInEnabled, weighInTime)
        ]

        let normalized = reminderPairs.compactMap { title, enabled, baseTime -> (String, Date)? in
            guard enabled else { return nil }
            let time = calendar.date(
                bySettingHour: calendar.component(.hour, from: baseTime),
                minute: calendar.component(.minute, from: baseTime),
                second: 0,
                of: date
            ) ?? baseTime
            let resolved = time > date ? time : calendar.date(byAdding: .day, value: 1, to: time)
            guard let resolved else { return nil }
            return (title, resolved)
        }

        return normalized.min { $0.1 < $1.1 }
    }
}
