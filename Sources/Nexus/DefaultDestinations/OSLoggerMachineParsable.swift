//
//  OSLoggerMachineParsable.swift
//  Nexus
//
//  Created by Josh Gallant on 01/07/2025.
//

import Foundation
import os

public struct OSLoggerMachineParsable: NexusDestination {
    private let logger: Logger
    private let maxMessageLength = 500
    private let maxValueLength = 200

    public init(
        subsystem: String = Bundle.main.bundleIdentifier ?? "Unknown Bundle",
        category: String = "NexusLogger"
    ) {
        self.logger = Logger(subsystem: subsystem, category: category)
    }

    public func send(_ event: NexusEvent) {
        let output = formatLogOutput(for: event)
        logger.log(level: event.metadata.type.defaultOSLogType, "\(output, privacy: .public)")
    }

    // MARK: - Private helpers

    private func formatLogOutput(for event: NexusEvent) -> String {
        let meta = event.metadata

        let emoji = meta.type.emoji
        let typeName = meta.type.name
        let timestamp = NexusTimeFormatter.shared.iso8601TimeString(from: meta.time)

        let trimmedMessage = event.message.trimmingCharacters(in: .whitespacesAndNewlines)
        let displayMessage = trimmedMessage.isEmpty ? "<no message>" : trimmedMessage
        let sanitizedMessage = "\"\(sanitizeAndTruncate(displayMessage, limit: maxMessageLength))\""

        var fields = [
            "\(emoji)\(typeName)",
            timestamp,
            meta.bundleName,
            meta.appVersion,
            "\(meta.fileName):\(meta.lineNumber)",
            meta.threadName,
            meta.functionName,
            meta.deviceModel,
            meta.osVersion,
            sanitizedMessage
        ]

        if let routingKey = meta.routingKey {
            fields.append("nexusRoutingKey=\(NexusDataFormatter.sanitizeString(routingKey))")
        }

        let structuredData = flattenData(from: event.data)
        if !structuredData.isEmpty {
            let keyValuePairs = structuredData
                .map { "\(NexusDataFormatter.sanitizeString($0.key))=\(sanitizeAndTruncate($0.value, limit: maxValueLength))" }
                .sorted()
                .joined(separator: ",")
            fields.append(keyValuePairs) // 11+
        }

        return fields.joined(separator: "|")
    }

    private func flattenData(from data: NexusEventData?) -> [String: String] {
        var values: [String: String] = [:]

        if let kv = data?.values {
            for (key, value) in kv {
                values[key] = value
            }
        }

        if let jsonData = data?.json {
            if let dict = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                for (key, value) in dict {
                    values[key] = String(describing: value)
                }
            } else {
                values["json"] = "<invalid>"
            }
        }

        return values
    }

    private func sanitizeAndTruncate(_ input: String, limit: Int) -> String {
        let truncated = input.count > limit ? String(input.prefix(limit)) + "…" : input
        return NexusDataFormatter.sanitizeString(truncated)
    }
}
