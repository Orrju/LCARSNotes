import SwiftUI

/// Centralized LCARS color system supporting light and dark modes.
struct LCARSColors {
    // MARK: - Backgrounds

    static var background: Color {
        Color("Background", bundle: .main)
    }

    static var cardBackground: Color {
        Color("CardBackground", bundle: .main)
    }

    static var elevatedBackground: Color {
        Color("ElevatedBackground", bundle: .main)
    }

    // MARK: - LCARS Accent Palette

    /// Primary actions, alerts, and highlights.
    static let commandOrange = Color(hex: "FF7B00")

    /// Highlights, secondary information, and status indicators.
    static let dataYellow = Color(hex: "FFC107")

    /// Navigation, system status, and informational elements.
    static let systemBlue = Color(hex: "3388DD")

    /// Warning Red — reserved for errors, destructive actions, and critical status.
    static let warningRed = Color(hex: "E53935")

    /// Accent purple for tags and tertiary elements.
    static let accentPurple = Color(hex: "7B68EE")

    /// Accent teal for status readouts and progress indicators.
    static let accentTeal = Color(hex: "00BCD4")

    // MARK: - Text

    /// Primary text color, dynamically adapts to color scheme.
    static var textPrimary: Color {
        Color("TextPrimary", bundle: .main)
    }

    /// Secondary / muted text.
    static var textSecondary: Color {
        Color("TextSecondary", bundle: .main)
    }

    // MARK: - Filaments

    /// Thin connector line color.
    static let filament = commandOrange.opacity(0.4)
    static let filamentBlue = systemBlue.opacity(0.4)
    static let filamentYellow = dataYellow.opacity(0.4)

    // MARK: - Semantic Aliases

    static let destructive = warningRed
    static let accent = commandOrange
    static let highlight = dataYellow
    static let navigation = systemBlue

    /// A dynamic gradient representing the full LCARS spectrum.
    static var lcarsGradient: LinearGradient {
        LinearGradient(
            colors: [commandOrange, dataYellow, accentTeal, systemBlue, accentPurple],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Tag Colors

    static let tagColorOptions: [(name: String, color: Color)] = [
        ("Orange", commandOrange),
        ("Yellow", dataYellow),
        ("Blue", systemBlue),
        ("Purple", accentPurple),
        ("Teal", accentTeal),
        ("Red", warningRed),
    ]
}

// MARK: - Hex Initializer

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
