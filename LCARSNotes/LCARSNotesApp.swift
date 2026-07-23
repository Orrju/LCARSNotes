import SwiftUI

@main
struct LCARSNotesApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var themeManager = ThemeManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.colorScheme)
        }
    }
}

/// Manages light/dark mode preference, persisted to UserDefaults.
final class ThemeManager: ObservableObject {
    enum Mode: String, CaseIterable {
        case system = "System"
        case light = "Light"
        case dark = "Dark"
    }

    @Published var selectedMode: Mode {
        didSet { UserDefaults.standard.set(selectedMode.rawValue, forKey: "themeMode") }
    }

    init() {
        let raw = UserDefaults.standard.string(forKey: "themeMode") ?? ""
        selectedMode = Mode(rawValue: raw) ?? .system
    }

    var colorScheme: ColorScheme? {
        switch selectedMode {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }

    func cycle() {
        let all = Mode.allCases
        guard let idx = all.firstIndex(of: selectedMode) else { return }
        selectedMode = all[(idx + 1) % all.count]
    }
}
