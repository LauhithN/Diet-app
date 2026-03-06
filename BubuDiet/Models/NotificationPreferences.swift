import Foundation

struct NotificationPreferences: Codable, Equatable {
    var notificationsEnabled: Bool
    var breakfastEnabled: Bool
    var lunchEnabled: Bool
    var dinnerEnabled: Bool
    var weighInEnabled: Bool
    var waterReminderEnabled: Bool
    var motivationReminderEnabled: Bool
    var breakfastTime: Date
    var lunchTime: Date
    var dinnerTime: Date
    var weighInTime: Date
    var waterReminderTime: Date
    var motivationReminderTime: Date

    enum CodingKeys: String, CodingKey {
        case notificationsEnabled
        case breakfastEnabled
        case lunchEnabled
        case dinnerEnabled
        case weighInEnabled
        case waterReminderEnabled
        case motivationReminderEnabled
        case breakfastTime
        case lunchTime
        case dinnerTime
        case weighInTime
        case waterReminderTime
        case motivationReminderTime
    }

    static var `default`: NotificationPreferences {
        NotificationPreferences(
            notificationsEnabled: true,
            breakfastEnabled: true,
            lunchEnabled: true,
            dinnerEnabled: true,
            weighInEnabled: true,
            waterReminderEnabled: true,
            motivationReminderEnabled: true,
            breakfastTime: Self.defaultTime(hour: 8, minute: 0),
            lunchTime: Self.defaultTime(hour: 13, minute: 0),
            dinnerTime: Self.defaultTime(hour: 19, minute: 0),
            weighInTime: Self.defaultTime(hour: 21, minute: 0),
            waterReminderTime: Self.defaultTime(hour: 15, minute: 0),
            motivationReminderTime: Self.defaultTime(hour: 10, minute: 30)
        )
    }

    init(
        notificationsEnabled: Bool,
        breakfastEnabled: Bool,
        lunchEnabled: Bool,
        dinnerEnabled: Bool,
        weighInEnabled: Bool,
        waterReminderEnabled: Bool,
        motivationReminderEnabled: Bool,
        breakfastTime: Date,
        lunchTime: Date,
        dinnerTime: Date,
        weighInTime: Date,
        waterReminderTime: Date,
        motivationReminderTime: Date
    ) {
        self.notificationsEnabled = notificationsEnabled
        self.breakfastEnabled = breakfastEnabled
        self.lunchEnabled = lunchEnabled
        self.dinnerEnabled = dinnerEnabled
        self.weighInEnabled = weighInEnabled
        self.waterReminderEnabled = waterReminderEnabled
        self.motivationReminderEnabled = motivationReminderEnabled
        self.breakfastTime = breakfastTime
        self.lunchTime = lunchTime
        self.dinnerTime = dinnerTime
        self.weighInTime = weighInTime
        self.waterReminderTime = waterReminderTime
        self.motivationReminderTime = motivationReminderTime
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let defaults = NotificationPreferences.default

        notificationsEnabled = try container.decodeIfPresent(Bool.self, forKey: .notificationsEnabled) ?? defaults.notificationsEnabled
        breakfastEnabled = try container.decodeIfPresent(Bool.self, forKey: .breakfastEnabled) ?? defaults.breakfastEnabled
        lunchEnabled = try container.decodeIfPresent(Bool.self, forKey: .lunchEnabled) ?? defaults.lunchEnabled
        dinnerEnabled = try container.decodeIfPresent(Bool.self, forKey: .dinnerEnabled) ?? defaults.dinnerEnabled
        weighInEnabled = try container.decodeIfPresent(Bool.self, forKey: .weighInEnabled) ?? defaults.weighInEnabled
        waterReminderEnabled = try container.decodeIfPresent(Bool.self, forKey: .waterReminderEnabled) ?? defaults.waterReminderEnabled
        motivationReminderEnabled = try container.decodeIfPresent(Bool.self, forKey: .motivationReminderEnabled) ?? defaults.motivationReminderEnabled
        breakfastTime = try container.decodeIfPresent(Date.self, forKey: .breakfastTime) ?? defaults.breakfastTime
        lunchTime = try container.decodeIfPresent(Date.self, forKey: .lunchTime) ?? defaults.lunchTime
        dinnerTime = try container.decodeIfPresent(Date.self, forKey: .dinnerTime) ?? defaults.dinnerTime
        weighInTime = try container.decodeIfPresent(Date.self, forKey: .weighInTime) ?? defaults.weighInTime
        waterReminderTime = try container.decodeIfPresent(Date.self, forKey: .waterReminderTime) ?? defaults.waterReminderTime
        motivationReminderTime = try container.decodeIfPresent(Date.self, forKey: .motivationReminderTime) ?? defaults.motivationReminderTime
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(notificationsEnabled, forKey: .notificationsEnabled)
        try container.encode(breakfastEnabled, forKey: .breakfastEnabled)
        try container.encode(lunchEnabled, forKey: .lunchEnabled)
        try container.encode(dinnerEnabled, forKey: .dinnerEnabled)
        try container.encode(weighInEnabled, forKey: .weighInEnabled)
        try container.encode(waterReminderEnabled, forKey: .waterReminderEnabled)
        try container.encode(motivationReminderEnabled, forKey: .motivationReminderEnabled)
        try container.encode(breakfastTime, forKey: .breakfastTime)
        try container.encode(lunchTime, forKey: .lunchTime)
        try container.encode(dinnerTime, forKey: .dinnerTime)
        try container.encode(weighInTime, forKey: .weighInTime)
        try container.encode(waterReminderTime, forKey: .waterReminderTime)
        try container.encode(motivationReminderTime, forKey: .motivationReminderTime)
    }

    func nextReminder(after date: Date = Date()) -> (title: String, date: Date)? {
        guard notificationsEnabled else { return nil }
        return scheduledReminders(after: date).min { $0.date < $1.date }
    }

    func nextMealReminder(after date: Date = Date()) -> (title: String, date: Date)? {
        guard notificationsEnabled else { return nil }
        return scheduledReminders(after: date, includeLifestyle: false).min { $0.date < $1.date }
    }

    private func scheduledReminders(after date: Date, includeLifestyle: Bool = true) -> [(title: String, date: Date)] {
        let calendar = Calendar.current
        var reminderPairs: [(String, Bool, Date)] = [
            ("Breakfast", breakfastEnabled, breakfastTime),
            ("Lunch", lunchEnabled, lunchTime),
            ("Dinner", dinnerEnabled, dinnerTime),
            ("Weigh-in", weighInEnabled, weighInTime)
        ]

        if includeLifestyle {
            reminderPairs.append(("Water", waterReminderEnabled, waterReminderTime))
            reminderPairs.append(("Motivation", motivationReminderEnabled, motivationReminderTime))
        }

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

        return normalized.map { (title: $0.0, date: $0.1) }
    }

    private static func defaultTime(hour: Int, minute: Int) -> Date {
        Calendar.current.date(from: DateComponents(hour: hour, minute: minute)) ?? Date()
    }
}
