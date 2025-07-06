//
//  NexusSerialActor.swift
//  Nexus
//
//  Created by Josh Gallant on 02/07/2025.
//


package actor NexusSerialActor {
    let destination: NexusDestination

    init(destination: NexusDestination) {
        self.destination = destination
    }

    func enqueue(_ event: NexusEvent) async {
        await destination.send(event)
    }
}

