import Foundation

struct HostStatus: Codable, Equatable {
    let isOnline: Bool
    let responseTime: Double?
    let timestamp: Date

    init(isOnline: Bool, responseTime: Double? = nil, timestamp: Date = Date()) {
        self.isOnline = isOnline
        self.responseTime = responseTime
        self.timestamp = timestamp
    }
}

struct HistoryEntry: Identifiable, Codable {
    let id: UUID
    let hostId: UUID
    let hostDisplayName: String
    let previousStatus: Bool?
    let newStatus: Bool
    let timestamp: Date

    init(
        id: UUID = UUID(),
        hostId: UUID,
        hostDisplayName: String,
        previousStatus: Bool?,
        newStatus: Bool,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.hostId = hostId
        self.hostDisplayName = hostDisplayName
        self.previousStatus = previousStatus
        self.newStatus = newStatus
        self.timestamp = timestamp
    }
}
