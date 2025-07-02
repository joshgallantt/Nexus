//
//  NexusTrackingDestinationStore.swift
//  Nexus
//
//  Created by Josh Gallant on 02/07/2025.
//

import Foundation

// MARK: — Protocol for Testability

protocol TrackingDestinationStore {
    var wrappers: [NexusTrackingDestinationWrapper] { get }
    func addDestination(_ destination: NexusTrackingDestination, serialised: Bool)
}

// MARK: — Tracking Destination Store

public final class NexusTrackingDestinationStore: @unchecked Sendable, TrackingDestinationStore {
    public static let shared = NexusTrackingDestinationStore()

    private var _wrappers: [NexusTrackingDestinationWrapper] = []
    private let queue = DispatchQueue(label: "com.nexuslogger.tracking.destinations.queue")

    private init() {}

    var wrappers: [NexusTrackingDestinationWrapper] {
        queue.sync { _wrappers }
    }

    public func addDestination(_ destination: NexusTrackingDestination, serialised: Bool = false) {
        let wrapper: NexusTrackingDestinationWrapper = serialised
            ? .serialised(NexusTrackingSerialActor(destination: destination))
            : .unsynchronised(destination)

        queue.sync {
            _wrappers.append(wrapper)
        }
    }
}
