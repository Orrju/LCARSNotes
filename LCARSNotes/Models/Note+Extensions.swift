import Foundation
import CoreData

extension Note {
    /// Create a new note with sensible defaults.
    static func create(
        title: String = "New Note",
        bodyText: String = "",
        in context: NSManagedObjectContext,
        folder: Folder? = nil
    ) -> Note {
        let note = Note(context: context)
        note.id = UUID()
        note.title = title
        note.bodyText = bodyText
        note.createdAt = Date()
        note.modifiedAt = Date()
        note.folder = folder
        return note
    }

    /// Returns a formatted date string for display.
    var formattedModifiedDate: String {
        guard let date = modifiedAt else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd · HH:mm"
        return formatter.string(from: date)
    }

    /// The drawing data as a PKDrawing if available.
    var pkDrawing: PKDrawing? {
        get {
            guard let data = drawingData else { return nil }
            return try? PKDrawing(data: data)
        }
        set {
            drawingData = newValue?.dataRepresentation()
        }
    }

    /// The template type stored, for selecting canvas presets.
    var template: NoteTemplate {
        get { NoteTemplate(rawValue: templateType ?? "blank") ?? .blank }
        set { templateType = newValue.rawValue }
    }

    /// Sort descriptor for reverse-chronological order.
    static var defaultSort: NSSortDescriptor {
        NSSortDescriptor(keyPath: \Note.modifiedAt, ascending: false)
    }

    /// Build a fetch request filtered by the given search text.
    static func searchPredicate(text: String) -> NSPredicate {
        let words = text.trimmingCharacters(in: .whitespaces).components(separatedBy: " ")
        let subpredicates = words
            .filter { !$0.isEmpty }
            .map { word in
                NSCompoundPredicate(orPredicateWithSubpredicates: [
                    NSPredicate(format: "title CONTAINS[cd] %@", word),
                    NSPredicate(format: "bodyText CONTAINS[cd] %@", word),
                ])
            }
        return NSCompoundPredicate(andPredicateWithSubpredicates: subpredicates)
    }
}
