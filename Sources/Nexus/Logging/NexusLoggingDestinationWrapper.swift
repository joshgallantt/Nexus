//
//  NexusLoggingDestinationWrapper.swift
//  Nexus
//
//  Created by Josh Gallant on 02/07/2025.
//

import Foundation

// MARK: — Logging Destination Wrapper

enum NexusLoggingDestinationWrapper {
    case serialised(SerialLoggingActor)
    case unsynchronised(NexusLoggingDestination)

    func log(entry: NexusLoggingEvent) {
        switch self {
        case .serialised(let actor):
            Task {
                await actor.enqueue(entry: entry)
            }
        case .unsynchronised(let dest):
            Task.detached(priority: .background) {
                await dest.log(
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
    }
}

actor SerialLoggingActor {
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
