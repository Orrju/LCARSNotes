import SwiftUI
import PencilKit

/// Main note editor: toggles between a PencilKit canvas and a text editor.
/// Each note stores both typed text and drawing data.
struct NoteEditorView: View {
    @ObservedObject var note: Note
    @Environment(\.managedObjectContext) private var viewContext
    @State private var editMode: EditMode = .draw
    @State private var bodyText: String = ""
    @State private var noteTitle: String = ""
    @State private var isExporting = false
    @State private var selectedTemplate: NoteTemplate = .blank

    enum EditMode: String, CaseIterable {
        case draw = "DRAW"
        case text = "TEXT"
        case preview = "PREVIEW"
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            noteHeader

            // Mode selector + template picker
            modeAndTemplateBar

            // Content area
            contentArea
        }
        .background(LCARSColors.background)
        .onAppear {
            bodyText = note.bodyText ?? ""
            noteTitle = note.title ?? ""
            selectedTemplate = note.template
        }
        .onChange(of: bodyText) { _, newValue in
            note.bodyText = newValue
            note.modifiedAt = Date()
            try? viewContext.save()
        }
        .onChange(of: noteTitle) { _, newValue in
            note.title = newValue
            note.modifiedAt = Date()
            try? viewContext.save()
        }
        .sheet(isPresented: $isExporting) {
            ExportShareView(note: note)
        }
    }

    // MARK: - Header

    private var noteHeader: some View {
        VStack(spacing: 0) {
            HStack {
                // Title
                TextField("NOTE TITLE", text: $noteTitle)
                    .font(LCARSTypography.header)
                    .foregroundColor(LCARSColors.textPrimary)
                    .textFieldStyle(.plain)

                Spacer()

                // Export button
                Button {
                    isExporting = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 12, weight: .bold))
                        Text("EXPORT")
                            .font(LCARSTypography.commandLabel)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(LCARSColors.systemBlue.opacity(0.15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .strokeBorder(LCARSColors.systemBlue.opacity(0.5), lineWidth: 1)
                            )
                    )
                    .foregroundColor(LCARSColors.systemBlue)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)

            // Metadata
            HStack {
                Text("MODIFIED: \(note.formattedModifiedDate)")
                    .font(LCARSTypography.stardate)
                    .foregroundColor(LCARSColors.textSecondary)
                Spacer()
                if let folder = note.folder {
                    Text(folder.name ?? "")
                        .font(LCARSTypography.caption)
                        .foregroundColor(LCARSColors.accentTeal)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(LCARSColors.accentTeal.opacity(0.15))
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)

            Rectangle()
                .fill(LCARSColors.filament)
                .frame(height: 1.5)
        }
        .background(LCARSColors.elevatedBackground)
    }

    // MARK: - Mode & Template Bar

    private var modeAndTemplateBar: some View {
        HStack(spacing: 16) {
            // Mode selector
            HStack(spacing: 0) {
                ForEach(EditMode.allCases, id: \.self) { mode in
                    Button {
                        editMode = mode
                    } label: {
                        Text(mode.rawValue)
                            .font(LCARSTypography.commandLabel)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: editMode == mode ? 8 : 0)
                                    .fill(editMode == mode ? LCARSColors.commandOrange : .clear)
                            )
                            .foregroundColor(editMode == mode ? .black : LCARSColors.textSecondary)
                    }
                    .buttonStyle(.plain)

                    if mode != EditMode.allCases.last {
                        Rectangle()
                            .fill(LCARSColors.filament)
                            .frame(width: 1, height: 16)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(LCARSColors.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(LCARSColors.filament, lineWidth: 1)
            )

            Spacer()

            // Template picker (only in draw mode)
            if editMode == .draw {
                TemplatePickerView(selectedTemplate: $selectedTemplate)
                    .onChange(of: selectedTemplate) { _, newTemplate in
                        note.template = newTemplate
                    }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(LCARSColors.background)
    }

    // MARK: - Content

    @ViewBuilder
    private var contentArea: some View {
        switch editMode {
        case .draw:
            NoteCanvasView(note: note)

        case .text:
            TextEditor(text: $bodyText)
                .font(LCARSTypography.body)
                .foregroundColor(LCARSColors.textPrimary)
                .scrollContentBackground(.hidden)
                .background(LCARSColors.cardBackground)
                .cornerRadius(12)
                .padding(10)

        case .preview:
            ScrollView {
                VStack(alignment: .leading) {
                    // Show drawing if available
                    if let drawingData = note.drawingData,
                       let drawing = try? PKDrawing(data: drawingData) {
                        Image(uiImage: drawing.image(from: drawing.bounds, scale: 1.0))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(LCARSColors.systemBlue.opacity(0.3), lineWidth: 1)
                            )
                    }

                    if let body = note.bodyText, !body.isEmpty {
                        Text(body)
                            .font(LCARSTypography.body)
                            .foregroundColor(LCARSColors.textPrimary)
                            .padding(.top, 8)
                    }
                }
                .padding(14)
            }
            .background(LCARSColors.cardBackground)
            .cornerRadius(12)
            .padding(10)
        }
    }
}
