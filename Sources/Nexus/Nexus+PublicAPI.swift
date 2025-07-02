//
//  Nexus+PublicAPI.swift
//  Nexus
//
//  Created by Josh Gallant on 02/07/2025.
//

import Foundation

public extension Nexus {
    /// Registers a new destination for event logging.
    /// - Parameters:
    ///   - dest: The `NexusDestination` to add.
    ///   - serialised: If true, events are delivered to the destination one at a time and in the order they are sent (strict ordering, useful for destinations where event sequencing matters). If false, events may be delivered out of order or in batches (higher performance, use when order does not matter or batching is preferred).
    public nonisolated static func addDestination(
        _ dest: NexusDestination,
        serialised: Bool = false
    ) {
        NexusDestinationStore.shared.addDestination(dest, serialised: serialised)
    }

    /// Sends an event with the specified message and type to all registered destinations.
    /// - Parameters:
    ///   - message: The log or event message.
    ///   - type: The event type (default is `.info`).
    ///   - attributes: Optional key-value attributes for the event.
    ///   - routingKey: Optional string used to route or filter events at the destination before sending. Useful for tagging events intended for specific destinations (e.g. "mparticle").
    ///   - file: The file name (auto-filled).
    ///   - function: The function name (auto-filled).
    ///   - line: The line number (auto-filled).
    public nonisolated static func sendEvent(
        _ message: String,
        _ type: NexusEventType = .info,
        attributes: [String: String]? = nil,
        routingKey: String? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let (bundleName, appVersion, deviceModel, osVersion) = Nexus.shared.metadata()

        let entry = NexusEvent(
            type: type,
            time: Date(),
            deviceModel: deviceModel,
            osVersion: osVersion,
            bundleName: bundleName,
            appVersion: appVersion,
            fileName: (file as NSString).lastPathComponent,
            functionName: function,
            lineNumber: String(line),
            threadName: Thread.isMainThread ? "main" : "thread-\(pthread_mach_thread_np(pthread_self()))",
            message: message,
            attributes: attributes,
            routingKey: routingKey
        )

        shared.send(entry)
    }

    /// Logs a debug-level message.
    ///
    /// When to use: For debugging! Don't ship with this, ya fool.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - attributes: Optional attributes.
    ///   - routingKey: Optional string used to route or filter events at the destination before sending. Useful for tagging events intended for specific destinations (e.g. "mparticle").
    ///   - file: The file name (auto-filled).
    ///   - function: The function name (auto-filled).
    ///   - line: The line number (auto-filled).
    public nonisolated static func debug(
        _ message: String,
        attributes: [String: String]? = nil,
        routingKey: String? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        sendEvent(message, .debug, attributes: attributes, routingKey: routingKey, file: file, function: function, line: line)
    }

    /// Sends a tracking/analytics event.
    ///
    /// When to use: For analytics or tracking events. Logged under the `OSLogType.info` level.
    /// - Parameters:
    ///   - message: The tracking message.
    ///   - attributes: Optional attributes.
    ///   - routingKey: Optional string used to route or filter events at the destination before sending. Useful for tagging events intended for specific destinations (e.g. "mparticle").
    ///   - file: The file name (auto-filled).
    ///   - function: The function name (auto-filled).
    ///   - line: The line number (auto-filled).
    public nonisolated static func track(
        _ message: String,
        attributes: [String: String]? = nil,
        routingKey: String? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        sendEvent(message, .track, attributes: attributes, routingKey: routingKey, file: file, function: function, line: line)
    }

    /// Logs an informational message.
    ///
    /// When to use: To record normal operation of the system.
    /// Example: user tapped a button, screen appeared, session refreshed.
    /// Logged under the `OSLogType.info` level, hidden unless “Include Info” is enabled.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - attributes: Optional attributes.
    ///   - routingKey: Optional string used to route or filter events at the destination before sending. Useful for tagging events intended for specific destinations (e.g. "mparticle").
    ///   - file: The file name (auto-filled).
    ///   - function: The function name (auto-filled).
    ///   - line: The line number (auto-filled).
    public nonisolated static func info(
        _ message: String,
        attributes: [String: String]? = nil,
        routingKey: String? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        sendEvent(message, .info, attributes: attributes, routingKey: routingKey, file: file, function: function, line: line)
    }

    /// Logs a notice-level message (higher than info).
    ///
    /// When to use: For normal but significant conditions that may require monitoring.
    /// Example: cache hits, number of items parsed, minor navigation events. Always recorded by default.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - attributes: Optional attributes.
    ///   - routingKey: Optional string used to route or filter events at the destination before sending. Useful for tagging events intended for specific destinations (e.g. "mparticle").
    ///   - file: The file name (auto-filled).
    ///   - function: The function name (auto-filled).
    ///   - line: The line number (auto-filled).
    public nonisolated static func notice(
        _ message: String,
        attributes: [String: String]? = nil,
        routingKey: String? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        sendEvent(message, .notice, attributes: attributes, routingKey: routingKey, file: file, function: function, line: line)
    }

    /// Logs a warning-level message.
    ///
    /// When to use: For recoverable issues or unusual conditions. Example: missing optional field, entering a degraded mode.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - attributes: Optional attributes.
    ///   - routingKey: Optional string used to route or filter events at the destination before sending. Useful for tagging events intended for specific destinations (e.g. "mparticle").
    ///   - file: The file name (auto-filled).
    ///   - function: The function name (auto-filled).
    ///   - line: The line number (auto-filled).
    public nonisolated static func warning(
        _ message: String,
        attributes: [String: String]? = nil,
        routingKey: String? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        sendEvent(message, .warning, attributes: attributes, routingKey: routingKey, file: file, function: function, line: line)
    }

    /// Logs an error-level message.
    ///
    /// When to use: For expected but unrecoverable errors that require developer attention. Example: decoding failure, file not found, unauthorized response.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - attributes: Optional attributes.
    ///   - routingKey: Optional string used to route or filter events at the destination before sending. Useful for tagging events intended for specific destinations (e.g. "mparticle").
    ///   - file: The file name (auto-filled).
    ///   - function: The function name (auto-filled).
    ///   - line: The line number (auto-filled).
    public nonisolated static func error(
        _ message: String,
        attributes: [String: String]? = nil,
        routingKey: String? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        sendEvent(message, .error, attributes: attributes, routingKey: routingKey, file: file, function: function, line: line)
    }

    /// Logs a fault-level message (critical error).
    ///
    /// When to use: For critical conditions that should never occur. Example: application entered an unexpected, unrecoverable state.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - attributes: Optional attributes.
    ///   - routingKey: Optional string used to route or filter events at the destination before sending. Useful for tagging events intended for specific destinations (e.g. "mparticle").
    ///   - file: The file name (auto-filled).
    ///   - function: The function name (auto-filled).
    ///   - line: The line number (auto-filled).
    public nonisolated static func fault(
        _ message: String,
        attributes: [String: String]? = nil,
        routingKey: String? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        sendEvent(message, .fault, attributes: attributes, routingKey: routingKey, file: file, function: function, line: line)
    }
}
