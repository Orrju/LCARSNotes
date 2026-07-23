import SwiftUI

/// LCARS-themed text field with a dark background, accent border, and monospace hinting.
struct LCARSTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(LCARSTypography.body)
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(LCARSColors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(LCARSColors.systemBlue.opacity(0.5), lineWidth: 1)
                    )
            )
            .foregroundColor(LCARSColors.textPrimary)
    }
}

extension TextFieldStyle where Self == LCARSTextFieldStyle {
    static var lcars: LCARSTextFieldStyle { LCARSTextFieldStyle() }
}
