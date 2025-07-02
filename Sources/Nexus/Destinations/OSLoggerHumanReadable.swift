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
    private let showProperties: Bool

    public init(
        subsystem: String = Bundle.main.bundleIdentifier ?? "Unknown Bundle",
        category: String = "NexusLogger",
        showProperties: Bool = true
    ) {
        self.logger = Logger(subsystem: subsystem, category: category)
        self.showProperties = showProperties
    }

    public func send(
        type: NexusEventType,
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
        let typeEmoji = type.emoji
        let typeName = type.name.uppercased()

        var output = "\(timestamp) \(typeEmoji) \(typeName) \(fileName):\(lineNumber) \(functionName) on \(threadName) - \(displayMessage)"

        if showProperties, let attrs = attributes, !attrs.isEmpty {
            let propsBlock = attrs.map { "\($0.key): \($0.value)" }.joined(separator: "\n")
            output += "\n\(propsBlock)"
        }

        logger.log(level: type.defaultOSLogType, "\(output, privacy: .public)")
    }
}
