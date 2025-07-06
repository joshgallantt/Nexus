//
//  NexusDestinationRegistry.swift
//  Nexus
//
//  Created by Josh Gallant on 02/07/2025.
//

import Foundation

protocol NexusDestinationRegistryProtocol: Sendable {
    var destinations: [NexusDestinationDeliveryMode] { get async }
    func addDestination(_ destination: NexusDestination, mode: NexusDeliveryMode) async
}

public actor NexusDestinationRegistry: NexusDestinationRegistryProtocol {
    public static let shared = NexusDestinationRegistry()
    
    private var _destinations: [NexusDestinationDeliveryMode] = []
    private init() {}

    var destinations: [NexusDestinationDeliveryMode] {
        get { _destinations }
    }

    public func addDestination(_ destination: NexusDestination, mode: NexusDeliveryMode) {
        let delivery: NexusDestinationDeliveryMode
        switch mode {
        case .serial:
            delivery = .serial(NexusSerialActor(destination: destination))
        case .concurrent:
            delivery = .concurrent(destination)
        }
        _destinations.append(delivery)
    }
}

