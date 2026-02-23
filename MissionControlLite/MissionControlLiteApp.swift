import SwiftUI
import AppKit

@main
struct MissionControlLiteApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings { EmptyView() }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var overlayController: OverlayWindowController?
    private var statusItem: NSStatusItem?
    /// Stored so we can re-enable the tap if the system disables it on timeout.
    var eventTap: CFMachPort?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        AXIsProcessTrustedWithOptions(options)

        overlayController = OverlayWindowController()
        setupStatusBarItem()
        setupGlobalHotkey()
    }

    // MARK: - Menu Bar

    private func setupStatusBarItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        guard let button = statusItem?.button else { return }
        button.image = NSImage(named: "MenuBarIcon")
        button.image?.isTemplate = true
        button.action = #selector(statusBarClicked(_:))
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        button.target = self
    }

    @objc private func statusBarClicked(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }
        if event.type == .rightMouseUp {
            showMenu()
        } else {
            toggleOverlay()
        }
    }

    private func showMenu() {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Open Mission Control Lite",
                                action: #selector(toggleOverlay),
                                keyEquivalent: ""))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit Mission Control Lite",
                                action: #selector(NSApplication.terminate(_:)),
                                keyEquivalent: "q"))
        statusItem?.popUpMenu(menu)
    }

    // MARK: - Global Hotkey  ⌃⌥M  (Control + Option + M)
    //
    // Uses CGEvent tap — works system-wide regardless of focused app.

    private func setupGlobalHotkey() {
        let mask: CGEventMask = (1 << CGEventType.keyDown.rawValue)

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: { _, type, event, refcon -> Unmanaged<CGEvent>? in
                guard let refcon else { return Unmanaged.passUnretained(event) }

                let appDelegate = Unmanaged<AppDelegate>.fromOpaque(refcon).takeUnretainedValue()

                // Re-enable if the system disabled the tap
                if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
                    if let tap = appDelegate.eventTap {
                        CGEvent.tapEnable(tap: tap, enable: true)
                    }
                    return Unmanaged.passUnretained(event)
                }

                guard type == .keyDown else { return Unmanaged.passUnretained(event) }

                let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
                let flags   = event.flags

                // ⌃M  (Control + M, keyCode 46)
                if keyCode == 46,
                   flags.contains(.maskControl),
                   !flags.contains(.maskAlternate),
                   !flags.contains(.maskCommand) {
                    DispatchQueue.main.async { appDelegate.toggleOverlay() }
                    return nil   // consume the event
                }

                return Unmanaged.passUnretained(event)
            },
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else {
            print("⚠️ Could not create event tap — grant Accessibility permission in System Settings")
            return
        }

        let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        eventTap = tap
    }

    @objc func toggleOverlay() {
        overlayController?.toggle()
    }
}
