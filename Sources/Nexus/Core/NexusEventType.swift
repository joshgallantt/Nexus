//
//  NexusEventType.swift
//  Nexus
//
//  Created by Josh Gallant on 01/07/2025.
//

import os

/// Represents the severity of a log message..
/// Ordered from least to most critical: `.debug` < `.track < `.info` < `.notice` < `.warning` < `.error` < `.fault`.
public enum NexusEventType: Int, Sendable, Comparable, CaseIterable {
    /// Very verbose diagnostic messages for in-depth troubleshooting.
    /// Hidden by default in Console.app (OSLogType.debug).
    /// Example: view lifecycle timings, full request/response payload dumps.
    case debug
    
    /// Used for tracking or analytics.
    /// Hidden by default unless “Include Info” is enabled (OSLogType.info).
    case track

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
        case .track:    return "🟫"
        case .debug:    return "🟪"
        case .info:     return "🟦"
        case .notice:   return "🟩"
        case .warning:  return "🟨"
        case .error:    return "🟧"
        case .fault:    return "🟥"
        }
    }

    /// Uppercase string name for use in log formatting.
    public var name: String {
        switch self {
        case .track:     return "TRACKING"
        case .debug:     return "DEBUG"
        case .info:      return "INFO"
        case .notice:    return "NOTICE"
        case .warning:   return "WARNING"
        case .error:     return "ERROR"
        case .fault:     return "FAULT"
        }
    }
    
    public var defaultOSLogType: OSLogType {
        switch self {
        case .debug:   return .debug
        case .track:   return .info
        case .info:    return .info
        case .notice:  return .default
        case .warning, .error: return .error
        case .fault:   return .fault
        }
    }

    /// Compares severity between two log types.
    public static func < (lhs: NexusEventType, rhs: NexusEventType) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

