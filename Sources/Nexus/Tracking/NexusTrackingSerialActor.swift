//
//  NexusTrackingSerialActor.swift
//  Nexus
//
//  Created by Josh Gallant on 02/07/2025.
//


actor NexusTrackingSerialActor {
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
