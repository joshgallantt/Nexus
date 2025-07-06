//
//  Nexus+PublicAPI.swift
//  Nexus
//
//  Created by Josh Gallant on 02/07/2025.
//

import Foundation

public extension Nexus {
    // MARK: - Public Destination Registration

    /// Registers a new destination for event logging.
    ///
    /// Use this to attach a `NexusDestination` that will receive events emitted through the Nexus logging system.
    ///
    /// - Parameters:
    ///   - dest: The `NexusDestination` to add.
    ///   - serialised: If true, events are delivered to the destination one at a time and in the order they are sent (strict ordering, useful for destinations where event sequencing matters).
    ///                 If false, events may be delivered out of order or in batches (higher performance, use when order does not matter or batching is preferred).
    @inlinable
    public nonisolated static func addDestination(
        _ dest: NexusDestination,
        serialised: Bool = true
    ) {
        Task(priority: .background) {
            await NexusDestinationStore.shared.addDestination(dest, serialised: serialised)
        }
    }
    
    
    // MARK: - DEBUG
    
    /// Logs a debug-level message with dictionary values.
    ///
    /// When to use: For diagnostic purposes during development. Not intended for production logging.
    /// - Parameters:
    ///   - message: The debug message.
    ///   - routingKey: Optional routing key to filter/route this message.
    ///   - values: Dictionary of string key-value pairs representing additional metadata.
    static func debug(_ message: String, routingKey: String? = nil, _ values: [String: Any]? = nil, file: String = #fileID, function: String = #function, line: Int = #line) {
        sendEvent(message, .debug, routingKey: routingKey, values: values, file: file, function: function, line: line)
    }

    /// Logs a debug-level message with an `Encodable` payload.
    ///
    /// When to use: For diagnostic purposes during development. Not intended for production logging.
    /// - Parameters:
    ///   - message: The debug message.
    ///   - routingKey: Optional routing key.
    ///   - data: Any encodable type to be JSON-encoded before logging.
    @_disfavoredOverload
    static func debug<T: Encodable>(_ message: String, routingKey: String? = nil, _ data: T, file: String = #fileID, function: String = #function, line: Int = #line) {
        sendEvent(message, .debug, routingKey: routingKey, encodable: data, file: file, function: function, line: line)
    }

    /// Logs a debug-level message with raw JSON data.
    ///
    /// When to use: For diagnostic purposes during development. Not intended for production logging.
    /// - Parameters:
    ///   - message: The debug message.
    ///   - routingKey: Optional routing key.
    ///   - json: A `Data` object representing a JSON payload.
    static func debug(_ message: String, routingKey: String? = nil, _ json: Data, file: String = #fileID, function: String = #function, line: Int = #line) {
        sendEvent(message, .debug, routingKey: routingKey, json: json, file: file, function: function, line: line)
    }

    // MARK: - TRACK
    
    /// Logs a tracking/analytics event with dictionary values.
    ///
    /// When to use: For analytics or tracking events. Logged under the `OSLogType.info` level.
    /// - Parameters:
    ///   - message: The tracking message.
    ///   - routingKey: Optional routing key.
    ///   - values: Dictionary of attributes for the event.
    static func track(_ message: String, routingKey: String? = nil, _ values: [String: Any]? = nil, file: String = #fileID, function: String = #function, line: Int = #line) {
        sendEvent(message, .track, routingKey: routingKey, values: values, file: file, function: function, line: line)
    }

    /// Logs a tracking event with an `Encodable` payload.
    ///
    /// When to use: For analytics or tracking events. Logged under the `OSLogType.info` level.
    /// - Parameters:
    ///   - message: The tracking message.
    ///   - routingKey: Optional routing key.
    ///   - data: Encodable payload for analytics.
    @_disfavoredOverload
    static func track<T: Encodable>(_ message: String, routingKey: String? = nil, _ data: T, file: String = #fileID, function: String = #function, line: Int = #line) {
        sendEvent(message, .track, routingKey: routingKey, encodable: data, file: file, function: function, line: line)
    }

    /// Logs a tracking event with pre-encoded JSON.
    ///
    /// When to use: For analytics or tracking events. Logged under the `OSLogType.info` level.
    /// - Parameters:
    ///   - message: The tracking message.
    ///   - routingKey: Optional routing key.
    ///   - json: Pre-encoded JSON data.
    static func track(_ message: String, routingKey: String? = nil, _ json: Data, file: String = #fileID, function: String = #function, line: Int = #line) {
        sendEvent(message, .track, routingKey: routingKey, json: json, file: file, function: function, line: line)
    }

    // MARK: - INFO
    
    /// Logs an informational message with dictionary attributes.
    ///
    /// When to use: To record normal operation of the system.
    /// Example: user tapped a button, screen appeared, session refreshed.
    /// Logged under the `OSLogType.info` level, hidden unless “Include Info” is enabled in Console.app.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - routingKey: Optional routing key.
    ///   - values: Optional key-value attributes.
    static func info(_ message: String, routingKey: String? = nil, _ values: [String: Any]? = nil, file: String = #fileID, function: String = #function, line: Int = #line) {
        sendEvent(message, .info, routingKey: routingKey, values: values, file: file, function: function, line: line)
    }

    /// Logs an informational message with an `Encodable` payload.
    ///
    /// When to use: To record normal operation of the system.
    /// Example: user tapped a button, screen appeared, session refreshed.
    /// Logged under the `OSLogType.info` level, hidden unless “Include Info” is enabled in Console.app.
    /// - Parameters:
    ///   - message: Info message.
    ///   - routingKey: Optional routing key.
    ///   - data: Encodable context.
    @_disfavoredOverload
    static func info<T: Encodable>(_ message: String, routingKey: String? = nil, _ data: T, file: String = #fileID, function: String = #function, line: Int = #line) {
        sendEvent(message, .info, routingKey: routingKey, encodable: data, file: file, function: function, line: line)
    }

    /// Logs an informational message with raw JSON.
    ///
    /// When to use: To record normal operation of the system.
    /// Example: user tapped a button, screen appeared, session refreshed.
    /// Logged under the `OSLogType.info` level, hidden unless “Include Info” is enabled in Console.app.
    /// - Parameters:
    ///   - message: The message.
    ///   - routingKey: Optional routing key.
    ///   - json: JSON data.
    static func info(_ message: String, routingKey: String? = nil, _ json: Data, file: String = #fileID, function: String = #function, line: Int = #line) {
        sendEvent(message, .info, routingKey: routingKey, json: json, file: file, function: function, line: line)
    }

    // MARK: - NOTICE
    
    /// Logs a notice-level message with key-value attributes.
    ///
    /// When to use: For normal but significant conditions that may require monitoring.
    /// Example: cache hits, number of items parsed, minor navigation events.
    /// - Parameters:
    ///   - message: Notice message.
    ///   - routingKey: Optional routing key.
    ///   - values: Event attributes.
    static func notice(_ message: String, routingKey: String? = nil, _ values: [String: Any]? = nil, file: String = #fileID, function: String = #function, line: Int = #line) {
        sendEvent(message, .notice, routingKey: routingKey, values: values, file: file, function: function, line: line)
    }

    /// Logs a notice-level message with an encodable payload.
    ///
    /// When to use: For normal but significant conditions that may require monitoring.
    /// Example: cache hits, number of items parsed, minor navigation events.
    /// - Parameters:
    ///   - message: The message.
    ///   - routingKey: Optional routing key.
    ///   - data: Encodable event context.
    @_disfavoredOverload
    static func notice<T: Encodable>(_ message: String, routingKey: String? = nil, _ data: T, file: String = #fileID, function: String = #function, line: Int = #line) {
        sendEvent(message, .notice, routingKey: routingKey, encodable: data, file: file, function: function, line: line)
    }

    /// Logs a notice-level message with raw JSON.
    ///
    /// When to use: For normal but significant conditions that may require monitoring.
    /// Example: cache hits, number of items parsed, minor navigation events.
    /// - Parameters:
    ///   - message: The message.
    ///   - routingKey: Optional routing key.
    ///   - json: JSON payload.
    static func notice(_ message: String, routingKey: String? = nil, _ json: Data, file: String = #fileID, function: String = #function, line: Int = #line) {
        sendEvent(message, .notice, routingKey: routingKey, json: json, file: file, function: function, line: line)
    }

    // MARK: - WARNING
    
    /// Logs a warning-level message with key-value attributes.
    ///
    /// When to use: For recoverable issues or unusual conditions.
    /// Example: missing optional field, entering a degraded mode.
    /// - Parameters:
    ///   - message: Warning message.
    ///   - routingKey: Optional routing key.
    ///   - values: Additional context.
    static func warning(_ message: String, routingKey: String? = nil, _ values: [String: Any]? = nil, file: String = #fileID, function: String = #function, line: Int = #line) {
        sendEvent(message, .warning, routingKey: routingKey, values: values, file: file, function: function, line: line)
    }

    /// Logs a warning-level message with an encodable payload.
    ///
    /// When to use: For recoverable issues or unusual conditions.
    /// Example: missing optional field, entering a degraded mode.
    /// - Parameters:
    ///   - message: Warning message.
    ///   - routingKey: Optional routing key.
    ///   - payload: Context object.
    @_disfavoredOverload
    static func warning<T: Encodable>(_ message: String, routingKey: String? = nil, _ data: T, file: String = #fileID, function: String = #function, line: Int = #line) {
        sendEvent(message, .warning, routingKey: routingKey, encodable: data, file: file, function: function, line: line)
    }

    /// Logs a warning-level message with raw JSON.
    ///
    /// When to use: For recoverable issues or unusual conditions.
    /// Example: missing optional field, entering a degraded mode.
    /// - Parameters:
    ///   - message: Message to log.
    ///   - routingKey: Optional routing key.
    ///   - json: JSON payload.
    static func warning(_ message: String, routingKey: String? = nil, _ json: Data, file: String = #fileID, function: String = #function, line: Int = #line) {
        sendEvent(message, .warning, routingKey: routingKey, json: json, file: file, function: function, line: line)
    }

    // MARK: - ERROR
    
    /// Logs an error-level message with key-value attributes.
    ///
    /// When to use: For expected but unrecoverable errors that require developer attention.
    /// You might have an error screen or state for these.
    /// Example: decoding failure, file not found, unauthorized response.
    /// - Parameters:
    ///   - message: The error message.
    ///   - routingKey: Optional routing key.
    ///   - values: Contextual data about the error.
    static func error(_ message: String, routingKey: String? = nil, _ values: [String: Any]? = nil, file: String = #fileID, function: String = #function, line: Int = #line) {
        sendEvent(message, .error, routingKey: routingKey, values: values, file: file, function: function, line: line)
    }

    /// Logs an error-level message with an encodable payload.
    ///
    /// When to use: For expected but unrecoverable errors that require developer attention.
    /// You might have an error screen or state for these.
    /// Example: decoding failure, file not found, unauthorized response.
    /// - Parameters:
    ///   - message: The message.
    ///   - routingKey: Optional routing key.
    ///   - data: Encodable payload.
    @_disfavoredOverload
    static func error<T: Encodable>(_ message: String, routingKey: String? = nil, _ data: T, file: String = #fileID, function: String = #function, line: Int = #line) {
        sendEvent(message, .error, routingKey: routingKey, encodable: data, file: file, function: function, line: line)
    }

    /// Logs an error-level message with raw JSON.
    ///
    /// When to use: For expected but unrecoverable errors that require developer attention.
    /// You might have an error screen or state for these.
    /// Example: decoding failure, file not found, unauthorized response.
    /// - Parameters:
    ///   - message: Error message.
    ///   - routingKey: Optional routing key.
    ///   - json: JSON payload.
    static func error(_ message: String, routingKey: String? = nil, _ json: Data, file: String = #fileID, function: String = #function, line: Int = #line) {
        sendEvent(message, .error, routingKey: routingKey, json: json, file: file, function: function, line: line)
    }

    // MARK: - FAULT
    
    /// Logs a fault-level message with attributes.
    ///
    /// When to use: For critical conditions that should never occur.
    /// Example: application entered an unexpected, unrecoverable state.
    /// - Parameters:
    ///   - message: The fault message.
    ///   - routingKey: Optional routing key.
    ///   - values: Details of the failure.
    static func fault(_ message: String, routingKey: String? = nil, _ values: [String: Any]? = nil, file: String = #fileID, function: String = #function, line: Int = #line) {
        sendEvent(message, .fault, routingKey: routingKey, values: values, file: file, function: function, line: line)
    }

    /// Logs a fault-level message with encodable payload.
    ///
    /// When to use: For critical conditions that should never occur.
    /// Example: application entered an unexpected, unrecoverable state.
    /// - Parameters:
    ///   - message: The message.
    ///   - routingKey: Optional routing key.
    ///   - data: Encodable fault context.
    @_disfavoredOverload
    static func fault<T: Encodable>(_ message: String, routingKey: String? = nil, _ data: T, file: String = #fileID, function: String = #function, line: Int = #line) {
        sendEvent(message, .fault, routingKey: routingKey, encodable: data, file: file, function: function, line: line)
    }

    /// Logs a fault-level message with raw JSON.
    ///
    /// When to use: For critical conditions that should never occur.
    /// Example: application entered an unexpected, unrecoverable state.
    /// - Parameters:
    ///   - message: The message.
    ///   - routingKey: Optional routing key.
    ///   - json: JSON payload.
    static func fault(_ message: String, routingKey: String? = nil, _ json: Data, file: String = #fileID, function: String = #function, line: Int = #line) {
        sendEvent(message, .fault, routingKey: routingKey, json: json, file: file, function: function, line: line)
    }

    // MARK: - Internal SendEvent Overloads

    private static func sendEvent(
        _ message: String,
        _ type: NexusEventType,
        routingKey: String?,
        values: [String: Any]? = nil,
        file: String,
        function: String,
        line: Int
    ) {
        let metadata = buildMetadata(type: type, routingKey: routingKey, file: file, function: function, line: line)
        let stringifiedValues = stringify(values)
        let event = NexusEvent(metadata: metadata, message: message, data: NexusEventData(values: stringifiedValues))
        shared.send(event)
    }

    private static func sendEvent<T: Encodable>(
        _ message: String,
        _ type: NexusEventType,
        routingKey: String?,
        encodable: T,
        file: String,
        function: String,
        line: Int
    ) {
        let metadata = buildMetadata(type: type, routingKey: routingKey, file: file, function: function, line: line)

        do {
            let json = try JSONEncoder().encode(encodable)
            let event = NexusEvent(metadata: metadata, message: message, data: NexusEventData(json: json))
            shared.send(event)
        } catch {
            let fallback = NexusEvent(
                metadata: metadata,
                message: "Encoding failed: \(error.localizedDescription)",
                data: NexusEventData(values: ["encoding_error": error.localizedDescription])
            )
            shared.send(fallback)
        }
    }

    private static func sendEvent(
        _ message: String,
        _ type: NexusEventType,
        routingKey: String?,
        json: Data,
        file: String,
        function: String,
        line: Int
    ) {
        let metadata = buildMetadata(type: type, routingKey: routingKey, file: file, function: function, line: line)
        let event = NexusEvent(metadata: metadata, message: message, data: NexusEventData(json: json))
        shared.send(event)
    }

    private static func buildMetadata(
        type: NexusEventType,
        routingKey: String?,
        file: String,
        function: String,
        line: Int
    ) -> NexusEventMetadata {
        let (bundleName, appVersion, deviceModel, osVersion) = Nexus.shared.metadata()
        return NexusEventMetadata(
            type: type,
            time: Date(),
            deviceModel: deviceModel,
            osVersion: osVersion,
            bundleName: bundleName,
            appVersion: appVersion,
            fileName: file,
            functionName: function,
            lineNumber: String(line),
            threadName: Thread.isMainThread ? "main" : "\(pthread_mach_thread_np(pthread_self()))",
            routingKey: routingKey
        )
    }
    
    private static func stringify(_ dict: [String: Any]?) -> [String: String]? {
        guard let dict = dict else { return nil }
        var result: [String: String] = [:]
        for (key, value) in dict {
            result[key] = String(describing: value)
        }
        return result
    }
}
