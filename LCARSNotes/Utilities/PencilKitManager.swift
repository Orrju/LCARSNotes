import Foundation
import PencilKit
import Combine

/// Manages the PencilKit canvas state, providing undo/redo and data access.
final class PencilKitManager: ObservableObject {
    @Published var canvasView = PKCanvasView()
    @Published var canUndo = false
    @Published var canRedo = false

    private var cancellables = Set<AnyCancellable>()
    private var observer: NSKeyValueObservation?

    var drawingData: Data? {
        canvasView.drawing.dataRepresentation()
    }

    init() {
        // Observe undo manager changes
        observer = canvasView.undoManager?.observe(\.canUndo, options: [.initial, .new]) { [weak self] mgr, _ in
            DispatchQueue.main.async {
                self?.canUndo = mgr.canUndo
            }
        }

        // Observe redo
        observer = canvasView.undoManager?.observe(\.canRedo, options: [.initial, .new]) { [weak self] mgr, _ in
            DispatchQueue.main.async {
                self?.canRedo = mgr.canRedo
            }
        }
    }

    /// Load an existing drawing into the canvas.
    func loadDrawing(from data: Data?) {
        guard let data = data, let drawing = try? PKDrawing(data: data) else { return }
        canvasView.drawing = drawing
    }

    /// Clear the canvas.
    func clear() {
        canvasView.drawing = PKDrawing()
    }

    func undo() {
        canvasView.undoManager?.undo()
    }

    func redo() {
        canvasView.undoManager?.redo()
    }
}
