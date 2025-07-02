//
//  NexusLogLevel.swift
//  NexusLogger
//
//  Created by Josh Gallant on 01/07/2025.
//

/// Represents the severity of a log message..
/// Ordered from least to most critical: `.debug` < `.info` < `.notice` < `.warning` < `.error` < `.fault`.
public enum NexusLogLevel: Int, Sendable, Comparable, CaseIterable {

    /// Very verbose diagnostic messages for in-depth troubleshooting.
    /// Hidden by default in Console.app (OSLogType.debug).
    /// Example: view lifecycle timings, full request/response payload dumps.
    case debug

    /// Messages recording the normal operation of the system.
    /// Hidden by default unless “Include Info” is enabled (OSLogType.info).
    /// Example: user tapped a button, screen appeared, session refreshed.
    case info

    /// Normal but significant conditions that may require monitoring.
    /// Always recorded by default (OSLogType.default).
    /// Example: cache hits, number of items parsed, minor navigation events.
    case notice

    /// Recoverable issues or unusual conditions.
    /// Example: missing optional field, entering degraded mode.
    case warning

    /// Expected but unrecoverable errors that require developer attention.
    /// Example: decoding failure, file not found, unauthorized response.
    case error

    /// Entered a expected and critical state that should never occur.
    case fault

    /// Emoji for quick visual identification in logs.
    public var emoji: String {
        switch self {
        case .debug:    return "⬜"
        case .info:     return "🟩"
        case .notice:   return "🟦"
        case .warning:  return "🟨"
        case .error:    return "🟧"
        case .fault:    return "🟥"
        }
    }

    /// Uppercase string name for use in log formatting.
    public var name: String {
        switch self {
        case .debug:     return "DEBUG"
        case .info:      return "INFO"
        case .notice:    return "NOTICE"
        case .warning:   return "WARNING"
        case .error:     return "ERROR"
        case .fault:     return "FAULT"
        }
    }

    /// Compares severity between two log levels.
    public static func < (lhs: NexusLogLevel, rhs: NexusLogLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
