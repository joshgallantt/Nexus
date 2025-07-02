//
//  NexusLog.swift
//  NexusLogger
//
//  Created by Josh Gallant on 01/07/2025.
//

import Foundation

package struct NexusLoggingEvent: Sendable {
    public let level: NexusLogLevel
    public let time: Date
    public let bundleName: String
    public let appVersion: String
    public let fileName: String
    public let functionName: String
    public let lineNumber: String
    public let threadName: String
    public let message: String
    public let attributes: [String: String]?
}
