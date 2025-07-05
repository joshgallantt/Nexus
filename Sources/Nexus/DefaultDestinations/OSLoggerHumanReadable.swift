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
        let message = msg.isEmpty ? "<no message>" : msg

        let headerLine = formatHeaderLine(from: event, message: message)
        var dataLines = formatDataBlock(from: event, fittingIn: maxLogLength - headerLine.count) ?? []

        let output: String = dataLines.isEmpty
            ? headerLine
            : ([headerLine] + dataLines).joined(separator: "\n")

        let truncated = output.count > maxLogLength
            ? String(output.prefix(maxLogLength)) + "\n└─ … [truncated]"
            : output

        logger.log(level: event.metadata.type.defaultOSLogType, "\(truncated, privacy: .public)")
    }

    private func formatHeaderLine(from event: NexusEvent, message: String) -> String {
        let m = event.metadata
        let time = NexusTimeFormatter.shared.shortTimeWithMillis(from: m.time)
        let emoji = m.type.emoji
        let level = m.type.name.uppercased()
        let file = ((m.fileName as NSString).lastPathComponent as NSString)
        let location = "\(file):\(m.lineNumber) on \(m.threadName)"
        return "\(time) \(emoji) \(level) - \(location) - \(message)"
    }

    private func formatDataBlock(from event: NexusEvent, fittingIn limit: Int) -> [String]? {
        guard showData else { return nil }

        // Merge routing key as a top-level property if present
        if let jsonData = event.data?.json {
            if var dict = (try? JSONSerialization.jsonObject(with: jsonData)) as? [String: Any] {
                if let routingKey = event.metadata.routingKey {
                    dict["routing key"] = routingKey
                }
                return NexusDataFormatter.formatLines(from: dict, limit: limit)
            }
            if let arr = (try? JSONSerialization.jsonObject(with: jsonData)) as? [Any] {
                var root: [String: Any] = ["data": arr]
                if let routingKey = event.metadata.routingKey {
                    root["routing key"] = routingKey
                }
                return NexusDataFormatter.formatLines(from: root, limit: limit)
            }
        } else if var values = event.data?.values as? [String: Any] {
            if let routingKey = event.metadata.routingKey {
                values["routing key"] = routingKey
            }
            return NexusDataFormatter.formatLines(from: values, limit: limit)
        } else if let routingKey = event.metadata.routingKey {
            return NexusDataFormatter.formatLines(from: ["routing key": routingKey], limit: limit)
        }
        return nil
    }
}
