import SwiftUI

/// Segmented, block-based progress bar reminiscent of 90s LCARS loading indicators.
struct LCARSProgressStyle: ProgressViewStyle {
    let segments: Int
    let accent: Color

    init(segments: Int = 8, accent: Color = LCARSColors.accentTeal) {
        self.segments = max(2, segments)
        self.accent = accent
    }

    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geometry in
            let totalWidth = geometry.size.width
            let filledCount = Int(CGFloat(segments) * (configuration.fractionCompleted ?? 0))

            HStack(spacing: 3) {
                ForEach(0..<segments, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(index < filledCount ? accent : accent.opacity(0.15))
                        .frame(width: (totalWidth - CGFloat(segments - 1) * 3) / CGFloat(segments))
                }
            }
        }
        .frame(height: 12)
    }
}

extension ProgressViewStyle where Self == LCARSProgressStyle {
    static func lcars(segments: Int = 8, accent: Color = LCARSColors.accentTeal) -> LCARSProgressStyle {
        LCARSProgressStyle(segments: segments, accent: accent)
    }
}
