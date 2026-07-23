import SwiftUI

/// Blocky, beveled button style for the LCARS aesthetic.
struct LCARSButtonStyle: ButtonStyle {
    enum Variant {
        case primary    // Command Orange
        case secondary  // System Blue
        case warning    // Warning Red
        case yellow     // Data Yellow
        case subtle     // Low-emphasis background
    }

    let variant: Variant

    private var backgroundColor: Color {
        switch variant {
        case .primary:   return LCARSColors.commandOrange
        case .secondary: return LCARSColors.systemBlue
        case .warning:   return LCARSColors.warningRed
        case .yellow:    return LCARSColors.dataYellow
        case .subtle:    return LCARSColors.cardBackground
        }
    }

    private var foregroundColor: Color {
        switch variant {
        case .yellow: return .black
        case .subtle: return LCARSColors.textPrimary
        default:      return .white
        }
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(LCARSTypography.commandLabel)
            .foregroundColor(foregroundColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
                    .overlay(
                        // Inner highlight (bevel effect)
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [.white.opacity(0.3), .clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: backgroundColor.opacity(configuration.isPressed ? 0.2 : 0.4), radius: 4, y: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Convenience

extension ButtonStyle where Self == LCARSButtonStyle {
    static func lcars(_ variant: LCARSButtonStyle.Variant) -> LCARSButtonStyle {
        LCARSButtonStyle(variant: variant)
    }
}
