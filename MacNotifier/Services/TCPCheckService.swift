import Foundation
import Network

actor TCPCheckService {
    static let shared = TCPCheckService()

    private init() {}

    struct TCPResult {
        let isReachable: Bool
        let responseTime: Double?
    }

    func checkPort(host: String, port: Int, timeout: TimeInterval = 5.0) async -> TCPResult {
        let startTime = Date()

        return await withCheckedContinuation { continuation in
            let nwHost = NWEndpoint.Host(host)
            let nwPort = NWEndpoint.Port(integerLiteral: UInt16(port))
            let connection = NWConnection(host: nwHost, port: nwPort, using: .tcp)

            var hasResumed = false
            let lock = NSLock()

            func resumeOnce(with result: TCPResult) {
                lock.lock()
                defer { lock.unlock() }
                guard !hasResumed else { return }
                hasResumed = true
                connection.cancel()
                continuation.resume(returning: result)
            }

            // Timeout handler
            DispatchQueue.global().asyncAfter(deadline: .now() + timeout) {
                resumeOnce(with: TCPResult(isReachable: false, responseTime: nil))
            }

            connection.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    let responseTime = Date().timeIntervalSince(startTime) * 1000 // ms
                    resumeOnce(with: TCPResult(isReachable: true, responseTime: responseTime))

                case .failed, .cancelled:
                    resumeOnce(with: TCPResult(isReachable: false, responseTime: nil))

                case .waiting(let error):
                    // Connection is waiting, likely unreachable
                    if case .posix(let code) = error {
                        if code == .ECONNREFUSED || code == .ETIMEDOUT || code == .EHOSTUNREACH {
                            resumeOnce(with: TCPResult(isReachable: false, responseTime: nil))
                        }
                    }

                default:
                    break
                }
            }

            connection.start(queue: DispatchQueue.global())
        }
    }
}
