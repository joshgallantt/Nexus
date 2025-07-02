//
//  NexusTrackingDestination.swift
//  Nexus
//
//  Created by Josh Gallant on 02/07/2025.
//

import Foundation

public protocol NexusTrackingDestination: Sendable {
    func track(
        name: String,
        time: Date,
        properties: [String: String]?
    ) async
}
