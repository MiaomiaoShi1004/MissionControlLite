import AppKit
import Observation

// MARK: - Model

struct WindowInfo: Identifiable {
    let id: CGWindowID
    let title: String
    let appName: String
    let appIcon: NSImage?
    let frame: CGRect
    let thumbnail: NSImage?
    let pid: pid_t
}

// MARK: - Manager
     
@Observable
class WindowManager {
    var windows: [WindowInfo] = []
    var isLoading = false
    /// Tracked so the overlay controller can close the hovered window on Cmd+W.
    var hoveredWindowID: CGWindowID? = nil

    @MainActor
    func refresh() async {
        isLoading = true
        let fetched = await Task.detached(priority: .userInitiated) {
            WindowManager.fetchWindows()
        }.value
        windows = fetched
        isLoading = false
    }

    // MARK: - Window Enumeration

    private static func fetchWindows() -> [WindowInfo] {
        let options: CGWindowListOption = [.optionOnScreenOnly, .excludeDesktopElements]
        guard let rawList = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]] else {
            return []
        }

        return rawList.compactMap { dict -> WindowInfo? in
            guard
                let windowID = dict[kCGWindowNumber as String] as? CGWindowID,
                let layer   = dict[kCGWindowLayer as String] as? Int, layer == 0,
                let bounds  = dict[kCGWindowBounds as String] as? [String: CGFloat],
                let pid     = dict[kCGWindowOwnerPID as String] as? pid_t
            else { return nil }

            let width  = bounds["Width"]  ?? 0
            let height = bounds["Height"] ?? 0
            guard width > 100, height > 100 else { return nil }

            let appName = dict[kCGWindowOwnerName as String] as? String ?? "Unknown"
            guard appName != "MissionControlLite" else { return nil }

            let title = dict[kCGWindowName as String] as? String ?? ""
            let frame = CGRect(x: bounds["X"] ?? 0, y: bounds["Y"] ?? 0, width: width, height: height)

            let runningApp = NSRunningApplication(processIdentifier: pid)
            let thumbnail  = captureWindowThumbnail(windowID: windowID)

            return WindowInfo(
                id: windowID,
                title: title,
                appName: appName,
                appIcon: runningApp?.icon,
                frame: frame,
                thumbnail: thumbnail,
                pid: pid
            )
        }
    }

    /// Capture a small thumbnail (max 400px wide) instead of the full-res screenshot.
    /// Removing `.nominalResolution` gives 1x (not Retina 2x) → 4× fewer pixels.
    /// Then we downscale further so each thumbnail is only ~200KB instead of ~30MB.
    private static func captureWindowThumbnail(windowID: CGWindowID) -> NSImage? {
        guard let cgImage = CGWindowListCreateImage(
            .null,
            .optionIncludingWindow,
            windowID,
            [.boundsIgnoreFraming, .bestResolution]
        ) else { return nil }

        let srcW = CGFloat(cgImage.width)
        let srcH = CGFloat(cgImage.height)
        guard srcW > 0, srcH > 0 else { return nil }

        let maxWidth: CGFloat = 800
        let scale = min(maxWidth / srcW, 1.0)
        let dstW = Int(srcW * scale)
        let dstH = Int(srcH * scale)

        guard let ctx = CGContext(
            data: nil, width: dstW, height: dstH,
            bitsPerComponent: 8, bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
                      | CGBitmapInfo.byteOrder32Little.rawValue
        ) else { return nil }

        ctx.interpolationQuality = .medium
        ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: dstW, height: dstH))

        guard let scaled = ctx.makeImage() else { return nil }
        return NSImage(cgImage: scaled, size: NSSize(width: dstW, height: dstH))
    }

    // MARK: - Window Actions

    func focusWindow(_ window: WindowInfo) {
        NSRunningApplication(processIdentifier: window.pid)?
            .activate(options: [.activateIgnoringOtherApps])

        let axApp = AXUIElementCreateApplication(window.pid)
        forEachAXWindow(in: axApp) { axWindow in
            guard axWindowTitle(axWindow) == window.title else { return false }
            AXUIElementSetAttributeValue(axWindow, kAXMainAttribute as CFString, kCFBooleanTrue)
            return true
        }
    }

    func closeWindow(_ window: WindowInfo) {
        let axApp = AXUIElementCreateApplication(window.pid)
        forEachAXWindow(in: axApp) { axWindow in
            guard axWindowTitle(axWindow) == window.title else { return false }
            var closeRef: CFTypeRef?
            if AXUIElementCopyAttributeValue(axWindow, kAXCloseButtonAttribute as CFString, &closeRef) == .success,
               let closeButton = closeRef {
                AXUIElementPerformAction(closeButton as! AXUIElement, kAXPressAction as CFString)
            }
            return true
        }
        windows.removeAll { $0.id == window.id }
    }

    /// Quit an entire app (all its windows disappear). Used by ⌘Q on hover.
    func quitApp(of window: WindowInfo) {
        NSRunningApplication(processIdentifier: window.pid)?.terminate()
        windows.removeAll { $0.pid == window.pid }
    }

    // MARK: - AX Helpers

    private func forEachAXWindow(in axApp: AXUIElement, body: (AXUIElement) -> Bool) {
        var windowsRef: CFTypeRef?
        guard AXUIElementCopyAttributeValue(axApp, kAXWindowsAttribute as CFString, &windowsRef) == .success,
              let axWindows = windowsRef as? [AXUIElement] else { return }
        for axWindow in axWindows {
            if body(axWindow) { break }
        }
    }

    private func axWindowTitle(_ element: AXUIElement) -> String {
        var ref: CFTypeRef?
        AXUIElementCopyAttributeValue(element, kAXTitleAttribute as CFString, &ref)
        return ref as? String ?? ""
    }
}
