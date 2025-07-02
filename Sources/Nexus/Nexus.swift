//
//  Nexus.swift
//  Nexus
//
//  Created by Josh Gallant on 02/07/2025.
//

import SwiftUI
import Foundation

// MARK: — Destination Stores

public actor NexusLoggingDestinationStore {
    public static let shared = NexusLoggingDestinationStore()
    private var destinations: [NexusLoggingDestination] = []
    
    public func addDestination(_ destination: NexusLoggingDestination) {
        destinations.append(destination)
    }
    
    public func allDestinations() -> [NexusLoggingDestination] {
        destinations
    }
}

public actor NexusTrackingDestinationStore {
    public static let shared = NexusTrackingDestinationStore()
    private var destinations: [NexusTrackingDestination] = []
    
    public func addDestination(_ destination: NexusTrackingDestination) {
        destinations.append(destination)
    }
    
    public func allDestinations() -> [NexusTrackingDestination] {
        destinations
    }
}

// MARK: — Nexus Actor

public actor Nexus {
    public static let shared = Nexus()
    
    // Streams with buffering limit to prevent memory blowup
    private let logStream: AsyncStream<NexusLog>
    private let logContinuation: AsyncStream<NexusLog>.Continuation
    
    private let trackStream: AsyncStream<NexusTrackingEvent>
    private let trackContinuation: AsyncStream<NexusTrackingEvent>.Continuation
    
    private init() {
        (logStream, logContinuation) = AsyncStream.makeStream(bufferingPolicy: .bufferingOldest(500))
        (trackStream, trackContinuation) = AsyncStream.makeStream(bufferingPolicy: .bufferingOldest(500))

        Task(priority: .utility) {
            for await entry in self.logStream {
                await self.processLog(entry)
            }
        }

        Task(priority: .utility) {
            for await entry in self.trackStream {
                await self.processTrack(entry)
            }
        }
    }

    
    // MARK: — Public Static API
    
    public static func addLoggingDestination(
        _ dest: NexusLoggingDestination,
        serialised: Bool? = true
    ) {
        let finalDest: NexusLoggingDestination
        if serialised != false {
            finalDest = NexusSerializedLoggingDestination(wrapping: dest)
        } else {
            finalDest = dest
        }

        Task {
            await NexusLoggingDestinationStore.shared.addDestination(finalDest)
        }
    }

    public static func addTrackingDestination(
        _ dest: NexusTrackingDestination,
        serialised: Bool? = true
    ) {
        let finalDest: NexusTrackingDestination
        if serialised != false {
            finalDest = NexusSerializedTrackingDestination(wrapping: dest)
        } else {
            finalDest = dest
        }

        Task {
            await NexusTrackingDestinationStore.shared.addDestination(finalDest)
        }
    }

    public static func log(
        _ message: String,
        _ level: NexusLogLevel = .info,
        attributes: [String: String]? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let entry = NexusLog(
            level: level,
            time: Date(),
            bundleName: Bundle.main.bundleIdentifier ?? "",
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "",
            fileName: (file as NSString).lastPathComponent,
            functionName: function,
            lineNumber: String(line),
            threadName: Thread.isMainThread
                ? "main"
                : "thread-\(pthread_mach_thread_np(pthread_self()))",
            message: message,
            attributes: attributes
        )
        
        Task {
            await shared.log(entry)
        }
    }

    public static func track(
        _ name: String,
        _ properties: [String: String]? = nil,
        time: Date = Date()
    ) {
        let entry = NexusTrackingEvent(name: name, time: time, properties: properties)
        Task {
            await shared.track(entry)
        }
    }

    // MARK: — Actor-isolated Methods

    private func log(_ entry: NexusLog) {
        logContinuation.yield(entry)
    }

    private func track(_ entry: NexusTrackingEvent) {
        trackContinuation.yield(entry)
    }

    private func processLog(_ entry: NexusLog) async {
        let destinations = await NexusLoggingDestinationStore.shared.allDestinations()
        
        await withTaskGroup(of: Void.self) { group in
            for destination in destinations {
                group.addTask {
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
        }
    }

    private func processTrack(_ entry: NexusTrackingEvent) async {
        let dests = await NexusTrackingDestinationStore.shared.allDestinations()
        await withTaskGroup(of: Void.self) { group in
            for dest in dests {
                group.addTask {
                    await dest.track(
                        name: entry.name,
                        time: entry.time,
                        properties: entry.properties
                    )
                }
            }
        }
    }
}

//
//  NexusSerializedTrackingDestination.swift
//  Nexus
//
//  Created by Josh Gallant on 02/07/2025.
//

import Foundation

package actor NexusSerializedTrackingDestination: NexusTrackingDestination {
    private let wrapped: NexusTrackingDestination

    package init(wrapping destination: NexusTrackingDestination) {
        self.wrapped = destination
    }

    package func track(
        name: String,
        time: Date,
        properties: [String : String]?
    ) async {
        await wrapped.track(name: name, time: time, properties: properties)
    }
}

//
//  NexusSerializedLoggingDestination.swift
//  Nexus
//
//  Created by Josh Gallant on 02/07/2025.
//

import Foundation

package actor NexusSerializedLoggingDestination: NexusLoggingDestination {
    private let wrapped: NexusLoggingDestination

    package init(wrapping destination: NexusLoggingDestination) {
        self.wrapped = destination
    }

    package func log(
        level: NexusLogLevel,
        time: Date,
        bundleName: String,
        appVersion: String,
        fileName: String,
        functionName: String,
        lineNumber: String,
        threadName: String,
        message: String,
        attributes: [String : String]?
    ) async {
        await wrapped.log(
            level: level,
            time: time,
            bundleName: bundleName,
            appVersion: appVersion,
            fileName: fileName,
            functionName: functionName,
            lineNumber: lineNumber,
            threadName: threadName,
            message: message,
            attributes: attributes
        )
    }
}
