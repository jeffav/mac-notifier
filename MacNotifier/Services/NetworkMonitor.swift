import Foundation
import Combine
import UserNotifications

extension Notification.Name {
    static let hostStatusDidChange = Notification.Name("hostStatusDidChange")
}

@MainActor
class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()

    @Published private(set) var isMonitoring = false
    @Published private(set) var lastCheckTime: Date?

    private var timer: Timer?
    private var dataStore: DataStore { DataStore.shared }
    private var settings: AppSettings { AppSettings.shared }
    private var cancellables = Set<AnyCancellable>()

    private init() {
        // Re-setup timer when check interval changes
        settings.$checkInterval
            .dropFirst()
            .sink { [weak self] _ in
                if self?.isMonitoring == true {
                    self?.stopMonitoring()
                    self?.startMonitoring()
                }
            }
            .store(in: &cancellables)
    }

    func startMonitoring() {
        guard !isMonitoring else { return }
        isMonitoring = true

        // Immediate first check
        Task {
            await checkAllHosts()
        }

        // Schedule periodic checks
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(settings.checkInterval), repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.checkAllHosts()
            }
        }
    }

    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
        isMonitoring = false
    }

    func checkAllHosts() async {
        let enabledHosts = dataStore.hosts.filter { $0.isEnabled }

        await withTaskGroup(of: Void.self) { group in
            for host in enabledHosts {
                group.addTask {
                    await self.checkHost(host)
                }
            }
        }

        lastCheckTime = Date()
        updateMenuBarIcon()
    }

    private func updateMenuBarIcon() {
        // Post notification to update menu bar icon
        NotificationCenter.default.post(name: .hostStatusDidChange, object: nil)
    }

    func checkHost(_ host: Host) async {
        let previousStatus = host.lastStatus?.isOnline

        var isOnline = false
        var responseTime: Double?

        switch host.checkMethod {
        case .ping:
            let result = await PingService.shared.ping(host: host.address)
            isOnline = result.isReachable
            responseTime = result.responseTime

        case .tcpPort:
            guard let port = host.tcpPort else {
                return
            }
            let result = await TCPCheckService.shared.checkPort(host: host.address, port: port)
            isOnline = result.isReachable
            responseTime = result.responseTime

        case .both:
            // Check both, consider online if either succeeds
            async let pingResult = PingService.shared.ping(host: host.address)

            if let port = host.tcpPort {
                async let tcpResult = TCPCheckService.shared.checkPort(host: host.address, port: port)

                let ping = await pingResult
                let tcp = await tcpResult

                isOnline = ping.isReachable || tcp.isReachable
                responseTime = ping.responseTime ?? tcp.responseTime
            } else {
                let ping = await pingResult
                isOnline = ping.isReachable
                responseTime = ping.responseTime
            }
        }

        let status = HostStatus(isOnline: isOnline, responseTime: responseTime)

        await MainActor.run {
            dataStore.updateHostStatus(hostId: host.id, status: status)

            // Send notification if status changed
            if previousStatus != isOnline && settings.notificationsEnabled {
                sendNotification(for: host, isOnline: isOnline)
            }
        }
    }

    private func sendNotification(for host: Host, isOnline: Bool) {
        let content = UNMutableNotificationContent()
        content.title = host.displayName
        content.body = isOnline ? "is now online" : "went offline"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }
}
