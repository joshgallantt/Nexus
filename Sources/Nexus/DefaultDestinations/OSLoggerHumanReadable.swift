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

        if let routingKey = event.metadata.routingKey {
            let formatted = "routing key: \"\(routingKey)\""
            dataLines.insert("└─ \(formatted)", at: 0)
        }

        var fullMessage = headerLine
        if !dataLines.isEmpty {
            fullMessage += "\n" + dataLines.joined(separator: "\n")
        }

        let output = fullMessage.count > maxLogLength
            ? String(fullMessage.prefix(maxLogLength)) + "\n└─ … [truncated]"
            : fullMessage

        logger.log(level: event.metadata.type.defaultOSLogType, "\(output, privacy: .public)")
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

        if let values = event.data?.values {
            return NexusDataFormatter.formatLines(from: values, limit: limit)
        } else if let jsonData = event.data?.json {
            return NexusDataFormatter.formatLines(from: jsonData, limit: limit)
        }

        return nil
    }
}
