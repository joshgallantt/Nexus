//
//  OSLoggerHumanReadable.swift
//  Nexus
//
//  Created by Josh Gallant on 02/07/2025.
//

import Foundation
import os

public struct OSLoggerHumanReadable: NexusDestination {
    private let logger: Logger
    private let showData: Bool
    private let maxLogLength: Int

    public init(
        subsystem: String = Bundle.main.bundleIdentifier ?? "Unknown Bundle",
        category: String = "NexusLogger",
        showData: Bool = true,
        maxLogLength: Int = 1000
    ) {
        self.logger = Logger(subsystem: subsystem, category: category)
        self.showData = showData
        self.maxLogLength = maxLogLength
    }

    public func send(_ event: NexusEvent) {
        let msg = event.message.trimmingCharacters(in: .whitespacesAndNewlines)
        let body = msg.isEmpty ? "<no message>" : msg
        let base = formatBaseMessage(from: event, message: body)

        if let lines = formatDataBlock(from: event, fittingIn: maxLogLength - base.count) {
            let formattedLines = lines.map { "↳ \($0)" }.joined(separator: "\n")
            var message = base + "\n" + formattedLines
            if message.count > maxLogLength {
                message += "\n↳ … [truncated]"
            }
            logger.log(level: event.metadata.type.defaultOSLogType, "\(message, privacy: .public)")
        } else {
            var message = base
            if message.count > maxLogLength {
                message = String(message.prefix(maxLogLength)) + "… [truncated]"
            }
            logger.log(level: event.metadata.type.defaultOSLogType, "\(message, privacy: .public)")
        }
    }

    private func formatBaseMessage(from event: NexusEvent, message: String) -> String {
        let m = event.metadata
        let time = TimeFormatter.shared.shortTimeWithMillis(from: m.time)
        let level = m.type.name.uppercased()

        let app = m.bundleName
        let version = m.appVersion
        let thread = m.threadName
        let file = m.fileName
        let line = m.lineNumber
        let function = m.functionName

        return """
        [\(time)] \(m.type.emoji) \(level): \(message)
        \(app)@\(version) on \(thread) - \(file):\(line) \(function)
        """
    }

    private func formatDataBlock(from event: NexusEvent, fittingIn limit: Int) -> [String]? {
        guard showData else { return nil }

        var lines: [String] = []

        if let values = event.data?.values {
            lines.append(contentsOf: values
                .sorted(by: { $0.key < $1.key })
                .map { "\($0.key): \($0.value)" })
        } else if let jsonData = event.data?.json {
            if let dict = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                for key in dict.keys.sorted() {
                    lines.append("\(key): \(String(describing: dict[key]!))")
                }
            } else {
                lines.append("<unreadable json>")
            }
        }

        guard !lines.isEmpty else { return nil }

        var truncatedLines: [String] = []
        var total = 0
        for line in lines {
            let next = line + "\n"
            if total + next.count > limit {
                truncatedLines.append("… [truncated]")
                break
            }
            truncatedLines.append(line)
            total += next.count
        }

        return truncatedLines
    }
}
