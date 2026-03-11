# MissionControlLite

A lightweight macOS app that provides a Mission Control-style overlay for managing windows with keyboard shortcuts.

## Features

### Window Management
- **View All Windows**: Display all open windows in an overlay view
- **Quick Focus**: Click on any window thumbnail to bring it to focus
- **Keyboard Shortcuts**: Manage windows efficiently with keyboard commands

### Keyboard Shortcuts

When the overlay is active (after pressing `Ctrl+M` or your configured trigger):

- **ESC** — Dismiss the overlay
- **⌘W** — Close the hovered window
- **⌘Q** — Quit the hovered application
- **⌘H** — Hide the hovered application ✨ *New!*

## Requirements

- macOS 13.0 (Ventura) or later
- Swift 5.9+
- Xcode 15.0+

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/MissionControlLite.git
   cd MissionControlLite
   ```

2. Open the project in Xcode:
   ```bash
   open MissionControlLite.xcodeproj
   ```

3. Build and run the project (`⌘R`)

## Setup

### Accessibility Permissions

MissionControlLite requires accessibility permissions to interact with other applications' windows.

1. Open **System Settings** → **Privacy & Security** → **Accessibility**
2. Add **MissionControlLite** to the list of allowed apps
3. Enable the checkbox next to MissionControlLite

### Setting Up Global Hotkey

Configure your preferred global hotkey to trigger the overlay (e.g., `Ctrl+M`). This can be set up in the app preferences.

## Usage

1. Press your configured hotkey (e.g., `Ctrl+M`) to show the window overlay
2. Hover over any window thumbnail to preview it
3. Click to focus a window, or use keyboard shortcuts:
   - **⌘W** to close the hovered window
   - **⌘Q** to quit the hovered app
   - **⌘H** to hide the hovered app
4. Press **ESC** to dismiss the overlay

## Technical Details

### Architecture

- **SwiftUI**: Modern declarative UI framework
- **AppKit Integration**: Native window management using `NSRunningApplication` and Accessibility APIs
- **Observable Pattern**: State management with Swift's `@Observable` macro
- **Async/Await**: Efficient window enumeration with Swift Concurrency

### Key Components

- `OverlayWindowController`: Manages the floating overlay panel and keyboard event monitoring
- `WindowManager`: Handles window enumeration, thumbnail capture, and window actions
- `WindowThumbnailView`: SwiftUI view for displaying window thumbnails
- `MissionControlView`: Main overlay interface

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

[Your License Here]

## Changelog

### Version 1.1.0
- ✨ Added **⌘H** keyboard shortcut to hide hovered applications
- 🐛 Improved keyboard shortcut reliability with modifier flag handling

### Version 1.0.0
- Initial release with window management overlay
- Keyboard shortcuts: ESC, ⌘W, ⌘Q
- Window thumbnails and previews

## Acknowledgments

Inspired by macOS Mission Control and various window management utilities.

---

**Note**: This app is not affiliated with or endorsed by Apple Inc.
