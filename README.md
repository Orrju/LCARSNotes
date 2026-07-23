# LCARS Notes

An iPad note-taking app built with SwiftUI, PencilKit, and Core Data, featuring a **Functional LCARS** design aesthetic inspired by *Star Trek: The Next Generation*.

## Features

- **PencilKit Canvas** — Primary note-taking interface with Apple Pencil support, handwriting recognition, and pre-defined templates (blank, lined, grid, dot grid, storyboard, Cornell notes, and more).
- **Hybrid Notes** — Each note supports both handwritten drawing and typed body text, switchable at will.
- **Hierarchical Folders** — Organize notes into nested folders with drag-and-drop reordering and inline rename.
- **Tags** — Assign multiple color-coded tags to any note for cross-cutting organization.
- **Full-Text Search** — Search across note titles, body text, and OCR-recognized handwriting.
- **Light / Dark Mode** — System-aware with a manual override toggle in the command bar.
- **Export & Share** — Export notes as PDF or image; share via the native iOS/iPadOS share sheet.
- **CloudKit-Ready** — Core Data stack initialized with `NSPersistentCloudKitContainer` for future iCloud sync.

## LCARS Design Philosophy

This project follows the **Functional Futurism** design brief:

| Principle | Implementation |
|---|---|
| Rounded Rectangles | Consistent 12–14 pt `cornerRadius` on all containers |
| Filament System | Thin 1.5 pt accent-colored lines connecting related blocks |
| Modular Grid | All elements snap to a block-based grid; no floating UI |
| Negative Space | Deliberate padding between modules to reduce cognitive load |
| High Contrast | All text meets WCAG AA; no orange-on-yellow or similar conflicts |
| SF Typography | Bold SF Pro for headers, SF Mono for data readouts |

### Color Palette

| Name | Hex | Role |
|---|---|---|
| Space Black | `#0B0B14` | Dark-mode background |
| Dark Charcoal | `#151525` | Dark-mode card surfaces |
| Light Gray | `#F0F0F5` | Light-mode background |
| Command Orange | `#FF7B00` | Primary actions, alerts |
| Data Yellow | `#FFC107` | Highlights, secondary info |
| System Blue | `#3388DD` | Navigation, status indicators |
| Warning Red | `#E53935` | Critical status, destructive actions |
| Accent Purple | `#7B68EE` | Tags, tertiary accent |
| Accent Teal | `#00BCD4` | Status readouts, progress |

## Project Structure

```
LCARSNotes/
├── LCARSNotesApp.swift              # App entry point
├── ContentView.swift                 # Root layout (sidebar + command bar + content)
├── Theme/
│   ├── LCARSColors.swift             # Color definitions, light/dark support
│   ├── LCARSTypography.swift         # Font styles
│   ├── LCARSButtonStyle.swift        # Blocky button styling
│   ├── LCARSTextFieldStyle.swift     # Themed text fields
│   ├── LCARSProgressStyle.swift      # Segmented progress bars
│   └── View+LCARSModifiers.swift     # Reusable view modifiers
├── CoreData/
│   ├── PersistenceController.swift   # NSPersistentCloudKitContainer setup
│   └── LCARSNotes.xcdatamodeld/      # Core Data schema
├── Models/
│   ├── Note+Extensions.swift
│   ├── Folder+Extensions.swift
│   └── Tag+Extensions.swift
├── ViewModels/
│   ├── NoteViewModel.swift
│   └── FolderViewModel.swift
├── Views/
│   ├── Main/
│   │   ├── CommandBarView.swift
│   │   └── SidebarView.swift
│   ├── Notes/
│   │   ├── NoteCanvasView.swift
│   │   ├── NoteEditorView.swift
│   │   ├── NoteListView.swift
│   │   └── TemplatePickerView.swift
│   ├── Organization/
│   │   ├── FolderTreeView.swift
│   │   ├── TagManagementView.swift
│   │   └── TagChipView.swift
│   └── Search/
│       └── SearchView.swift
└── Utilities/
    ├── PencilKitManager.swift
    ├── ExportManager.swift
    └── DateFormatter+Extensions.swift
```

## Setup Instructions

1. **Create a new Xcode project:**
   - Open Xcode 15+
   - File → New → Project → iOS → App
   - Interface: SwiftUI, Language: Swift
   - Check "Use Core Data" and "Include Tests" as preferred
   - Minimum Deployment Target: iPadOS 17.0

2. **Add source files:**
   - Drag the `LCARSNotes/` directory from this repo into your Xcode project navigator.
   - Ensure "Create groups" is selected and the target is checked.

3. **Configure the Core Data model:**
   - In your `.xcdatamodeld`, create the entities as shown in the model contents file, or replace with the provided model.

4. **Build & Run** on an iPad simulator or device.

## Requirements

- Xcode 15.0+
- iPadOS 17.0+
- Apple Pencil (for handwriting features)

## License

MIT — see LICENSE file.
