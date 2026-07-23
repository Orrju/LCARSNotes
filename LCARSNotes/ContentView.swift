import SwiftUI

struct ContentView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedFolder: Folder?
    @State private var selectedNote: Note?
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @State private var searchText = ""
    @State private var isSearching = false

    var body: some View {
        VStack(spacing: 0) {
            CommandBarView(
                searchText: $searchText,
                isSearching: $isSearching,
                selectedNote: $selectedNote,
                columnVisibility: $columnVisibility
            )
            Divider()
                .frame(height: 2)
                .background(LCARSColors.systemBlue.opacity(0.6))

            NavigationSplitView(columnVisibility: $columnVisibility) {
                SidebarView(
                    selectedFolder: $selectedFolder,
                    selectedNote: $selectedNote,
                    isSearching: $isSearching,
                    searchText: $searchText
                )
            } content: {
                if isSearching {
                    SearchView(searchText: $searchText, selectedNote: $selectedNote)
                } else if let folder = selectedFolder {
                    NoteListView(folder: folder, selectedNote: $selectedNote)
                } else {
                    AllNotesView(selectedNote: $selectedNote)
                }
            } detail: {
                if let note = selectedNote {
                    NoteEditorView(note: note)
                } else {
                    LCARSEmptyStateView()
                }
            }
            .navigationSplitViewStyle(.balanced)
            .background(LCARSColors.background)
        }
        .background(LCARSColors.background)
    }
}

// MARK: - Empty State

struct LCARSEmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "rectangle.and.pencil.and.ellipsis")
                .font(.system(size: 48))
                .foregroundColor(LCARSColors.systemBlue)
            Text("SELECT A NOTE")
                .font(LCARSTypography.header)
                .foregroundColor(LCARSColors.textSecondary)
            Text("Choose a note from the list or tap + to create one.")
                .font(LCARSTypography.body)
                .foregroundColor(LCARSColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(LCARSColors.background)
    }
}

// MARK: - All Notes Fallback

struct AllNotesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [SortDescriptor(\Note.modifiedAt, order: .reverse)],
        animation: .default
    ) private var notes: FetchedResults<Note>
    @Binding var selectedNote: Note?

    var body: some View {
        List(selection: $selectedNote) {
            ForEach(notes) { note in
                NoteRowView(note: note)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(LCARSColors.background)
        .navigationTitle("All Notes")
    }
}
