import Foundation
import SwiftUI

extension Tag {
    /// Create a new tag.
    static func create(
        name: String,
        colorHex: String = "3388DD",
        in context: NSManagedObjectContext
    ) -> Tag {
        let tag = Tag(context: context)
        tag.id = UUID()
        tag.name = name
        tag.colorHex = colorHex
        return tag
    }

    /// Resolved Color from the stored hex value.
    var resolvedColor: Color {
        Color(hex: colorHex ?? "3388DD")
    }

    /// All tags sorted alphabetically.
    static func allTagsFetchRequest() -> NSFetchRequest<Tag> {
        let request = NSFetchRequest<Tag>(entityName: "Tag")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Tag.name, ascending: true)]
        return request
    }
}
