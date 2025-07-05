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

        let headerLine = formatHeaderLine(from: event, message: body)
        let metaLine = formatMetadataLine(from: event)

        let fullMessage: String
        if let lines = formatDataBlock(from: event, fittingIn: maxLogLength - (headerLine.count + metaLine.count)) {
            let formattedLines = lines.map { "↳ \($0)" }.joined(separator: "\n")
            fullMessage = [headerLine, metaLine, formattedLines].joined(separator: "\n")
        } else {
            fullMessage = [headerLine, metaLine].joined(separator: "\n")
        }

        let output = fullMessage.count > maxLogLength
            ? String(fullMessage.prefix(maxLogLength)) + "\n↳ … [truncated]"
            : fullMessage

        logger.log(level: event.metadata.type.defaultOSLogType, "\(output, privacy: .public)")
    }

    private func formatHeaderLine(from event: NexusEvent, message: String) -> String {
        let m = event.metadata
        let time = NexusTimeFormatter.shared.shortTimeWithMillis(from: m.time)
        let emoji = m.type.emoji
        let level = m.type.name.uppercased()
        return "\(time) \(emoji) \(level) - \(message)"
    }

    private func formatMetadataLine(from event: NexusEvent) -> String {
        let m = event.metadata
        return "\(m.bundleName)@\(m.appVersion) - \(m.fileName):\(m.lineNumber) - \(m.functionName):\(m.threadName)"
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
