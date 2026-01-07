import SwiftUI

struct HistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var dataStore = DataStore.shared

    @State private var filterHostId: UUID?
    @State private var filterOnlineOnly = false
    @State private var filterOfflineOnly = false

    private var filteredHistory: [HistoryEntry] {
        dataStore.history.filter { entry in
            if let hostId = filterHostId, entry.hostId != hostId {
                return false
            }
            if filterOnlineOnly && !entry.newStatus {
                return false
            }
            if filterOfflineOnly && entry.newStatus {
                return false
            }
            return true
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Status History")
                    .font(.headline)
                Spacer()
                Button("Done") {
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding()

            Divider()

            // Filters
            filterBar

            Divider()

            // History list
            if filteredHistory.isEmpty {
                emptyState
            } else {
                historyList
            }
        }
        .frame(width: 500, height: 400)
    }

    private var filterBar: some View {
        HStack {
            Picker("Host", selection: $filterHostId) {
                Text("All Hosts").tag(nil as UUID?)
                ForEach(dataStore.hosts) { host in
                    Text(host.displayName).tag(host.id as UUID?)
                }
            }
            .frame(width: 150)

            Spacer()

            Toggle("Online", isOn: $filterOnlineOnly)
                .toggleStyle(.button)
                .onChange(of: filterOnlineOnly) { _, value in
                    if value { filterOfflineOnly = false }
                }

            Toggle("Offline", isOn: $filterOfflineOnly)
                .toggleStyle(.button)
                .onChange(of: filterOfflineOnly) { _, value in
                    if value { filterOnlineOnly = false }
                }

            Button(action: { DataStore.shared.clearHistory() }) {
                Image(systemName: "trash")
            }
            .disabled(dataStore.history.isEmpty)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            Text("No history")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("Status changes will appear here")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var historyList: some View {
        List(filteredHistory) { entry in
            HistoryRowView(entry: entry)
        }
    }
}

struct HistoryRowView: View {
    let entry: HistoryEntry

    var body: some View {
        HStack(spacing: 12) {
            // Status change indicator
            HStack(spacing: 4) {
                Circle()
                    .fill(entry.previousStatus == true ? Color.green : (entry.previousStatus == nil ? Color.gray : Color.red))
                    .frame(width: 8, height: 8)

                Image(systemName: "arrow.right")
                    .font(.caption2)
                    .foregroundColor(.secondary)

                Circle()
                    .fill(entry.newStatus ? Color.green : Color.red)
                    .frame(width: 8, height: 8)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.hostDisplayName)
                    .font(.body)

                Text(statusChangeText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(formatDate(entry.timestamp))
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(formatTime(entry.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private var statusChangeText: String {
        if entry.previousStatus == nil {
            return entry.newStatus ? "First check: Online" : "First check: Offline"
        }
        return entry.newStatus ? "Came online" : "Went offline"
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    HistoryView()
}
