import AppKit
import SwiftUI

// MARK: - Custom panel that can receive keyboard events

private class KeyablePanel: NSPanel {
    override var canBecomeKey: Bool  { true }
    override var canBecomeMain: Bool { true }
}

// MARK: - Overlay Controller

class OverlayWindowController: NSObject {
    private var panel: NSPanel?
    private var keyMonitor: Any?
    private var windowManager: WindowManager?

    var isVisible: Bool { panel != nil }

    func toggle() { isVisible ? hide() : show() }

    // MARK: - Show

    func show() {
        guard !isVisible, let screen = NSScreen.main else { return }

        let wm = WindowManager()
        self.windowManager = wm

        let panel = KeyablePanel(
            contentRect: screen.frame,
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        panel.level = .floating
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.isMovable = false
        panel.acceptsMouseMovedEvents = true

        let content = MissionControlView(
            windowManager: wm,
            onDismiss: { [weak self] in self?.hide() }
        )
        .frame(width: screen.frame.width, height: screen.frame.height)

        let hostingView = NSHostingView(rootView: content)
        panel.contentView = hostingView
        panel.makeKeyAndOrderFront(nil)
        panel.makeFirstResponder(hostingView)
        NSApp.activate(ignoringOtherApps: true)

        self.panel = panel
        installMonitors()
    }

    // MARK: - Hide

    func hide() {
        removeMonitors()
        panel?.orderOut(nil)
        panel = nil
        windowManager = nil
    }

    // MARK: - Event monitors (AppKit level — always reliable)

    private func installMonitors() {
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self else { return event }

            let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)

            // Escape → dismiss
            if event.keyCode == 53 {
                self.hide()
                return nil
            }

            // ⌘W → close hovered window
            // Use .contains — `== .command` fails when Caps Lock etc. are active
            if flags.contains(.command), event.keyCode == 13 {
                self.closeHoveredWindow()
                return nil   // always consume so it never reaches the system
            }

            // ⌘Q → quit the hovered app (NOT MissionControlLite)
            // Always consume to prevent the system from quitting our app
            if flags.contains(.command), event.keyCode == 12 {
                self.quitHoveredApp()
                return nil
            }

            return event
        }
    }

    private func removeMonitors() {
        if let m = keyMonitor {
            NSEvent.removeMonitor(m)
            keyMonitor = nil
        }
    }

    private func closeHoveredWindow() {
        guard let wm = windowManager,
              let id = wm.hoveredWindowID,
              let win = wm.windows.first(where: { $0.id == id })
        else { return }
        wm.closeWindow(win)
    }

    private func quitHoveredApp() {
        guard let wm = windowManager,
              let id = wm.hoveredWindowID,
              let win = wm.windows.first(where: { $0.id == id })
        else { return }
        wm.quitApp(of: win)
    }
}
