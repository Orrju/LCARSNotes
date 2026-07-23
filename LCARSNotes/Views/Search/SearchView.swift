import SwiftUI

/// Full-text search view across note titles and body text.
struct SearchView: View {
    @Binding var searchText: String
    @Binding var selectedNote: Note?
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest private var results: FetchedResults<Note>

    init(searchText: Binding<String>, selectedNote: Binding<Note?>) {
        _searchText = searchText
        _selectedNote = selectedNote

        let predicate: NSPredicate
        let trimmed = searchText.wrappedValue.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            predicate = NSPredicate(value: false)
        } else {
            predicate = Note.searchPredicate(text: trimmed)
        }

        _results = FetchRequest(
            sortDescriptors: [SortDescriptor(\Note.modifiedAt, order: .reverse)],
            predicate: predicate,
            animation: .default
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            // Search stats
            HStack {
                Text("\(results.count) RESULT\(results.count == 1 ? "" : "S")")
                    .font(LCARSTypography.commandLabel)
                    .foregroundColor(LCARSColors.accentTeal)
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(LCARSColors.elevatedBackground)

            if results.isEmpty && !searchText.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 32))
                        .foregroundColor(LCARSColors.textSecondary)
                    Text("NO RESULTS FOR \"\(searchText)\"")
                        .font(LCARSTypography.subheader)
                        .foregroundColor(LCARSColors.textSecondary)
                    Text("Try a different query or check your spelling.")
                        .font(LCARSTypography.body)
                        .foregroundColor(LCARSColors.textSecondary)
                }
                .frame(maxHeight: .infinity)
            } else {
                List(selection: $selectedNote) {
                    ForEach(results) { note in
                        searchResultRow(note)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(LCARSColors.background)
            }
        }
        .background(LCARSColors.background)
        .navigationTitle("Search")
    }

    private func searchResultRow(_ note: FetchedResults<Note>.Element) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(note.title ?? "Untitled")
                .font(LCARSTypography.subheader)
                .foregroundColor(LCARSColors.textPrimary)

            if let body = note.bodyText, !body.isEmpty {
                Text(highlightedText(body))
                    .font(LCARSTypography.caption)
                    .foregroundColor(LCARSColors.textSecondary)
                    .lineLimit(3)
            }

            HStack {
                Text(note.formattedModifiedDate)
                    .font(LCARSTypography.stardate)
                    .foregroundColor(LCARSColors.textSecondary)

                if let folder = note.folder {
                    Text(folder.name ?? "")
                        .font(LCARSTypography.caption)
                        .foregroundColor(LCARSColors.accentTeal)
                }

                Spacer()
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(LCARSColors.cardBackground.opacity(0.5))
        )
    }

    /// Wrap search matches with accent-colored attributes (simplified — highlights the raw text).
    private func highlightedText(_ text: String) -> AttributedString {
        var attributed = AttributedString(text)
        let trimmed = searchText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return attributed }

        let lowercased = text.lowercased()
        let query = trimmed.lowercased()

        var range = lowercased.startIndex..<lowercased.endIndex
        while let matchRange = lowercased.range(of: query, options: .caseInsensitive, range: range) {
            if let attrRange = AttributedString.Index(matchRange.lowerBound, within: attributed),
               let attrEnd = AttributedString.Index(matchRange.upperBound, within: attributed) {
                attributed[attrRange..<attrEnd].foregroundColor = LCARSColors.dataYellow
                attributed[attrRange..<attrEnd].font = .system(.caption, design: .default).weight(.bold)
            }
            range = matchRange.upperBound..<lowercased.endIndex
        }

        return attributed
    }
}
