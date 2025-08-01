//
//  NexusDebugLog.swift
//  Nexus
//
//  Created by Josh Gallant on 02/07/2025.
//

import Foundation
import os

public struct NexusDebugLog: NexusDestination {
    private let logger: Logger
    private let showData: Bool
    private let maxLogLength: Int
    private let logOnly: [NexusEventType]
    private let requiredRoutingKey: String?

    public init(
        showData: Bool = true,
        logOnly: [NexusEventType] = [.debug, .track, .info, .notice, .warning, .error, .fault],
        requiredRoutingKey: String? = nil,
        maxLogLength: Int = 1000,
        logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Unknown Bundle", category: "Nexus Debug Log")
    ) {
        self.logger = logger
        self.showData = showData
        self.logOnly = logOnly
        self.requiredRoutingKey = requiredRoutingKey
        self.maxLogLength = maxLogLength
    }

    public func send(_ event: NexusEvent) {
        
        if let requiredRoutingKey, requiredRoutingKey != event.metadata.routingKey {
            return
        }
        
        if !logOnly.contains(event.metadata.type) {
            return
        }
        
        let msg = event.message.trimmingCharacters(in: .whitespacesAndNewlines)
        let message = msg.isEmpty ? "<no message>" : msg

        let headerLine = formatHeaderLine(from: event, message: message)
        let dataLines = formatDataBlock(from: event, fittingIn: maxLogLength - headerLine.count) ?? []

        let output: String = dataLines.isEmpty
            ? headerLine
            : ([headerLine] + dataLines).joined(separator: "\n")

        let truncated = output.count > maxLogLength
            ? String(output.prefix(maxLogLength)) + "\n└─ … [truncated]"
            : output

        logger.log(level: event.metadata.type.defaultOSLogType, "\(truncated, privacy: .public)")
    }

    func formatHeaderLine(from event: NexusEvent, message: String) -> String {
        let m = event.metadata
        let time = NexusTimeFormatter.shared.shortTimeWithMillis(from: m.time)
        let emoji = m.type.emoji
        let level = m.type.name.uppercased()
        let file = ((m.fileName as NSString).lastPathComponent as NSString)
        let location = "\(file):\(m.lineNumber) on \(m.threadName)"
        return "\(time) \(emoji) \(level) - \(location) - \(message)"
    }

    func formatDataBlock(from event: NexusEvent, fittingIn limit: Int) -> [String]? {
        guard showData else { return nil }

        if let jsonData = event.data?.json {
            if var dict = (try? JSONSerialization.jsonObject(with: jsonData)) as? [String: Any] {
                if let routingKey = event.metadata.routingKey {
                    dict["nexusRoutingKey"] = routingKey
                }
                return NexusDataFormatter.formatLines(from: dict, limit: limit)
            }
            if let arr = (try? JSONSerialization.jsonObject(with: jsonData)) as? [Any] {
                var root: [String: Any] = ["data": arr]
                if let routingKey = event.metadata.routingKey {
                    root["nexusRoutingKey"] = routingKey
                }
                return NexusDataFormatter.formatLines(from: root, limit: limit)
            }
        } else if var values = event.data?.values as? [String: Any] {
            if let routingKey = event.metadata.routingKey {
                values["nexusRoutingKey"] = routingKey
            }
            return NexusDataFormatter.formatLines(from: values, limit: limit)
        } else if let routingKey = event.metadata.routingKey {
            return NexusDataFormatter.formatLines(from: ["nexusRoutingKey": routingKey], limit: limit)
        }
        return nil
    }
}
