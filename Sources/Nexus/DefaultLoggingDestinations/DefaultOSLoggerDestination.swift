//
//  DefaultOSLoggerDestination.swift
//  Nexus
//
//  Created by Josh Gallant on 01/07/2025.
//

import Foundation
import os

public struct DefaultOSLoggerDestination: NexusLoggingDestination {
    private let logger: Logger

    public init(
        subsystem: String = Bundle.main.bundleIdentifier ?? "Unknown Bundle",
        category: String = "NexusLogger"
    ) {
        self.logger = Logger(subsystem: subsystem, category: category)
    }

    private func osLogType(for level: NexusLogLevel) -> OSLogType {
        switch level {
        case .debug:   return .debug
        case .info:    return .info
        case .notice:  return .default
        case .warning: return .error
        case .error:   return .error
        case .fault:   return .fault
        }
    }

    public func log(
        level: NexusLogLevel,
        time: Date,
        bundleName: String,
        appVersion: String,
        fileName: String,
        functionName: String,
        lineNumber: String,
        threadName: String,
        message: String,
        attributes: [String: String]? = nil
    ) {
        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        let nonEmpty = trimmed.isEmpty ? "<no message>" : trimmed

        let sections = [
            "\(level.emoji)\(level.name)",
            sanitizeString(TimeFormatter.shared.iso8601TimeString(from: time)),
            sanitizeString(bundleName),
            sanitizeString(appVersion),
            "\(sanitizeString(fileName)):\(lineNumber)",
            sanitizeString(threadName),
            sanitizeString(functionName),
            "\"\(sanitizeString(nonEmpty))\""
        ]

        var output = sections.joined(separator: "|")

        if let attrs = attributes, !attrs.isEmpty {
            let kvs = attrs
                .map { sanitizeString($0.key) + "=" + sanitizeString($0.value) }
                .joined(separator: ",")
            output += "|\(kvs)"
        }

        logger.log(level: osLogType(for: level), "\(output, privacy: .public)")
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

import Foundation

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
