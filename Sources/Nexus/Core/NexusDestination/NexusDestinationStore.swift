//
//  NexusDestinationStore.swift
//  Nexus
//
//  Created by Josh Gallant on 02/07/2025.
//

import Foundation

// MARK: — Protocol for Testability

protocol NexusDestinationStoreProtocol: Sendable {
    var destinations: [NexusDestinationStrategy] { get async }
    func addDestination(_ destination: NexusDestination, serialised: Bool) async
}

// MARK: — Event Destination Store

public actor NexusDestinationStore: NexusDestinationStoreProtocol {
    public static let shared = NexusDestinationStore()
    
    private var _destinations: [NexusDestinationStrategy] = []
    private init() {}

    var destinations: [NexusDestinationStrategy] {
        get { _destinations }
    }

    public func addDestination(_ destination: NexusDestination, serialised: Bool) {
        let destinationWithStrategy: NexusDestinationStrategy = serialised
            ? .serialised(NexusSerialActor(destination: destination))
            : .unsynchronised(destination)
        _destinations.append(destinationWithStrategy)
    }
}

