import SwiftUI
import PencilKit

/// Canvas view wrapping PencilKit for handwriting input.
struct NoteCanvasView: View {
    let note: Note
    @StateObject private var pkManager = PencilKitManager()
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedTool: PKToolType = .pen
    @State private var strokeWidth: CGFloat = 3
    @State private var strokeColor: Color = .white
    @State private var isToolPickerVisible = false

    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            canvasToolbar

            // Canvas
            PencilKitCanvas(
                canvasView: $pkManager.canvasView,
                toolType: $selectedTool,
                strokeColor: $strokeColor,
                strokeWidth: $strokeWidth
            )
            .cornerRadius(12)
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(LCARSColors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(LCARSColors.systemBlue.opacity(0.3), lineWidth: 1)
                    )
            )
            .padding(10)

            // Status bar
            canvasStatusBar
        }
        .background(LCARSColors.background)
        .onAppear {
            pkManager.loadDrawing(from: note.drawingData)
        }
        .onChange(of: pkManager.drawingData) { _, newData in
            note.drawingData = newData
            note.modifiedAt = Date()
            try? viewContext.save()
        }
    }

    // MARK: - Toolbar

    private var canvasToolbar: some View {
        HStack(spacing: 12) {
            // Tool selector
            ForEach(canvasTools, id: \.type) { tool in
                toolButton(tool)
            }

            Divider()
                .frame(height: 24)
                .background(LCARSColors.filament)

            // Color picker
            ForEach(strokeColors, id: \.self) { color in
                Button {
                    strokeColor = color
                } label: {
                    Circle()
                        .fill(color)
                        .frame(width: 22, height: 22)
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    strokeColor == color ? Color.white : Color.clear,
                                    lineWidth: 2
                                )
                        )
                }
                .buttonStyle(.plain)
            }

            Divider()
                .frame(height: 24)
                .background(LCARSColors.filament)

            // Stroke width
            HStack(spacing: 4) {
                Circle()
                    .fill(LCARSColors.textSecondary)
                    .frame(width: 6, height: 6)
                Slider(value: $strokeWidth, in: 1...12)
                    .frame(width: 80)
                    .tint(LCARSColors.commandOrange)
                Circle()
                    .fill(LCARSColors.textSecondary)
                    .frame(width: 14, height: 14)
            }

            Spacer()

            // Undo / Redo
            Button {
                pkManager.undo()
            } label: {
                Image(systemName: "arrow.uturn.backward")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(LCARSColors.systemBlue)
            }
            .buttonStyle(.plain)
            .disabled(!pkManager.canUndo)

            Button {
                pkManager.redo()
            } label: {
                Image(systemName: "arrow.uturn.forward")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(LCARSColors.systemBlue)
            }
            .buttonStyle(.plain)
            .disabled(!pkManager.canRedo)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(LCARSColors.elevatedBackground)
        )
        .padding(.horizontal, 10)
        .padding(.top, 6)
    }

    private struct CanvasTool: Identifiable {
        let type: PKToolType
        let icon: String
        var id: PKToolType { type }
    }

    private var canvasTools: [CanvasTool] { [
        CanvasTool(type: .pen, icon: "pencil.tip"),
        CanvasTool(type: .pencil, icon: "pencil"),
        CanvasTool(type: .marker, icon: "highlighter"),
        CanvasTool(type: .eraser, icon: "eraser"),
    ]}

    private var strokeColors: [Color] {
        [.white, LCARSColors.commandOrange, LCARSColors.dataYellow,
         LCARSColors.systemBlue, LCARSColors.accentTeal, LCARSColors.warningRed]
    }

    private func toolButton(_ tool: CanvasTool) -> some View {
        Button {
            selectedTool = tool.type
        } label: {
            Image(systemName: tool.icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(selectedTool == tool.type ? LCARSColors.commandOrange : LCARSColors.textSecondary)
                .padding(6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(selectedTool == tool.type ? LCARSColors.commandOrange.opacity(0.15) : .clear)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Status Bar

    private var canvasStatusBar: some View {
        HStack {
            Text("TOOL: \(selectedTool.rawValue.uppercased())")
                .font(LCARSTypography.commandLabel)
                .foregroundColor(LCARSColors.accentTeal)
            Spacer()
            Text("LAYER: HANDWRITING")
                .font(LCARSTypography.commandLabel)
                .foregroundColor(LCARSColors.textSecondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .background(LCARSColors.elevatedBackground)
    }
}

// MARK: - PencilKit Canvas Wrapper

struct PencilKitCanvas: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    @Binding var toolType: PKToolType
    @Binding var strokeColor: Color
    @Binding var strokeWidth: CGFloat

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .pencilOnly
        canvasView.tool = tool
        canvasView.backgroundColor = UIColor(red: 0.04, green: 0.04, blue: 0.08, alpha: 1.0)
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        if uiView.tool.hash != tool.hash {
            uiView.tool = tool
        }
    }

    private var tool: PKTool {
        let ink = PKInkingTool. InkType.from(toolType)
        let uiColor = UIColor(strokeColor)
        switch toolType {
        case .pen:
            return PKInkingTool(.pen, color: uiColor, width: strokeWidth)
        case .pencil:
            return PKInkingTool(.pencil, color: uiColor, width: strokeWidth)
        case .marker:
            return PKInkingTool(.marker, color: uiColor, width: strokeWidth * 3)
        case .eraser:
            return PKEraserTool(.vector)
        @unknown default:
            return PKInkingTool(.pen, color: uiColor, width: strokeWidth)
        }
    }
}
