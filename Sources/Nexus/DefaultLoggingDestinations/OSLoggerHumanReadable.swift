//
//  OSLoggerHumanReadable.swift
//  Nexus
//
//  Created by Josh Gallant on 02/07/2025.
//

import Foundation
import os

public struct OSLoggerHumanReadable: NexusLoggingDestination {
    private let logger: Logger
    private let showProperties: Bool

    public init(
        subsystem: String = Bundle.main.bundleIdentifier ?? "Unknown Bundle",
        category: String = "NexusLogger",
        showProperties: Bool = true
    ) {
        self.logger = Logger(subsystem: subsystem, category: category)
        self.showProperties = showProperties
    }

    private func osLogType(for level: NexusLogLevel) -> OSLogType {
        switch level {
        case .debug:   return .debug
        case .info:    return .info
        case .notice:  return .default
        case .warning, .error: return .error
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
        let trimmedMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
        let displayMessage = trimmedMessage.isEmpty ? "<no message>" : trimmedMessage

        let timestamp = TimeFormatter.shared.shortTimeWithMillis(from: time)
        let levelEmoji = level.emoji
        let levelName = level.name.uppercased()

        var output = "\(timestamp) \(levelEmoji) \(levelName) \(fileName):\(lineNumber) \(functionName) on \(threadName) - \(displayMessage)"

        if showProperties, let attrs = attributes, !attrs.isEmpty {
            let propsBlock = attrs.map { "\($0.key): \($0.value)" }.joined(separator: "\n")
            output += "\n\(propsBlock)"
        }

        logger.log(level: osLogType(for: level), "\(output, privacy: .public)")
    }
}
