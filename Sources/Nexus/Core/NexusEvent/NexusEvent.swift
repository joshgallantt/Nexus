//
//  NexusEvent.swift
//  Nexus
//
//  Created by Josh Gallant on 03/07/2025.
//

public struct NexusEvent: Sendable {
    public let metadata: NexusEventMetadata
    public let message: String
    public let data: NexusEventData?

    public init(
        metadata: NexusEventMetadata,
        message: String,
        data: NexusEventData? = nil
    ) {
        self.metadata = metadata
        self.message = message
        self.data = data
    }
}
