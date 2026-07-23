import SwiftUI

/// Left sidebar with hierarchical folder tree, tag management, and quick filters.
struct SidebarView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var selectedFolder: Folder?
    @Binding var selectedNote: Note?
    @Binding var isSearching: Bool
    @Binding var searchText: String

    @FetchRequest(fetchRequest: Folder.rootFoldersFetchRequest(), animation: .default)
    private var rootFolders: FetchedResults<Folder>

    @FetchRequest(fetchRequest: Tag.allTagsFetchRequest(), animation: .default)
    private var tags: FetchedResults<Tag>

    @State private var isAddingFolder = false
    @State private var newFolderName = ""
    @State private var isShowingTagManager = false
    @State private var expandedFolders: Set<UUID> = []

    // MARK: - Body

    var body: some View {
        List(selection: $selectedFolder) {
            // Quick-access section
            Section {
                quickAccessRow(label: "ALL NOTES", icon: "note.text", action: {
                    selectedFolder = nil
                    isSearching = false
                })

                quickAccessRow(label: "RECENT", icon: "clock", action: {
                    selectedFolder = nil
                    isSearching = false
                })
            } header: {
                sidebarHeader("QUICK ACCESS")
            }

            // Folder tree
            Section {
                ForEach(rootFolders) { folder in
                    FolderTreeRow(
                        folder: folder,
                        selectedFolder: $selectedFolder,
                        selectedNote: $selectedNote,
                        expandedFolders: $expandedFolders,
                        isSearching: $isSearching,
                        searchText: $searchText
                    )
                }

                // Add folder button
                if isAddingFolder {
                    HStack {
                        Image(systemName: "folder.badge.plus")
                            .foregroundColor(LCARSColors.dataYellow)
                        TextField("Folder name", text: $newFolderName)
                            .font(LCARSTypography.body)
                            .textFieldStyle(.lcars)
                            .foregroundColor(LCARSColors.textPrimary)
                            .onSubmit { commitNewFolder() }

                        Button { isAddingFolder = false; newFolderName = "" } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(LCARSColors.textSecondary)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 4)
                }

                Button {
                    isAddingFolder = true
                    newFolderName = ""
                } label: {
                    Label("New Folder", systemImage: "plus")
                        .font(LCARSTypography.body)
                        .foregroundColor(LCARSColors.systemBlue)
                }
                .buttonStyle(.plain)
            } header: {
                sidebarHeader("FOLDERS")
            }

            // Tags
            Section {
                ForEach(tags) { tag in
                    tagRow(tag)
                }

                Button {
                    isShowingTagManager = true
                } label: {
                    Label("Manage Tags", systemImage: "tag")
                        .font(LCARSTypography.body)
                        .foregroundColor(LCARSColors.accentPurple)
                }
                .buttonStyle(.plain)
            } header: {
                sidebarHeader("TAGS")
            }
            .sheet(isPresented: $isShowingTagManager) {
                TagManagementView()
            }
        }
        .listStyle(.sidebar)
        .scrollContentBackground(.hidden)
        .background(LCARSColors.background)
        .toolbar(.hidden)
        .navigationTitle("")
    }

    // MARK: - Subviews

    private func sidebarHeader(_ text: String) -> some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(LCARSColors.commandOrange)
                .frame(width: 4)
            Text(text)
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(LCARSColors.textSecondary)
                .padding(.leading, 6)
        }
        .padding(.bottom, 4)
    }

    private func quickAccessRow(label: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(LCARSColors.systemBlue)
                    .frame(width: 20)
                Text(label)
                    .font(LCARSTypography.sidebar)
                    .foregroundColor(LCARSColors.textPrimary)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }

    private func tagRow(_ tag: FetchedResults<Tag>.Element) -> some View {
        Button {
            selectedFolder = nil
            isSearching = true
            searchText = ""
        } label: {
            HStack(spacing: 8) {
                Circle()
                    .fill(tag.resolvedColor)
                    .frame(width: 10, height: 10)
                Text(tag.name ?? "")
                    .font(LCARSTypography.sidebar)
                    .foregroundColor(LCARSColors.textPrimary)
                Spacer()
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Actions

    private func commitNewFolder() {
        guard !newFolderName.trimmingCharacters(in: .whitespaces).isEmpty else {
            isAddingFolder = false
            return
        }
        _ = Folder.create(name: newFolderName, in: viewContext)
        try? viewContext.save()
        isAddingFolder = false
        newFolderName = ""
    }
}

// MARK: - Folder Tree Row

struct FolderTreeRow: View {
    @ObservedObject var folder: Folder
    @Binding var selectedFolder: Folder?
    @Binding var selectedNote: Note?
    @Binding var expandedFolders: Set<UUID>
    @Binding var isSearching: Bool
    @Binding var searchText: String

    @Environment(\.managedObjectContext) private var viewContext
    @State private var isRenaming = false
    @State private var renameText = ""

    private var isExpanded: Bool {
        expandedFolders.contains(folder.id ?? UUID())
    }

    var body: some View {
        DisclosureGroup(isExpanded: Binding(
            get: { isExpanded },
            set: { toggle($0) }
        )) {
            ForEach(folder.sortedChildren) { child in
                FolderTreeRow(
                    folder: child,
                    selectedFolder: $selectedFolder,
                    selectedNote: $selectedNote,
                    expandedFolders: $expandedFolders,
                    isSearching: $isSearching,
                    searchText: $searchText
                )
                .padding(.leading, 12)
            }
        } label: {
            folderLabel
        }
        .contextMenu {
            Button {
                isRenaming = true
                renameText = folder.name ?? ""
            } label: {
                Label("Rename", systemImage: "pencil")
            }

            Button(role: .destructive) {
                viewContext.delete(folder)
                try? viewContext.save()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .alert("Rename Folder", isPresented: $isRenaming) {
            TextField("Name", text: $renameText)
            Button("Cancel", role: .cancel) {}
            Button("OK") {
                folder.name = renameText
                try? viewContext.save()
            }
        }
    }

    private var folderLabel: some View {
        Button {
            selectedFolder = folder
            isSearching = false
            searchText = ""
        } label: {
            HStack(spacing: 8) {
                Image(systemName: isExpanded ? "folder.fill" : "folder")
                    .foregroundColor(LCARSColors.dataYellow)
                    .frame(width: 20)
                Text(folder.name ?? "Untitled")
                    .font(LCARSTypography.sidebar)
                    .foregroundColor(LCARSColors.textPrimary)
                Spacer()
                Text("\(folder.notes?.count ?? 0)")
                    .font(LCARSTypography.caption)
                    .foregroundColor(LCARSColors.textSecondary)
            }
            .padding(.vertical, 3)
        }
        .buttonStyle(.plain)
    }

    private func toggle(_ expand: Bool) {
        guard let id = folder.id else { return }
        if expand {
            expandedFolders.insert(id)
        } else {
            expandedFolders.remove(id)
        }
    }
}
