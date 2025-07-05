//
//  NexusTimeFormatter.swift
//  Nexus
//
//  Created by Josh Gallant on 05/07/2025.
//

import Foundation

package struct NexusTimeFormatter: Sendable {
    static let shared = NexusTimeFormatter()

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
