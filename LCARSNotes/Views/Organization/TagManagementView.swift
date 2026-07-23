import SwiftUI

/// Sheet for managing tags: create, rename, delete, and assign colors.
struct TagManagementView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @FetchRequest(fetchRequest: Tag.allTagsFetchRequest(), animation: .default)
    private var tags: FetchedResults<Tag>

    @State private var newTagName = ""
    @State private var newTagColor = LCARSColors.tagColorOptions.first!.color
    @State private var editingTag: Tag?
    @State private var editTagName = ""
    @State private var editTagColorHex = "3388DD"

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Create new tag
                creationPanel

                // Existing tags
                List {
                    ForEach(tags) { tag in
                        HStack(spacing: 12) {
                            Circle()
                                .fill(tag.resolvedColor)
                                .frame(width: 14, height: 14)

                            if editingTag == tag {
                                TextField("Tag name", text: $editTagName)
                                    .font(LCARSTypography.body)
                                    .textFieldStyle(.lcars)
                                    .foregroundColor(LCARSColors.textPrimary)
                                    .onSubmit { finishEditing() }

                                ForEach(LCARSColors.tagColorOptions, id: \.name) { option in
                                    Button {
                                        editTagColorHex = option.color.toHex()
                                    } label: {
                                        Circle()
                                            .fill(option.color)
                                            .frame(width: 20, height: 20)
                                            .overlay(
                                                Circle()
                                                    .strokeBorder(
                                                        editTagColorHex == option.color.toHex()
                                                            ? Color.white : Color.clear,
                                                        lineWidth: 2
                                                    )
                                            )
                                    }
                                    .buttonStyle(.plain)
                                }

                                Button {
                                    finishEditing()
                                } label: {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(LCARSColors.dataYellow)
                                }
                                .buttonStyle(.plain)
                            } else {
                                Text(tag.name ?? "")
                                    .font(LCARSTypography.body)
                                    .foregroundColor(LCARSColors.textPrimary)

                                Spacer()

                                Button {
                                    startEditing(tag)
                                } label: {
                                    Image(systemName: "pencil")
                                        .foregroundColor(LCARSColors.systemBlue)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete(perform: deleteTags)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(LCARSColors.background)
            }
            .background(LCARSColors.background)
            .navigationTitle("MANAGE TAGS")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundColor(LCARSColors.systemBlue)
                }
            }
        }
    }

    // MARK: - Creation Panel

    private var creationPanel: some View {
        HStack(spacing: 10) {
            TextField("New tag name…", text: $newTagName)
                .font(LCARSTypography.body)
                .textFieldStyle(.lcars)
                .foregroundColor(LCARSColors.textPrimary)

            ForEach(LCARSColors.tagColorOptions, id: \.name) { option in
                Button {
                    newTagColor = option.color
                } label: {
                    Circle()
                        .fill(option.color)
                        .frame(width: 22, height: 22)
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    newTagColor.toHex() == option.color.toHex()
                                        ? Color.white : Color.clear,
                                    lineWidth: 2
                                )
                        )
                }
                .buttonStyle(.plain)
            }

            Button {
                commitNewTag()
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(LCARSColors.commandOrange)
            }
            .buttonStyle(.plain)
            .disabled(newTagName.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(12)
        .background(LCARSColors.elevatedBackground)
        .overlay(
            Rectangle()
                .fill(LCARSColors.filament)
                .frame(height: 1),
            alignment: .bottom
        )
    }

    // MARK: - Actions

    private func commitNewTag() {
        let name = newTagName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        _ = Tag.create(name: name, colorHex: newTagColor.toHex(), in: viewContext)
        try? viewContext.save()
        newTagName = ""
    }

    private func startEditing(_ tag: Tag) {
        editingTag = tag
        editTagName = tag.name ?? ""
        editTagColorHex = tag.colorHex ?? "3388DD"
    }

    private func finishEditing() {
        guard let tag = editingTag else { return }
        tag.name = editTagName
        tag.colorHex = editTagColorHex
        try? viewContext.save()
        editingTag = nil
    }

    private func deleteTags(at offsets: IndexSet) {
        for index in offsets {
            let tag = tags[index]
            viewContext.delete(tag)
        }
        try? viewContext.save()
    }
}
