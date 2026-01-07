import Foundation

actor PingService {
    static let shared = PingService()

    private init() {}

    struct PingResult {
        let isReachable: Bool
        let responseTime: Double?
    }

    func ping(host: String, timeout: Int = 2) async -> PingResult {
        await withCheckedContinuation { continuation in
            let process = Process()
            let pipe = Pipe()

            process.executableURL = URL(fileURLWithPath: "/sbin/ping")
            process.arguments = ["-c", "1", "-W", "\(timeout * 1000)", host]
            process.standardOutput = pipe
            process.standardError = pipe

            do {
                try process.run()
                process.waitUntilExit()

                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                let output = String(data: data, encoding: .utf8) ?? ""

                if process.terminationStatus == 0 {
                    let responseTime = parseResponseTime(from: output)
                    continuation.resume(returning: PingResult(isReachable: true, responseTime: responseTime))
                } else {
                    continuation.resume(returning: PingResult(isReachable: false, responseTime: nil))
                }
            } catch {
                continuation.resume(returning: PingResult(isReachable: false, responseTime: nil))
            }
        }
    }

    private func parseResponseTime(from output: String) -> Double? {
        // Parse "time=X.XXX ms" from ping output
        let pattern = #"time=(\d+\.?\d*)\s*ms"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []),
              let match = regex.firstMatch(in: output, options: [], range: NSRange(output.startIndex..., in: output)),
              let range = Range(match.range(at: 1), in: output) else {
            return nil
        }

        return Double(output[range])
    }
}
