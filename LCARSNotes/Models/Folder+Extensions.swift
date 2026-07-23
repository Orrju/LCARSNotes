import Foundation
import CoreData

extension Folder {
    /// Create a new folder with sensible defaults.
    static func create(
        name: String = "New Folder",
        in context: NSManagedObjectContext,
        parent: Folder? = nil
    ) -> Folder {
        let folder = Folder(context: context)
        folder.id = UUID()
        folder.name = name
        folder.parent = parent
        folder.sortIndex = Int64((parent?.children?.count ?? 0))
        return folder
    }

    /// Fetch all root-level folders (those without a parent).
    static func rootFoldersFetchRequest() -> NSFetchRequest<Folder> {
        let request = NSFetchRequest<Folder>(entityName: "Folder")
        request.predicate = NSPredicate(format: "parent == nil")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Folder.sortIndex, ascending: true)]
        return request
    }

    /// Sorted children of this folder.
    var sortedChildren: [Folder] {
        let set = children as? Set<Folder> ?? []
        return set.sorted { $0.sortIndex < $1.sortIndex }
    }

    /// Sorted notes within this folder.
    var sortedNotes: [Note] {
        let set = notes as? Set<Note> ?? []
        return set.sorted { ($0.modifiedAt ?? .distantPast) > ($1.modifiedAt ?? .distantPast) }
    }
}
