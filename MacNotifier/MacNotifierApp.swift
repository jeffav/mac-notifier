import SwiftUI

@main
struct MacNotifierApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            SettingsView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Request notification permissions
        Task {
            _ = await NotificationManager.shared.requestAuthorization()
        }

        // Setup menu bar
        setupMenuBar()

        // Listen for status changes to update icon
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStatusChange),
            name: .hostStatusDidChange,
            object: nil
        )

        // Start monitoring
        NetworkMonitor.shared.startMonitoring()
    }

    @objc private func handleStatusChange() {
        updateMenuBarIcon()
    }

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "network", accessibilityDescription: "Network Monitor")
            button.action = #selector(togglePopover)
            button.target = self
        }

        popover = NSPopover()
        popover.contentSize = NSSize(width: 360, height: 400)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: MenuBarView())
    }

    @objc private func togglePopover() {
        guard let button = statusItem.button else { return }

        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }

    func updateMenuBarIcon() {
        guard let button = statusItem?.button else { return }

        let hosts = DataStore.shared.hosts.filter { $0.isEnabled }
        let onlineCount = hosts.filter { $0.lastStatus?.isOnline == true }.count
        let totalCount = hosts.count

        let symbolName: String
        if totalCount == 0 {
            symbolName = "network"
        } else if onlineCount == totalCount {
            symbolName = "network"
        } else if onlineCount == 0 {
            symbolName = "network.slash"
        } else {
            symbolName = "network.badge.shield.half.filled"
        }

        button.image = NSImage(systemSymbolName: symbolName, accessibilityDescription: "Network Monitor")
    }
}
