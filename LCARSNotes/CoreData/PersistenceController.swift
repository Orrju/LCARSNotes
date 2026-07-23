import Foundation
import CoreData
import CloudKit

/// Core Data stack configured with CloudKit for eventual sync.
/// The container is initialized as NSPersistentCloudKitContainer;
/// CloudKit syncing is disabled until explicitly enabled in production.
final class PersistenceController: ObservableObject {
    static let shared = PersistenceController()

    let container: NSPersistentCloudKitContainer

    var viewContext: NSManagedObjectContext { container.viewContext }

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "LCARSNotes")

        // CloudKit configuration (disabled by default for local development).
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("No persistent store description found.")
        }

        // Enable CloudKit remote change notifications once ready for sync.
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        // CloudKit container identifier — replace with your own iCloud container.
        let cloudKitOptions = NSPersistentCloudKitContainerOptions(
            containerIdentifier: "iCloud.com.example.LCARSNotes"
        )
        description.cloudKitContainerOptions = nil // Set to cloudKitOptions when sync is desired.

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    // MARK: - Preview Helper

    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let ctx = controller.viewContext

        // Create sample tags
        let tag1 = Tag(context: ctx)
        tag1.id = UUID()
        tag1.name = "Important"
        tag1.colorHex = "FF7B00"

        let tag2 = Tag(context: ctx)
        tag2.id = UUID()
        tag2.name = "Personal"
        tag2.colorHex = "7B68EE"

        // Create sample folders
        let folder1 = Folder(context: ctx)
        folder1.id = UUID()
        folder1.name = "Starfleet Logs"
        folder1.sortIndex = 0

        let folder2 = Folder(context: ctx)
        folder2.id = UUID()
        folder2.name = "Ship Diagnostics"
        folder2.sortIndex = 1

        let subfolder = Folder(context: ctx)
        subfolder.id = UUID()
        subfolder.name = "Warp Core"
        subfolder.sortIndex = 0
        subfolder.parent = folder2

        // Sample note
        let note = Note(context: ctx)
        note.id = UUID()
        note.title = "Captain's Log"
        note.bodyText = "Stardate 47988.1. The Enterprise has been assigned to patrol the Neutral Zone. All systems nominal."
        note.createdAt = Date()
        note.modifiedAt = Date()
        note.folder = folder1
        note.addToTags(tag1)

        try? ctx.save()
        return controller
    }()
}
