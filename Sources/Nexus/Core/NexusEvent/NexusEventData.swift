//
//  NexusEventData.swift
//  Nexus
//
//  Created by Josh Gallant on 03/07/2025.
//


import Foundation

/// Represents additional diagnostic or structured data attached to a log event.
public struct NexusEventData: Sendable {
    /// Flat string key-value pairs, suitable for filtering, tags, metrics.
    public let values: [String: String]?

    /// Optional raw JSON payload for rich, structured data.
    public let json: Data?

    public init(values: [String: String]? = nil, json: Data? = nil) {
        self.values = values
        self.json = json
    }
}
