import Foundation

struct RomanticMessageGenerator {
    private static let gentleTemplates = [
        "You're doing amazing today, {name}.",
        "Every step brings you closer to your goal.",
        "Your future self will thank you for today's gentle effort.",
        "One loving choice at a time, {name}.",
        "A calm routine still counts, especially today.",
        "You're building something steady and beautiful, {name}."
    ]

    private static let nearlyDoneTemplates = [
        "Only a little more to go today, {name}. Keep it soft and steady.",
        "The day is almost complete, and you're handling it with care.",
        "One more gentle choice and today's rhythm is complete."
    ]

    private static let completedTemplates = [
        "Everything planned for today is done, {name}. That's real progress.",
        "Today's effort was loving, steady, and enough.",
        "You showed up for yourself today, {name}. That matters."
    ]

    static func randomMessage(for displayName: String) -> String {
        resolvedMessage(from: gentleTemplates.randomElement() ?? "You're doing amazing today, {name}.", displayName: displayName)
    }

    static func homeMessage(for displayName: String, mealsCompleted: Int, totalMeals: Int) -> String {
        switch mealsCompleted {
        case totalMeals where totalMeals > 0:
            return resolvedMessage(from: completedTemplates.randomElement() ?? "Today's effort was loving, steady, and enough.", displayName: displayName)
        case max(totalMeals - 1, 1):
            return resolvedMessage(from: nearlyDoneTemplates.randomElement() ?? "Only a little more to go today, {name}. Keep it soft and steady.", displayName: displayName)
        default:
            return randomMessage(for: displayName)
        }
    }

    static func notificationBody(for displayName: String) -> String {
        randomMessage(for: displayName)
    }

    private static func resolvedMessage(from template: String, displayName: String) -> String {
        template.replacingOccurrences(of: "{name}", with: displayName)
    }
}
