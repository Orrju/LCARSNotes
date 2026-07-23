import SwiftUI

/// Compact tag chip displayed in note rows and detail views.
struct TagChipView: View {
    @ObservedObject var tag: Tag
    var compact: Bool = false

    var body: some View {
        Text(tag.name ?? "")
            .font(.system(size: compact ? 9 : 11, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, compact ? 6 : 10)
            .padding(.vertical, compact ? 2 : 4)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(tag.resolvedColor.opacity(0.8))
            )
    }
}

// MARK: - Color → Hex Helper

extension Color {
    func toHex() -> String {
        guard let components = UIColor(self).cgColor.components else { return "3388DD" }
        let r = Int((components[0] * 255).rounded())
        let g = Int((components[1] * 255).rounded())
        let b = Int((components[2] * 255).rounded())
        return String(format: "%02X%02X%02X", r, g, b)
    }
}
