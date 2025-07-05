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

    public init(
        subsystem: String = Bundle.main.bundleIdentifier ?? "Unknown Bundle",
        category: String = "NexusLogger"
    ) {
        self.logger = Logger(subsystem: subsystem, category: category)
    }

    public func send(_ event: NexusEvent) {
        let message = event.message
        let metadata = event.metadata

        // Surface metadata
        let type = metadata.type
        let time = metadata.time
        let deviceModel = metadata.deviceModel
        let osVersion = metadata.osVersion
        let bundleName = metadata.bundleName
        let appVersion = metadata.appVersion
        let fileName = metadata.fileName
        let functionName = metadata.functionName
        let lineNumber = metadata.lineNumber
        let threadName = metadata.threadName
        let routingKey = metadata.routingKey

        // Prep values
        let emoji = type.emoji
        let typeName = type.name
        let osLogType = type.defaultOSLogType
        let timestamp = TimeFormatter.shared.iso8601TimeString(from: time)

        let trimmedMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
        let displayMessage = trimmedMessage.isEmpty ? "<no message>" : trimmedMessage
        let sanitizedMessage = "\"\(sanitizeString(displayMessage))\""

        var sections = [
            "\(emoji)\(typeName)",
            timestamp,
            bundleName,
            appVersion,
            "\(fileName):\(lineNumber)",
            threadName,
            functionName,
            deviceModel,
            osVersion,
            sanitizedMessage
        ]

        if let routingKey {
            sections.append("routingKey=\(routingKey)")
        }

        if let values = event.data?.values, !values.isEmpty {
            let keyValuePairs = values
                .map { "\(sanitizeString($0.key))=\(sanitizeString($0.value))" }
                .joined(separator: ",")
            sections.append(keyValuePairs)
        }

        let output = sections.joined(separator: "|")
        logger.log(level: osLogType, "\(output, privacy: .public)")
    }
    private func sanitizeString(_ input: String) -> String {
        input
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "\\r")
            .replacingOccurrences(of: "\t", with: "\\t")
            .replacingOccurrences(of: "|", with: "\\|")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: ",", with: "\\,")
            .replacingOccurrences(of: "=", with: "\\=")
    }
}

struct TimeFormatter: Sendable {
    static let shared = TimeFormatter()

    nonisolated(unsafe) private static let formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()

    func iso8601TimeString(from date: Date) -> String {
        Self.formatter.string(from: date)
    }
    
    func shortTimeWithMillis(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        formatter.timeZone = .current
        return formatter.string(from: date)
    }

}
