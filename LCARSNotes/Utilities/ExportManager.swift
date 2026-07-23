import Foundation
import SwiftUI
import PencilKit

/// Manages exporting notes as PDF or image, and invoking the share sheet.
struct ExportManager {
    /// Generate a PDF file URL for the note.
    static func exportAsPDF(note: Note) -> URL? {
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792))
        let data = renderer.pdfData { context in
            context.beginPage()

            // Title
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24, weight: .bold),
                .foregroundColor: UIColor.black,
            ]
            let titleStr = note.title ?? "Untitled"
            titleStr.draw(at: CGPoint(x: 40, y: 40), withAttributes: titleAttributes)

            // Date
            let dateAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.monospacedSystemFont(ofSize: 10, weight: .regular),
                .foregroundColor: UIColor.gray,
            ]
            let dateStr = "Stardate \(note.formattedModifiedDate)"
            dateStr.draw(at: CGPoint(x: 40, y: 72), withAttributes: dateAttributes)

            // Drawing
            if let drawingData = note.drawingData,
               let drawing = try? PKDrawing(data: drawingData) {
                let image = drawing.image(from: drawing.bounds, scale: 1.0)
                let drawingRect = CGRect(x: 40, y: 100, width: 532, height: 350)
                image.draw(in: drawingRect)
            }

            // Body text
            if let body = note.bodyText, !body.isEmpty {
                let bodyAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 12),
                    .foregroundColor: UIColor.black,
                ]
                let bodyRect = CGRect(x: 40, y: 480, width: 532, height: 280)
                (body as NSString).draw(in: bodyRect, withAttributes: bodyAttributes)
            }
        }

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(note.title ?? "note").pdf")
        try? data.write(to: url)
        return url
    }

    /// Generate a PNG image of the drawing layer.
    static func exportAsImage(note: Note) -> URL? {
        guard let drawingData = note.drawingData,
              let drawing = try? PKDrawing(data: drawingData) else { return nil }

        let image = drawing.image(from: drawing.bounds, scale: 2.0)
        guard let pngData = image.pngData() else { return nil }

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(note.title ?? "note").png")
        try? pngData.write(to: url)
        return url
    }
}

// MARK: - Share Sheet View

/// SwiftUI wrapper for UIActivityViewController (share sheet).
struct ExportShareView: UIViewControllerRepresentable {
    let note: Note

    func makeUIViewController(context: Context) -> UIActivityViewController {
        var items: [Any] = []

        // Export the drawing as PNG
        if let imageURL = ExportManager.exportAsImage(note: note) {
            items.append(imageURL)
        }

        // Export as PDF
        if let pdfURL = ExportManager.exportAsPDF(note: note) {
            items.append(pdfURL)
        }

        // Fallback: plain text
        if items.isEmpty {
            items.append(note.title ?? "LCARS Note")
        }

        return UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
