import SwiftUI

/// Note template types for the PencilKit canvas background.
enum NoteTemplate: String, CaseIterable, Identifiable {
    case blank = "blank"
    case lined = "lined"
    case grid = "grid"
    case dotGrid = "dotgrid"
    case storyboard = "storyboard"
    case cornell = "cornell"
    case music = "music"
    case isometric = "isometric"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .blank:      return "Blank"
        case .lined:      return "Lined"
        case .grid:       return "Grid"
        case .dotGrid:    return "Dot Grid"
        case .storyboard: return "Storyboard"
        case .cornell:    return "Cornell"
        case .music:      return "Music"
        case .isometric:  return "Isometric"
        }
    }

    var icon: String {
        switch self {
        case .blank:      return "rectangle"
        case .lined:      return "text.alignleft"
        case .grid:       return "grid"
        case .dotGrid:    return "circle.grid.3x3"
        case .storyboard: return "rectangle.split.3x1"
        case .cornell:    return "rectangle.split.2x1"
        case .music:      return "music.note"
        case .isometric:  return "skew"
        }
    }
}

/// Button group for selecting a canvas template.
struct TemplatePickerView: View {
    @Binding var selectedTemplate: NoteTemplate

    var body: some View {
        Menu {
            ForEach(NoteTemplate.allCases) { template in
                Button {
                    selectedTemplate = template
                } label: {
                    HStack {
                        Label(template.label, systemImage: template.icon)
                        if template == selectedTemplate {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: selectedTemplate.icon)
                    .font(.system(size: 12, weight: .bold))
                Text(selectedTemplate.label.uppercased())
                    .font(LCARSTypography.commandLabel)
                Image(systemName: "chevron.down")
                    .font(.system(size: 9, weight: .bold))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(LCARSColors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(LCARSColors.accentTeal.opacity(0.4), lineWidth: 1)
                    )
            )
            .foregroundColor(LCARSColors.accentTeal)
        }
    }
}
