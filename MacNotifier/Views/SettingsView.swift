import SwiftUI
import ServiceManagement
import UserNotifications

struct SettingsView: View {
    @ObservedObject private var settings = AppSettings.shared
    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined

    var body: some View {
        TabView {
            generalSettings
                .tabItem {
                    Label("General", systemImage: "gear")
                }

            notificationSettings
                .tabItem {
                    Label("Notifications", systemImage: "bell")
                }

            advancedSettings
                .tabItem {
                    Label("Advanced", systemImage: "wrench")
                }
        }
        .frame(width: 450, height: 250)
        .task {
            notificationStatus = await NotificationManager.shared.checkAuthorizationStatus()
        }
    }

    private var generalSettings: some View {
        Form {
            Section {
                HStack {
                    Text("Check Interval")
                    Spacer()
                    Picker("", selection: $settings.checkInterval) {
                        Text("10 seconds").tag(10)
                        Text("30 seconds").tag(30)
                        Text("1 minute").tag(60)
                        Text("2 minutes").tag(120)
                        Text("5 minutes").tag(300)
                    }
                    .frame(width: 150)
                }

                Toggle("Show response time", isOn: $settings.showResponseTime)
            }

            Section {
                Toggle("Launch at login", isOn: $settings.launchAtLogin)
                    .onChange(of: settings.launchAtLogin) { _, newValue in
                        updateLaunchAtLogin(enabled: newValue)
                    }
            }
        }
        .formStyle(.grouped)
        .padding()
    }

    private var notificationSettings: some View {
        Form {
            Section {
                Toggle("Enable notifications", isOn: $settings.notificationsEnabled)

                if notificationStatus == .denied {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text("Notifications are disabled in System Settings")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Button("Open Settings") {
                            openNotificationSettings()
                        }
                        .font(.caption)
                    }
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }

    private var advancedSettings: some View {
        Form {
            Section {
                HStack {
                    Text("Max history entries")
                    Spacer()
                    Picker("", selection: $settings.maxHistoryEntries) {
                        Text("100").tag(100)
                        Text("500").tag(500)
                        Text("1000").tag(1000)
                        Text("5000").tag(5000)
                    }
                    .frame(width: 100)
                }

                HStack {
                    Button("Clear History") {
                        DataStore.shared.clearHistory()
                    }

                    Text("\(DataStore.shared.history.count) entries")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Section {
                HStack {
                    Text("Data Location")
                    Spacer()
                    Button("Reveal in Finder") {
                        revealDataFolder()
                    }
                    .font(.caption)
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }

    private func updateLaunchAtLogin(enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("Failed to update launch at login: \(error)")
        }
    }

    private func openNotificationSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.notifications") {
            NSWorkspace.shared.open(url)
        }
    }

    private func revealDataFolder() {
        let urls = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let appSupport = urls[0].appendingPathComponent("MacNotifier", isDirectory: true)
        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: appSupport.path)
    }
}

#Preview {
    SettingsView()
}
