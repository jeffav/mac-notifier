import Foundation

enum CheckMethod: String, Codable, CaseIterable {
    case ping = "Ping"
    case tcpPort = "TCP Port"
    case both = "Both"
}

struct Host: Identifiable, Codable, Equatable {
    let id: UUID
    var address: String
    var label: String?
    var checkMethod: CheckMethod
    var tcpPort: Int?
    var isEnabled: Bool
    var lastStatus: HostStatus?
    var lastChecked: Date?

    var displayName: String {
        label?.isEmpty == false ? label! : address
    }

    init(
        id: UUID = UUID(),
        address: String,
        label: String? = nil,
        checkMethod: CheckMethod = .ping,
        tcpPort: Int? = nil,
        isEnabled: Bool = true,
        lastStatus: HostStatus? = nil,
        lastChecked: Date? = nil
    ) {
        self.id = id
        self.address = address
        self.label = label
        self.checkMethod = checkMethod
        self.tcpPort = tcpPort
        self.isEnabled = isEnabled
        self.lastStatus = lastStatus
        self.lastChecked = lastChecked
    }
}
