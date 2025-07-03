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

    public func send(_ event: NexusEvent) {

        // Surface the Data we want.
        let message = event.message
        let metadata = event.metadata

        let time = metadata.time
        let emoji = metadata.type.emoji
        let typeAsString = metadata.type.name
        let typeAsOSLog = metadata.type.defaultOSLogType
        let fileName = metadata.fileName
        let lineNumber = metadata.lineNumber
        let functionName = metadata.functionName
        let threadName = metadata.threadName

        let trimmedMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
        let displayMessage = trimmedMessage.isEmpty ? "<no message>" : trimmedMessage

        let timestamp = TimeFormatter.shared.shortTimeWithMillis(from: time)
        let typeEmoji = emoji

        var output = "\(timestamp) \(typeEmoji) \(typeAsString) \(fileName):\(lineNumber) \(functionName) on \(threadName) - \(displayMessage)"

        if showProperties, let values = event.data?.values, !values.isEmpty {
            let propsBlock = values.map { "\($0.key): \($0.value)" }.joined(separator: "\n")
            output += "\n\(propsBlock)"
        }

        logger.log(level: typeAsOSLog, "\(output, privacy: .public)")
    }

}
