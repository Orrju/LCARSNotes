import SwiftUI

/// List of notes within a selected folder.
struct NoteListView: View {
    @ObservedObject var folder: Folder
    @Binding var selectedNote: Note?
    @Environment(\.managedObjectContext) private var viewContext

    @State private var isAddingNote = false

    var body: some View {
        List(selection: $selectedNote) {
            ForEach(folder.sortedNotes) { note in
                NoteRowView(note: note)
            }
            .onDelete(perform: deleteNotes)

            if isAddingNote {
                HStack {
                    Image(systemName: "doc.badge.plus")
                        .foregroundColor(LCARSColors.dataYellow)
                    TextField("Note title", text: .constant("New Note"))
                        .font(LCARSTypography.body)
                        .onSubmit {
                            createNote()
                        }

                    Button { isAddingNote = false } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(LCARSColors.textSecondary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(LCARSColors.background)
        .navigationTitle(folder.name ?? "Notes")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    createNote()
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(LCARSColors.commandOrange)
                        .font(.system(size: 16, weight: .bold))
                }
            }
        }
    }

    private func createNote() {
        let note = Note.create(in: viewContext, folder: folder)
        try? viewContext.save()
        selectedNote = note
        isAddingNote = false
    }

    private func deleteNotes(at offsets: IndexSet) {
        for index in offsets {
            let note = folder.sortedNotes[index]
            viewContext.delete(note)
        }
        try? viewContext.save()
    }
}

// MARK: - Note Row

struct NoteRowView: View {
    @ObservedObject var note: Note

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(note.title ?? "Untitled")
                    .font(LCARSTypography.subheader)
                    .foregroundColor(LCARSColors.textPrimary)
                    .lineLimit(1)

                Spacer()

                // Template badge
                if note.template != .blank {
                    Image(systemName: note.template.icon)
                        .font(.system(size: 10))
                        .foregroundColor(LCARSColors.accentTeal)
                }

                // Has-drawing indicator
                if note.drawingData != nil {
                    Image(systemName: "pencil.line")
                        .font(.system(size: 10))
                        .foregroundColor(LCARSColors.dataYellow)
                }
            }

            HStack(spacing: 8) {
                Text(note.formattedModifiedDate)
                    .font(LCARSTypography.stardate)
                    .foregroundColor(LCARSColors.textSecondary)

                if let tags = note.tags as? Set<Tag>, !tags.isEmpty {
                    ForEach(Array(tags).sorted(by: { ($0.name ?? "") < ($1.name ?? "") })) { tag in
                        TagChipView(tag: tag, compact: true)
                    }
                }
            }

            if let body = note.bodyText, !body.isEmpty {
                Text(body)
                    .font(LCARSTypography.caption)
                    .foregroundColor(LCARSColors.textSecondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(LCARSColors.cardBackground.opacity(0.5))
        )
    }
}
