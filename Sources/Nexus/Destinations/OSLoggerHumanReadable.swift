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
        let base = formatBaseMessage(from: event)
        let data = formatDataBlock(from: event, fittingIn: maxLogLength - base.count)
        var message = data.map { base + "\n" + $0 } ?? base

        if message.count > maxLogLength {
            message = String(message.prefix(maxLogLength)) + "… [truncated]"
        }

        logger.log(level: event.metadata.type.defaultOSLogType, "\(message, privacy: .public)")
    }

    private func formatBaseMessage(from event: NexusEvent) -> String {
        let m = event.metadata
        let msg = event.message.trimmingCharacters(in: .whitespacesAndNewlines)
        let body = msg.isEmpty ? "<no message>" : msg
        let time = TimeFormatter.shared.shortTimeWithMillis(from: m.time)

        return "\(time) \(m.type.emoji) \(m.type.name) \(m.fileName):\(m.lineNumber) \(m.functionName) on \(m.threadName) - \(body)"
    }

    private func formatDataBlock(from event: NexusEvent, fittingIn limit: Int) -> String? {
        guard showData, let values = event.data?.values, !values.isEmpty else { return nil }

        let full = values.map { "\($0.key): \($0.value)" }.joined(separator: "\n")
        guard full.count > limit else { return full }

        var truncated = "", length = 0
        for line in full.split(separator: "\n", omittingEmptySubsequences: false) {
            let next = line + "\n"
            if length + next.count > limit { return truncated + "… [truncated]" }
            truncated += next; length += next.count
        }

        return truncated.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
