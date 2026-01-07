import SwiftUI

struct HostRowView: View {
    let host: Host
    @ObservedObject private var settings = AppSettings.shared
    @State private var showingEditSheet = false

    var body: some View {
        HStack(spacing: 12) {
            statusIndicator

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(host.displayName)
                        .font(.system(.body, design: .default))
                        .fontWeight(.medium)

                    if !host.isEnabled {
                        Text("Disabled")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color.secondary.opacity(0.2))
                            .cornerRadius(3)
                    }
                }

                HStack(spacing: 8) {
                    if host.label != nil {
                        Text(host.address)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Text(host.checkMethod.rawValue)
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    if let port = host.tcpPort, host.checkMethod != .ping {
                        Text(":\(port)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                if let status = host.lastStatus {
                    if settings.showResponseTime, let time = status.responseTime {
                        Text(String(format: "%.0fms", time))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    if let lastChecked = host.lastChecked {
                        Text(timeAgo(from: lastChecked))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                } else {
                    Text("Not checked")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .contextMenu {
            Button("Edit") {
                showingEditSheet = true
            }

            Button(host.isEnabled ? "Disable" : "Enable") {
                var updated = host
                updated.isEnabled.toggle()
                DataStore.shared.updateHost(updated)
            }

            Divider()

            Button("Check Now") {
                Task {
                    await NetworkMonitor.shared.checkHost(host)
                }
            }

            Divider()

            Button("Delete", role: .destructive) {
                DataStore.shared.deleteHost(host)
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            AddHostView(editingHost: host)
        }
    }

    private var statusIndicator: some View {
        ZStack {
            Circle()
                .fill(statusColor.opacity(0.2))
                .frame(width: 28, height: 28)

            Circle()
                .fill(statusColor)
                .frame(width: 12, height: 12)
        }
    }

    private var statusColor: Color {
        guard host.isEnabled else { return .gray }

        if let status = host.lastStatus {
            return status.isOnline ? .green : .red
        }
        return .gray
    }

    private func timeAgo(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)

        if interval < 60 {
            return "just now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)m ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h ago"
        } else {
            let days = Int(interval / 86400)
            return "\(days)d ago"
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        HostRowView(host: Host(
            address: "192.168.1.1",
            label: "Router",
            lastStatus: HostStatus(isOnline: true, responseTime: 2.5)
        ))
        Divider()
        HostRowView(host: Host(
            address: "server.local",
            checkMethod: .tcpPort,
            tcpPort: 22,
            lastStatus: HostStatus(isOnline: false)
        ))
        Divider()
        HostRowView(host: Host(
            address: "192.168.1.100",
            isEnabled: false
        ))
    }
    .frame(width: 360)
}
