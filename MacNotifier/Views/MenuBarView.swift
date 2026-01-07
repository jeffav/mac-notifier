import SwiftUI

struct MenuBarView: View {
    @ObservedObject private var dataStore = DataStore.shared
    @ObservedObject private var monitor = NetworkMonitor.shared
    @State private var showingAddHost = false
    @State private var showingSettings = false
    @State private var showingHistory = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Network Monitor")
                    .font(.headline)
                Spacer()
                statusSummary
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))

            Divider()

            // Host list
            if dataStore.hosts.isEmpty {
                emptyState
            } else {
                hostList
            }

            Divider()

            // Footer actions
            footerActions
        }
        .frame(width: 360)
        .sheet(isPresented: $showingAddHost) {
            AddHostView()
        }
        .sheet(isPresented: $showingHistory) {
            HistoryView()
        }
    }

    private var statusSummary: some View {
        let hosts = dataStore.hosts.filter { $0.isEnabled }
        let online = hosts.filter { $0.lastStatus?.isOnline == true }.count

        return HStack(spacing: 4) {
            Circle()
                .fill(online == hosts.count && !hosts.isEmpty ? Color.green : (online > 0 ? Color.orange : Color.red))
                .frame(width: 8, height: 8)
            Text("\(online)/\(hosts.count)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "network.slash")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            Text("No hosts configured")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("Add a host to start monitoring")
                .font(.caption)
                .foregroundColor(.secondary)
            Button("Add Host") {
                showingAddHost = true
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    private var hostList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(dataStore.hosts) { host in
                    HostRowView(host: host)
                    if host.id != dataStore.hosts.last?.id {
                        Divider()
                            .padding(.leading, 44)
                    }
                }
            }
        }
        .frame(maxHeight: 300)
    }

    private var footerActions: some View {
        HStack {
            Button(action: { showingAddHost = true }) {
                Label("Add Host", systemImage: "plus")
            }
            .buttonStyle(.borderless)

            Spacer()

            Button(action: {
                Task {
                    await monitor.checkAllHosts()
                }
            }) {
                Label("Check Now", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.borderless)

            Button(action: { showingHistory = true }) {
                Label("History", systemImage: "clock")
            }
            .buttonStyle(.borderless)

            SettingsLink {
                Label("Settings", systemImage: "gear")
            }
            .buttonStyle(.borderless)

            Button(action: { NSApplication.shared.terminate(nil) }) {
                Label("Quit", systemImage: "power")
            }
            .buttonStyle(.borderless)
        }
        .padding(12)
        .labelStyle(.iconOnly)
    }
}

#Preview {
    MenuBarView()
}
