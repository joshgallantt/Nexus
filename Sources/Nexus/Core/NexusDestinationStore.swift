//
//  NexusDestinationStore.swift
//  Nexus
//
//  Created by Josh Gallant on 02/07/2025.
//

import Foundation

// MARK: — Protocol for Testability

protocol NexusDestinationStoreProtocol {
    var destinations: [NexusDestinationStrategy] { get }
    func addDestination(_ destination: NexusDestination, serialised: Bool)
}

// MARK: — Event Destination Store

public final class NexusDestinationStore: @unchecked Sendable, NexusDestinationStoreProtocol {
    public static let shared = NexusDestinationStore()

    private let queue = DispatchQueue(label: "com.nexus.destinations.queue")
    private var _destinations: [NexusDestinationStrategy] = []

    private init() {}

    var destinations: [NexusDestinationStrategy] {
        queue.sync { _destinations }
    }

    public func addDestination(_ destination: NexusDestination, serialised: Bool) {
        let wrapper: NexusDestinationStrategy = serialised
            ? .serialised(NexusSerialActor(destination: destination))
            : .unsynchronised(destination)

        queue.sync {
            _destinations.append(wrapper)
        }
    }
}
