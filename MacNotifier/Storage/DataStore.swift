import Foundation
import Combine

class DataStore: ObservableObject {
    static let shared = DataStore()

    @Published private(set) var hosts: [Host] = []
    @Published private(set) var history: [HistoryEntry] = []

    private let fileManager = FileManager.default
    private let hostsFileName = "hosts.json"
    private let historyFileName = "history.json"

    private var appSupportURL: URL {
        let urls = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let appSupport = urls[0].appendingPathComponent("MacNotifier", isDirectory: true)

        if !fileManager.fileExists(atPath: appSupport.path) {
            try? fileManager.createDirectory(at: appSupport, withIntermediateDirectories: true)
        }

        return appSupport
    }

    private var hostsFileURL: URL {
        appSupportURL.appendingPathComponent(hostsFileName)
    }

    private var historyFileURL: URL {
        appSupportURL.appendingPathComponent(historyFileName)
    }

    private init() {
        loadHosts()
        loadHistory()
    }

    // MARK: - Hosts CRUD

    func addHost(_ host: Host) {
        hosts.append(host)
        saveHosts()
    }

    func updateHost(_ host: Host) {
        if let index = hosts.firstIndex(where: { $0.id == host.id }) {
            hosts[index] = host
            saveHosts()
        }
    }

    func deleteHost(_ host: Host) {
        hosts.removeAll { $0.id == host.id }
        saveHosts()
    }

    func deleteHosts(at offsets: IndexSet) {
        hosts.remove(atOffsets: offsets)
        saveHosts()
    }

    func moveHosts(from source: IndexSet, to destination: Int) {
        hosts.move(fromOffsets: source, toOffset: destination)
        saveHosts()
    }

    func updateHostStatus(hostId: UUID, status: HostStatus) {
        guard let index = hosts.firstIndex(where: { $0.id == hostId }) else { return }

        let previousStatus = hosts[index].lastStatus?.isOnline
        hosts[index].lastStatus = status
        hosts[index].lastChecked = status.timestamp

        // Log to history if status changed
        if previousStatus != status.isOnline {
            let entry = HistoryEntry(
                hostId: hostId,
                hostDisplayName: hosts[index].displayName,
                previousStatus: previousStatus,
                newStatus: status.isOnline
            )
            addHistoryEntry(entry)
        }

        saveHosts()
    }

    // MARK: - History

    func addHistoryEntry(_ entry: HistoryEntry) {
        history.insert(entry, at: 0)

        // Trim history if exceeds max
        let maxEntries = AppSettings.shared.maxHistoryEntries
        if history.count > maxEntries {
            history = Array(history.prefix(maxEntries))
        }

        saveHistory()
    }

    func clearHistory() {
        history.removeAll()
        saveHistory()
    }

    func historyForHost(_ hostId: UUID) -> [HistoryEntry] {
        history.filter { $0.hostId == hostId }
    }

    // MARK: - Persistence

    private func loadHosts() {
        guard fileManager.fileExists(atPath: hostsFileURL.path) else { return }

        do {
            let data = try Data(contentsOf: hostsFileURL)
            hosts = try JSONDecoder().decode([Host].self, from: data)
        } catch {
            print("Failed to load hosts: \(error)")
        }
    }

    private func saveHosts() {
        do {
            let data = try JSONEncoder().encode(hosts)
            try data.write(to: hostsFileURL, options: .atomic)
        } catch {
            print("Failed to save hosts: \(error)")
        }
    }

    private func loadHistory() {
        guard fileManager.fileExists(atPath: historyFileURL.path) else { return }

        do {
            let data = try Data(contentsOf: historyFileURL)
            history = try JSONDecoder().decode([HistoryEntry].self, from: data)
        } catch {
            print("Failed to load history: \(error)")
        }
    }

    private func saveHistory() {
        do {
            let data = try JSONEncoder().encode(history)
            try data.write(to: historyFileURL, options: .atomic)
        } catch {
            print("Failed to save history: \(error)")
        }
    }
}
