//
//  NexusLoggingSerialActor.swift
//  Nexus
//
//  Created by Josh Gallant on 02/07/2025.
//


actor NexusLoggingSerialActor {
    let destination: NexusLoggingDestination

    init(destination: NexusLoggingDestination) {
        self.destination = destination
    }

    func enqueue(entry: NexusLoggingEvent) async {
        await destination.log(
            level: entry.level,
            time: entry.time,
            bundleName: entry.bundleName,
            appVersion: entry.appVersion,
            fileName: entry.fileName,
            functionName: entry.functionName,
            lineNumber: entry.lineNumber,
            threadName: entry.threadName,
            message: entry.message,
            attributes: entry.attributes
        )
    }
}
