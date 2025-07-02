//
//  NexusLog.swift
//  Nexus
//
//  Created by Josh Gallant on 02/07/2025.
//


import SwiftUI
import Foundation

// MARK: — Logging Destination Wrapper

enum DestinationLoggingWrapper {
    case serialised(SerialLoggingActor)
    case unsynchronised(NexusLoggingDestination)

    func log(entry: NexusLog) {
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

    func enqueue(entry: NexusLog) async {
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

public final class NexusLoggingDestinationStore: @unchecked Sendable {
    public static let shared = NexusLoggingDestinationStore()

    private let queue = DispatchQueue(label: "com.nexuslogger.logging.destinations.queue")
    private var _wrappers: [DestinationLoggingWrapper] = []

    private init() {}

    var wrappers: [DestinationLoggingWrapper] {
        queue.sync { _wrappers }
    }

    public func addDestination(_ destination: NexusLoggingDestination, serialised: Bool) {
        let wrapper: DestinationLoggingWrapper = serialised
            ? .serialised(SerialLoggingActor(destination: destination))
            : .unsynchronised(destination)

        queue.sync {
            _wrappers.append(wrapper)
        }
    }
}

// MARK: — Tracking Destination Wrapper

enum DestinationTrackingWrapper {
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

public final class NexusTrackingDestinationStore: @unchecked Sendable {
    public static let shared = NexusTrackingDestinationStore()
    
    private var _wrappers: [DestinationTrackingWrapper] = []
    private let queue = DispatchQueue(label: "com.nexuslogger.tracking.destinations.queue")
    private init() {}

    var wrappers: [DestinationTrackingWrapper] {
        queue.sync { _wrappers }
    }

    public func addDestination(_ destination: NexusTrackingDestination, serialised: Bool = false) {
        let wrapper: DestinationTrackingWrapper = serialised
            ? .serialised(SerialTrackingActor(destination: destination))
            : .unsynchronised(destination)

        queue.sync {
            _wrappers.append(wrapper)
        }
    }
}

// MARK: — Nexus Actor

public actor Nexus {
    public static let shared = Nexus()

    // 1) Log stream
    private let logStream: AsyncStream<NexusLog>
    private let logContinuation: AsyncStream<NexusLog>.Continuation

    // 2) Tracking stream
    private let trackStream: AsyncStream<NexusTrackingEvent>
    private let trackContinuation: AsyncStream<NexusTrackingEvent>.Continuation

    private init() {
        (logStream, logContinuation) = AsyncStream.makeStream()
        (trackStream, trackContinuation) = AsyncStream.makeStream()

        Task {
            for await entry in logStream {
                await processLog(entry)
            }
        }

        Task {
            for await entry in trackStream {
                await processTrack(entry)
            }
        }
    }

    // MARK: — Public Static API

    public nonisolated static func addLoggingDestination(
        _ dest: NexusLoggingDestination,
        serialised: Bool = false
    ) {
        NexusLoggingDestinationStore.shared.addDestination(dest, serialised: serialised)
    }

    public nonisolated static func addTrackingDestination(
        _ dest: NexusTrackingDestination,
        serialised: Bool = false
    ) {
        NexusTrackingDestinationStore.shared.addDestination(dest, serialised: serialised)
    }

    public nonisolated static func log(
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
        shared.log(entry)
    }

    public nonisolated static func track(
        _ name: String,
        _ properties: [String: String]? = nil,
        time: Date = Date()
    ) {
        let entry = NexusTrackingEvent(name: name, time: time, properties: properties)
        shared.track(entry)
    }

    // MARK: — Nonisolated Instance Yielders

    private nonisolated func log(_ entry: NexusLog) {
        logContinuation.yield(entry)
    }

    private nonisolated func track(_ entry: NexusTrackingEvent) {
        trackContinuation.yield(entry)
    }

    // MARK: — Processors

    private func processLog(_ entry: NexusLog) async {
        let wrappers = NexusLoggingDestinationStore.shared.wrappers

        await withTaskGroup(of: Void.self) { group in
            for wrapper in wrappers {
                group.addTask {
                    wrapper.log(entry: entry)
                }
            }
        }
    }

    private func processTrack(_ entry: NexusTrackingEvent) async {
        let wrappers = NexusTrackingDestinationStore.shared.wrappers

        await withTaskGroup(of: Void.self) { group in
            for wrapper in wrappers {
                group.addTask {
                    wrapper.track(entry: entry)
                }
            }
        }
    }
}
