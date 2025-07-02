//
//  NexusSerialActor.swift
//  Nexus
//
//  Created by Josh Gallant on 02/07/2025.
//


actor NexusSerialActor {
    let destination: NexusDestination

    init(destination: NexusDestination) {
        self.destination = destination
    }

    func enqueue(_ event: NexusEvent) async {
        await destination.send(
            type: event.type,
            time: event.time,
            bundleName: event.bundleName,
            appVersion: event.appVersion,
            fileName: event.fileName,
            functionName: event.functionName,
            lineNumber: event.lineNumber,
            threadName: event.threadName,
            message: event.message,
            attributes: event.attributes
        )
    }
}
