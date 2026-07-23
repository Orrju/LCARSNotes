import SwiftUI

// MARK: - Rounded Container

struct LCARSContainer: ViewModifier {
    let color: Color
    let cornerRadius: CGFloat

    init(color: Color = LCARSColors.cardBackground, cornerRadius: CGFloat = 14) {
        self.color = color
        self.cornerRadius = cornerRadius
    }

    func body(content: Content) -> some View {
        content
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(color)
            )
    }
}

// MARK: - Filament Connector

struct FilamentModifier: ViewModifier {
    let color: Color
    let width: CGFloat

    init(color: Color = LCARSColors.filament, width: CGFloat = 1.5) {
        self.color = color
        self.width = width
    }

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .topLeading) {
                Rectangle()
                    .fill(color)
                    .frame(width: width, height: 12)
                    .offset(x: -6, y: -12)
            }
            .overlay(alignment: .topTrailing) {
                Rectangle()
                    .fill(color)
                    .frame(width: width, height: 12)
                    .offset(x: 6, y: -12)
            }
    }
}

// MARK: - Block Accent Border

struct LCARSBlockBorder: ViewModifier {
    let accent: Color
    let side: Edge.Set

    init(accent: Color = LCARSColors.commandOrange, side: Edge.Set = .leading) {
        self.accent = accent
        self.side = side
    }

    func body(content: Content) -> some View {
        content
            .overlay(
                Rectangle()
                    .fill(accent)
                    .frame(width: side == .leading || side == .trailing ? 3 : nil,
                           height: side == .top || side == .bottom ? 3 : nil)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: {
                        switch side {
                        case .leading:  return .leading
                        case .trailing: return .trailing
                        case .top:      return .top
                        case .bottom:   return .bottom
                        default:        return .leading
                        }
                    }()),
                alignment: {
                    switch side {
                    case .leading:  return .leading
                    case .trailing: return .trailing
                    case .top:      return .top
                    case .bottom:   return .bottom
                    default:        return .leading
                    }
                }()
            )
    }
}

// MARK: - Convenience Extensions

extension View {
    func lcarsContainer(color: Color = LCARSColors.cardBackground, cornerRadius: CGFloat = 14) -> some View {
        modifier(LCARSContainer(color: color, cornerRadius: cornerRadius))
    }

    func lcarsFilament(color: Color = LCARSColors.filament, width: CGFloat = 1.5) -> some View {
        modifier(FilamentModifier(color: color, width: width))
    }

    func lcarsBlockBorder(accent: Color = LCARSColors.commandOrange, side: Edge.Set = .leading) -> some View {
        modifier(LCARSBlockBorder(accent: accent, side: side))
    }
}
