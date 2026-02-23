# Mission Control Lite

A free, open-source alternative to [Mission Control Plus](https://www.fadel.io/missioncontrolplus) for macOS.

See all your open windows at a glance. Close them without switching apps. No subscription, no tracking, no nonsense.

![macOS](https://img.shields.io/badge/macOS-14.0%2B-blue)
![License](https://img.shields.io/badge/license-MIT-green)

## What it does

- Shows all open windows as thumbnails in a fullscreen overlay
- **Close any window** by hovering and clicking the red ✕ (or pressing ⌘W)
- **Quit any app** by hovering and pressing ⌘Q
- **Switch to a window** by clicking its thumbnail
- Lives in your menu bar — no Dock icon, no clutter

## Keyboard shortcuts

| Shortcut | Action |
|----------|--------|
| `⌃M` (Control + M) | Toggle overlay on/off |
| `Esc` | Dismiss overlay |
| `⌘W` | Close the window you're hovering |
| `⌘Q` | Quit the app you're hovering |
| Click a thumbnail | Switch to that window |
| Click empty space | Dismiss overlay |

You can also click the menu bar icon to open the overlay, and right-click it to quit Mission Control Lite.

## Install

### Option 1: Download the app (easiest)

1. Go to [Releases](../../releases)
2. Download `MissionControlLite.app.zip`
3. Unzip and drag `MissionControlLite.app` into your `/Applications` folder
4. Double-click to launch

### Option 2: Build from source

Requirements: macOS 14+ and Xcode 15+

```bash
git clone https://github.com/miaomiaoshi/MissionControlLite.git
cd MissionControlLite
xcodebuild -scheme MissionControlLite -configuration Release -derivedDataPath build
cp -R build/Build/Products/Release/MissionControlLite.app /Applications/
```

Then open it from `/Applications`.

## Permissions

On first launch, macOS will ask for two permissions:

1. **Accessibility** — needed to close/focus windows (System Settings → Privacy & Security → Accessibility)
2. **Screen Recording** — needed to capture window thumbnails (System Settings → Privacy & Security → Screen Recording)

Both are required for the app to work. Your data never leaves your Mac.

## Uninstall

Drag `MissionControlLite.app` from `/Applications` to the Trash. Done.

## License

MIT — do whatever you want with it.
