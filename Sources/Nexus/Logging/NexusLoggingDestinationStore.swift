//
//  NexusLoggingDestinationStore.swift
//  Nexus
//
//  Created by Josh Gallant on 02/07/2025.
//

import Foundation

// MARK: — Protocol for Testability

protocol LoggingDestinationStore {
    var wrappers: [NexusLoggingDestinationWrapper] { get }
    func addDestination(_ destination: NexusLoggingDestination, serialised: Bool)
}

// MARK: — Logging Destination Store

public final class NexusLoggingDestinationStore: @unchecked Sendable, LoggingDestinationStore {
    public static let shared = NexusLoggingDestinationStore()

    private let queue = DispatchQueue(label: "com.nexuslogger.logging.destinations.queue")
    private var _wrappers: [NexusLoggingDestinationWrapper] = []

    private init() {}

    var wrappers: [NexusLoggingDestinationWrapper] {
        queue.sync { _wrappers }
    }

    public func addDestination(_ destination: NexusLoggingDestination, serialised: Bool) {
        let wrapper: NexusLoggingDestinationWrapper = serialised
            ? .serialised(NexusLoggingSerialActor(destination: destination))
            : .unsynchronised(destination)

        queue.sync {
            _wrappers.append(wrapper)
        }
    }
}
