import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

enum Theme {
    enum Palette {
        static let blush = Color(uiColor: .bubu(light: "F2D9DC", dark: "51313B"))
        static let peach = Color(uiColor: .bubu(light: "EED4C8", dark: "624941"))
        static let cream = Color(uiColor: .bubu(light: "FBF6F2", dark: "140F12"))
        static let beige = Color(uiColor: .bubu(light: "EDE2D8", dark: "362D33"))
        static let rose = Color(uiColor: .bubu(light: "A35B6D", dark: "F0B7C1"))
        static let roseDeep = Color(uiColor: .bubu(light: "7E4152", dark: "FFD3DB"))
        static let cocoa = Color(uiColor: .bubu(light: "2F242B", dark: "F7F0EE"))
        static let mist = Color(uiColor: .bubu(light: "685961", dark: "D2C3C8"))
        static let sage = Color(uiColor: .bubu(light: "89A192", dark: "A8C5B1"))
        static let background = Color(uiColor: .bubu(light: "FBF6F2", dark: "140F12"))
        static let backgroundSecondary = Color(uiColor: .bubu(light: "F3EBE4", dark: "1B1518"))
        static let surface = Color(uiColor: .bubu(light: "FFFDFC", dark: "211B1F"))
        static let surfaceRaised = Color(uiColor: .bubu(light: "F7EEE8", dark: "2B2328"))
        static let border = Color(uiColor: .bubu(light: "E7D8CF", dark: "44373E"))
        static let shadow = Color.black.opacity(0.12)
        static let positive = Color(uiColor: .bubu(light: "567B67", dark: "A8CCB4"))
        static let warning = Color(uiColor: .bubu(light: "A66A5D", dark: "F2B29C"))
        static let onAccent = Color.white.opacity(0.96)
    }

    enum Typography {
        static let hero = Font.system(.largeTitle, design: .serif).weight(.semibold)
        static let largeTitle = Font.system(.title, design: .serif).weight(.semibold)
        static let section = Font.system(.title3, design: .serif).weight(.semibold)
        static let headline = Font.system(.headline, design: .rounded).weight(.semibold)
        static let body = Font.system(.body, design: .rounded)
        static let bodyStrong = Font.system(.body, design: .rounded).weight(.semibold)
        static let footnote = Font.system(.footnote, design: .rounded)
        static let caption = Font.system(.caption, design: .rounded).weight(.medium)
        static let stat = Font.system(size: 30, weight: .semibold, design: .serif)
    }

    enum Spacing {
        static let xxxs: CGFloat = 4
        static let xxs: CGFloat = 8
        static let xs: CGFloat = 12
        static let sm: CGFloat = 16
        static let md: CGFloat = 20
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }

    enum Radius {
        static let small: CGFloat = 16
        static let medium: CGFloat = 20
        static let large: CGFloat = 28
        static let hero: CGFloat = 34
        static let capsule: CGFloat = 999
    }

    enum Shadow {
        static let cardRadius: CGFloat = 20
        static let cardY: CGFloat = 10
        static let buttonRadius: CGFloat = 14
        static let buttonY: CGFloat = 8
    }

    enum Gradients {
        static let hero = LinearGradient(
            colors: [
                Palette.background,
                Palette.peach.opacity(0.92),
                Palette.blush.opacity(0.88)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let accent = LinearGradient(
            colors: [
                Palette.rose,
                Palette.roseDeep
            ],
            startPoint: .leading,
            endPoint: .trailing
        )

        static let ring = AngularGradient(
            colors: [
                Palette.roseDeep,
                Palette.rose,
                Palette.peach,
                Palette.roseDeep
            ],
            center: .center
        )

        static let screen = LinearGradient(
            colors: [
                Palette.background,
                Palette.backgroundSecondary,
                Palette.blush.opacity(0.35)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static let blush = Palette.blush
    static let peach = Palette.peach
    static let cream = Palette.cream
    static let beige = Palette.beige
    static let rose = Palette.rose
    static let cocoa = Palette.cocoa
    static let mint = Palette.sage
    static let heroGradient = Gradients.hero

    #if canImport(UIKit)
    private static var appearanceConfigured = false

    static func configureSystemAppearance() {
        guard !appearanceConfigured else { return }
        appearanceConfigured = true

        let navigationAppearance = UINavigationBarAppearance()
        navigationAppearance.configureWithTransparentBackground()
        navigationAppearance.backgroundColor = UIColor.bubu(light: "FBF6F2", dark: "140F12").withAlphaComponent(0.92)
        navigationAppearance.shadowColor = UIColor.bubu(light: "E7D8CF", dark: "44373E").withAlphaComponent(0.35)
        navigationAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.bubu(light: "2F242B", dark: "F7F0EE"),
            .font: UIFont.systemFont(ofSize: 19, weight: .semibold)
        ]
        navigationAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.bubu(light: "2F242B", dark: "F7F0EE"),
            .font: UIFont.systemFont(ofSize: 33, weight: .semibold)
        ]

        UINavigationBar.appearance().standardAppearance = navigationAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationAppearance
        UINavigationBar.appearance().compactAppearance = navigationAppearance
        UINavigationBar.appearance().tintColor = UIColor.bubu(light: "A35B6D", dark: "F0B7C1")
        UINavigationBar.appearance().prefersLargeTitles = true

        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithTransparentBackground()
        tabAppearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        tabAppearance.backgroundColor = UIColor.bubu(light: "FFFDFC", dark: "211B1F").withAlphaComponent(0.92)
        tabAppearance.shadowColor = UIColor.bubu(light: "E7D8CF", dark: "44373E").withAlphaComponent(0.35)

        let normalColor = UIColor.bubu(light: "8D7B83", dark: "B29EA6")
        let selectedColor = UIColor.bubu(light: "A35B6D", dark: "F0B7C1")
        for layout in [
            tabAppearance.stackedLayoutAppearance,
            tabAppearance.inlineLayoutAppearance,
            tabAppearance.compactInlineLayoutAppearance
        ] {
            layout.normal.iconColor = normalColor
            layout.normal.titleTextAttributes = [.foregroundColor: normalColor]
            layout.selected.iconColor = selectedColor
            layout.selected.titleTextAttributes = [.foregroundColor: selectedColor]
        }

        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
    }
    #endif
}

struct BubuScreenBackground: View {
    var body: some View {
        Theme.Gradients.screen
            .overlay(alignment: .topTrailing) {
                Circle()
                    .fill(Theme.Palette.blush.opacity(0.18))
                    .frame(width: 220, height: 220)
                    .blur(radius: 14)
                    .offset(x: 60, y: -80)
            }
            .overlay(alignment: .bottomLeading) {
                Circle()
                    .fill(Theme.Palette.peach.opacity(0.22))
                    .frame(width: 180, height: 180)
                    .blur(radius: 18)
                    .offset(x: -50, y: 50)
            }
            .ignoresSafeArea()
    }
}

struct BubuCardModifier: ViewModifier {
    var tint: Color = Theme.Palette.surface
    var padding: CGFloat = Theme.Spacing.md

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous)
                    .fill(tint.opacity(0.96))
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.large, style: .continuous)
                    .stroke(Theme.Palette.border.opacity(0.75), lineWidth: 1)
            )
            .shadow(
                color: Theme.Palette.shadow,
                radius: Theme.Shadow.cardRadius,
                x: 0,
                y: Theme.Shadow.cardY
            )
    }
}

struct BubuInputModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(Theme.Typography.body)
            .padding(.horizontal, Theme.Spacing.sm)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                    .fill(Theme.Palette.surfaceRaised)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                    .stroke(Theme.Palette.border, lineWidth: 1)
            )
    }
}

struct BubuPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.Typography.bodyStrong)
            .foregroundStyle(Theme.Palette.onAccent)
            .frame(maxWidth: .infinity, minHeight: 52)
            .padding(.horizontal, Theme.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                    .fill(Theme.Gradients.accent)
            )
            .shadow(
                color: Theme.Palette.rose.opacity(configuration.isPressed ? 0.16 : 0.28),
                radius: Theme.Shadow.buttonRadius,
                x: 0,
                y: Theme.Shadow.buttonY
            )
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(.easeOut(duration: 0.18), value: configuration.isPressed)
    }
}

struct BubuSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.Typography.bodyStrong)
            .foregroundStyle(Theme.Palette.cocoa)
            .frame(maxWidth: .infinity, minHeight: 48)
            .padding(.horizontal, Theme.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                    .fill(Theme.Palette.surfaceRaised.opacity(configuration.isPressed ? 0.85 : 1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                    .stroke(Theme.Palette.border, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.99 : 1)
            .animation(.easeOut(duration: 0.18), value: configuration.isPressed)
    }
}

struct BubuChipButtonStyle: ButtonStyle {
    var isSelected = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.Typography.caption)
            .foregroundStyle(isSelected ? Theme.Palette.onAccent : Theme.Palette.cocoa)
            .padding(.horizontal, Theme.Spacing.sm)
            .padding(.vertical, Theme.Spacing.xs)
            .background(
                Capsule(style: .continuous)
                    .fill(isSelected ? AnyShapeStyle(Theme.Gradients.accent) : AnyShapeStyle(Theme.Palette.surfaceRaised))
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(
                        isSelected ? Theme.Palette.rose.opacity(0.15) : Theme.Palette.border,
                        lineWidth: 1
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct BubuSectionHeader: View {
    let eyebrow: String?
    let title: String
    let subtitle: String?

    init(eyebrow: String? = nil, title: String, subtitle: String? = nil) {
        self.eyebrow = eyebrow
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
            if let eyebrow {
                Text(eyebrow.uppercased())
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Theme.Palette.rose)
                    .tracking(1.2)
            }

            Text(title)
                .font(Theme.Typography.largeTitle)
                .foregroundStyle(Theme.Palette.cocoa)

            if let subtitle {
                Text(subtitle)
                    .font(Theme.Typography.body)
                    .foregroundStyle(Theme.Palette.mist)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct BubuMetricPill: View {
    let title: String
    let value: String
    var icon: String? = nil
    var accent: Color = Theme.Palette.rose

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
            if let icon {
                Label(title, systemImage: icon)
                    .font(Theme.Typography.caption)
                    .foregroundStyle(accent)
                    .labelStyle(.titleAndIcon)
            } else {
                Text(title)
                    .font(Theme.Typography.caption)
                    .foregroundStyle(accent)
            }

            Text(value)
                .font(Theme.Typography.headline)
                .foregroundStyle(Theme.Palette.cocoa)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Theme.Spacing.sm)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                .fill(Theme.Palette.surfaceRaised)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                .stroke(Theme.Palette.border, lineWidth: 1)
        )
    }
}

extension View {
    func bubuCard(tint: Color = Theme.Palette.surface, padding: CGFloat = Theme.Spacing.md) -> some View {
        modifier(BubuCardModifier(tint: tint, padding: padding))
    }

    func bubuField() -> some View {
        modifier(BubuInputModifier())
    }

    func bubuScreenBackground() -> some View {
        background(BubuScreenBackground())
    }
}

#if canImport(UIKit)
private extension UIColor {
    static func bubu(light: String, dark: String) -> UIColor {
        UIColor { traits in
            UIColor(hex: traits.userInterfaceStyle == .dark ? dark : light)
        }
    }

    convenience init(hex: String) {
        let cleaned = hex.replacingOccurrences(of: "#", with: "")
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)
        let r = CGFloat((value >> 16) & 0xFF) / 255
        let g = CGFloat((value >> 8) & 0xFF) / 255
        let b = CGFloat(value & 0xFF) / 255
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}
#endif
