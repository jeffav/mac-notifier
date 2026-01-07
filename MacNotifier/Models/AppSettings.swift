import Foundation

class AppSettings: ObservableObject {
    static let shared = AppSettings()

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let checkInterval = "checkInterval"
        static let notificationsEnabled = "notificationsEnabled"
        static let launchAtLogin = "launchAtLogin"
        static let showResponseTime = "showResponseTime"
        static let maxHistoryEntries = "maxHistoryEntries"
    }

    @Published var checkInterval: Int {
        didSet { defaults.set(checkInterval, forKey: Keys.checkInterval) }
    }

    @Published var notificationsEnabled: Bool {
        didSet { defaults.set(notificationsEnabled, forKey: Keys.notificationsEnabled) }
    }

    @Published var launchAtLogin: Bool {
        didSet { defaults.set(launchAtLogin, forKey: Keys.launchAtLogin) }
    }

    @Published var showResponseTime: Bool {
        didSet { defaults.set(showResponseTime, forKey: Keys.showResponseTime) }
    }

    @Published var maxHistoryEntries: Int {
        didSet { defaults.set(maxHistoryEntries, forKey: Keys.maxHistoryEntries) }
    }

    private init() {
        // Register defaults
        defaults.register(defaults: [
            Keys.checkInterval: 30,
            Keys.notificationsEnabled: true,
            Keys.launchAtLogin: false,
            Keys.showResponseTime: true,
            Keys.maxHistoryEntries: 1000
        ])

        // Load values
        self.checkInterval = defaults.integer(forKey: Keys.checkInterval)
        self.notificationsEnabled = defaults.bool(forKey: Keys.notificationsEnabled)
        self.launchAtLogin = defaults.bool(forKey: Keys.launchAtLogin)
        self.showResponseTime = defaults.bool(forKey: Keys.showResponseTime)
        self.maxHistoryEntries = defaults.integer(forKey: Keys.maxHistoryEntries)
    }
}
