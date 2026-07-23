import Foundation

extension DateFormatter {
    /// LCARS stardate format: yyyy.MM.dd
    static let stardate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter
    }()

    /// LCARS stardate with time: yyyy.MM.dd · HH:mm
    static let stardateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd · HH:mm"
        return formatter
    }()
}
