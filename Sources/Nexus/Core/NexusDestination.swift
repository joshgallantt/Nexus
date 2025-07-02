//
//  NexusDestination.swift
//  Nexus
//
//  Created by Josh Gallant on 01/07/2025.
//

import Foundation

/// Protocol for a Nexus Log Destination (e.g., system log, remote service).
public protocol NexusDestination: Sendable {
    func send(
        type: NexusEventType,
        time: Date,
        bundleName: String,
        appVersion: String,
        fileName: String,
        functionName: String,
        lineNumber: String,
        threadName: String,
        message: String,
        attributes: [String: String]?
    ) async
}

