import SwiftUI

/// Top command ribbon providing search, theme toggle, new-note action, and status readout.
struct CommandBarView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var searchText: String
    @Binding var isSearching: Bool
    @Binding var selectedNote: Note?
    @Binding var columnVisibility: NavigationSplitViewVisibility

    @Environment(\.managedObjectContext) private var viewContext
    @State private var currentDate = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(spacing: 0) {
            // Left: LCARS identifier block
            lcarsBadge

            // Center: Search field
            searchArea

            Spacer()

            // Right: Actions
            actionCluster
        }
        .frame(height: 52)
        .background(LCARSColors.elevatedBackground)
        .overlay(
            // Bottom filament
            Rectangle()
                .fill(LCARSColors.commandOrange.opacity(0.6))
                .frame(height: 2),
            alignment: .bottom
        )
        .onReceive(timer) { _ in currentDate = Date() }
    }

    // MARK: - Subviews

    private var lcarsBadge: some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 6)
                .fill(LCARSColors.commandOrange)
                .frame(width: 44, height: 36)
                .overlay(
                    Text("LCARS")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(.black)
                )

            VStack(alignment: .leading, spacing: 1) {
                Text(stardateString)
                    .font(LCARSTypography.stardate)
                    .foregroundColor(LCARSColors.dataYellow)
                Text("STARDATE")
                    .font(.system(size: 7, weight: .bold))
                    .foregroundColor(LCARSColors.textSecondary)
            }
        }
        .padding(.leading, 14)
    }

    private var searchArea: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(LCARSColors.systemBlue)
                .font(.system(size: 14, weight: .bold))

            TextField("SEARCH NOTES…", text: $searchText)
                .font(LCARSTypography.body)
                .foregroundColor(LCARSColors.textPrimary)
                .onTapGesture { isSearching = true }
                .onSubmit { isSearching = !searchText.isEmpty }

            if isSearching {
                Button {
                    isSearching = false
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(LCARSColors.textSecondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(LCARSColors.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(LCARSColors.systemBlue.opacity(0.4), lineWidth: 1)
                )
        )
        .padding(.horizontal, 12)
    }

    private var actionCluster: some View {
        HStack(spacing: 6) {
            // Theme toggle
            Button {
                themeManager.cycle()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: themeIcon)
                        .font(.system(size: 12, weight: .bold))
                    Text(themeManager.selectedMode.rawValue.uppercased())
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

            // New Note
            Button {
                let note = Note.create(in: viewContext, title: "Note \(Date().formatted(date: .omitted, time: .shortened))")
                try? viewContext.save()
                selectedNote = note
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .bold))
                    Text("NEW NOTE")
                        .font(LCARSTypography.commandLabel)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(LCARSColors.commandOrange.opacity(0.15))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(LCARSColors.commandOrange.opacity(0.5), lineWidth: 1)
                        )
                )
                .foregroundColor(LCARSColors.commandOrange)
            }
            .buttonStyle(.plain)

            // Sidebar toggle
            Button {
                withAnimation {
                    columnVisibility = columnVisibility == .all ? .detailOnly : .all
                }
            } label: {
                Image(systemName: "sidebar.left")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(LCARSColors.textSecondary)
                    .padding(10)
            }
            .buttonStyle(.plain)
        }
        .padding(.trailing, 10)
    }

    // MARK: - Helpers

    private var stardateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        let datePart = formatter.string(from: currentDate)
        formatter.dateFormat = "HH:mm:ss"
        let timePart = formatter.string(from: currentDate)
        // Format as a pseudo-stardate: yyyyMM.dd:HH:mm
        return "\(datePart) · \(timePart)"
    }

    private var themeIcon: String {
        switch themeManager.selectedMode {
        case .system: return "circle.lefthalf.filled"
        case .light:  return "sun.max.fill"
        case .dark:   return "moon.fill"
        }
    }
}
