//
//  NexusDestination.swift
//  Nexus
//
//  Created by Josh Gallant on 01/07/2025.
//

import Foundation

/// Protocol for a Nexus Log Destination (e.g., system log, remote service).
public protocol NexusDestination: Sendable {
    func send(_ event: NexusEvent) async
}
