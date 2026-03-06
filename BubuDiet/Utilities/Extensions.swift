import Foundation
import SwiftUI

extension Double {
    var asCurrencyCAD: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "CAD"
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: self)) ?? "CA$0.00"
    }

    var oneDecimalText: String {
        formatted(.number.precision(.fractionLength(1)))
    }
}

extension Int {
    var calorieText: String {
        "\(self) cal"
    }
}

extension Date {
    var dayLabel: String {
        formatted(.dateTime.weekday(.wide))
    }

    var shortDateLabel: String {
        formatted(.dateTime.month(.abbreviated).day())
    }

    var fullDateLabel: String {
        formatted(date: .abbreviated, time: .omitted)
    }

    var timeLabel: String {
        formatted(date: .omitted, time: .shortened)
    }

    var startOfLocalDay: Date {
        Calendar.current.startOfDay(for: self)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.replacingOccurrences(of: "#", with: "")
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6:
            (r, g, b) = (int >> 16, (int >> 8) & 0xff, int & 0xff)
        default:
            (r, g, b) = (255, 255, 255)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1
        )
    }
}
