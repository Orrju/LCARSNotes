import SwiftUI

/// Typography system for the LCARS design language.
/// Uses San Francisco (the system font family) for readability
/// with bold, blocky headers and monospaced data readouts.
struct LCARSTypography {
    /// Large header — typically used for module titles.
    static var header: Font {
        .system(.title2, design: .default).weight(.bold)
    }

    /// Small header for sub-sections.
    static var subheader: Font {
        .system(.headline, design: .default).weight(.semibold)
    }

    /// Command bar label.
    static var commandLabel: Font {
        .system(.caption, design: .default).weight(.bold)
    }

    /// Body text for long-form reading.
    static var body: Font {
        .system(.body, design: .default)
    }

    /// Caption / metadata text.
    static var caption: Font {
        .system(.caption, design: .default)
    }

    /// Numeric readouts and technical data (monospaced).
    static var data: Font {
        .system(.body, design: .monospaced)
    }

    /// Large numeric display (monospaced).
    static var dataLarge: Font {
        .system(.largeTitle, design: .monospaced).weight(.bold)
    }

    /// Sidebar navigation items.
    static var sidebar: Font {
        .system(.body, design: .default).weight(.medium)
    }

    /// Date display — monospaced for the LCARS "computer" feel.
    static var stardate: Font {
        .system(.caption, design: .monospaced).weight(.medium)
    }
}
