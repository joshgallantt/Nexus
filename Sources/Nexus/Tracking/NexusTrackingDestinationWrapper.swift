//
//  NexusTrackingDestinationWrapper.swift
//  Nexus
//
//  Created by Josh Gallant on 02/07/2025.
//

import Foundation

// MARK: — Tracking Destination Wrapper

enum NexusTrackingDestinationWrapper {
    case serialised(SerialTrackingActor)
    case unsynchronised(NexusTrackingDestination)

    func track(entry: NexusTrackingEvent) {
        switch self {
        case .serialised(let actor):
            Task {
                await actor.enqueue(entry: entry)
            }
        case .unsynchronised(let dest):
            Task.detached(priority: .background) {
                await dest.track(
                    name: entry.name,
                    time: entry.time,
                    properties: entry.properties
                )
            }
        }
    }
}

actor SerialTrackingActor {
    let destination: NexusTrackingDestination

    init(destination: NexusTrackingDestination) {
        self.destination = destination
    }

    func enqueue(entry: NexusTrackingEvent) async {
        await destination.track(
            name: entry.name,
            time: entry.time,
            properties: entry.properties
        )
    }
}
