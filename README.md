# Mission Control Lite — Free Window Manager for macOS

A free, open-source alternative to [Mission Control Plus](https://www.fadel.io/missioncontrolplus) for macOS. See all your open windows at a glance. Close, quit, or hide any app without switching to it. No subscription, no tracking, no nonsense.

Built with Swift and SwiftUI. Runs natively on macOS 14 Sonoma and later.

![macOS](https://img.shields.io/badge/macOS-14.0%2B-blue)
![License](https://img.shields.io/badge/license-MIT-green)

![Mission Control Lite screenshot](screenshot.png)

## Features

- **See all windows** — fullscreen overlay shows every open window as a live thumbnail
- **Close any window** — hover and click the red ✕ button (or press ⌘W)
- **Quit any app** — hover over a window and press ⌘Q
- **Hide any app** — hover over a window and press ⌘H
- **Switch to any window** — click its thumbnail to bring it to the front
- **Menu bar app** — lives in your menu bar, no Dock icon, no clutter
- **Privacy first** — your data never leaves your Mac, zero telemetry

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `⌃M` (Control + M) | Toggle overlay on/off |
| `Esc` | Dismiss overlay |
| `⌘W` | Close the hovered window |
| `⌘Q` | Quit the hovered app |
| `⌘H` | Hide the hovered app |
| Click thumbnail | Switch to that window |
| Click empty space | Dismiss overlay |

You can also click the menu bar icon to open the overlay, or right-click it to quit.

## Install

### Option 1: Download (easiest)

1. Go to [Releases](../../releases)
2. Download `MissionControlLite.app.zip`
3. Unzip and drag to `/Applications`
4. If macOS shows an "unverified developer" warning, run:
   ```bash
   xattr -cr /Applications/MissionControlLite.app
   ```
5. Launch from `/Applications`

### Option 2: Build from source

Requires macOS 14+ and Xcode 15+.

```bash
git clone https://github.com/MiaomiaoShi1004/MissionControlLite.git
cd MissionControlLite
xcodebuild -scheme MissionControlLite -configuration Release -derivedDataPath build
cp -R build/Build/Products/Release/MissionControlLite.app /Applications/
```

## Permissions

On first launch, macOS will ask for two permissions:

1. **Accessibility** — needed to close and focus windows (System Settings → Privacy & Security → Accessibility)
2. **Screen Recording** — needed to capture window thumbnails (System Settings → Privacy & Security → Screen Recording)

Both are required. Your data stays on your Mac — nothing is sent anywhere.

## How It Compares

| Feature | Mission Control Lite | Mission Control Plus | AltTab | macOS Mission Control |
|---------|---------------------|---------------------|--------|----------------------|
| See all windows | ✅ | ✅ | ✅ | ✅ |
| Close windows from overview | ✅ | ✅ | ❌ | ❌ |
| Quit apps from overview | ✅ | ✅ | ❌ | ❌ |
| Hide apps from overview | ✅ | ❌ | ❌ | ❌ |
| Free | ✅ | ❌ ($5.99) | ✅ | ✅ |
| Open source | ✅ | ❌ | ✅ | ❌ |
| No subscription | ✅ | ✅ | ✅ | ✅ |

## Uninstall

Drag `MissionControlLite.app` from `/Applications` to the Trash. Done.

## FAQ

**Is this app free?**
Yes, completely free and open source under the MIT license.

**Does it collect any data?**
No. Zero analytics, zero telemetry, zero network calls. Everything runs locally.

**Why does it need Screen Recording permission?**
macOS requires this permission for any app that captures window thumbnails, even if the content never leaves your device.

**How is this different from Mission Control Plus?**
Mission Control Lite is free, open source, and includes app hiding — a feature Mission Control Plus doesn't offer. It's a lightweight alternative for anyone who wants window management without paying for a subscription.

**How is this different from AltTab?**
AltTab replaces the ⌘Tab switcher. Mission Control Lite replaces Mission Control with a fullscreen overlay that lets you close, quit, or hide any window.

## Contributing

Pull requests and issues welcome. This is a community project — help make it better.

## License

[MIT](LICENSE) — do whatever you want with it.
