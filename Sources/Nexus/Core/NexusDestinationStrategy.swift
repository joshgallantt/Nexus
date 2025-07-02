//
//  NexusDestinationStrategy.swift
//  Nexus
//
//  Created by Josh Gallant on 02/07/2025.
//

import Foundation

// MARK: — Logging Destination Wrapper

enum NexusDestinationStrategy {
    case serialised(NexusSerialActor)
    case unsynchronised(NexusDestination)

    func send(_ event: NexusEvent) {
        switch self {
        case .serialised(let actor):
            Task {
                await actor.enqueue(event)
            }
        case .unsynchronised(let destination):
            Task.detached(priority: .background) {
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
    }
}
