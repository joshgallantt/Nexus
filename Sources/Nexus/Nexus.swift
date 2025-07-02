//
//  NexusLog.swift
//  Nexus
//
//  Created by Josh Gallant on 02/07/2025.
//

import SwiftUI
import Foundation

// MARK: — Nexus Actor

public actor Nexus {
    public static let shared = Nexus(
        loggingStore: NexusLoggingDestinationStore.shared,
        trackingStore: NexusTrackingDestinationStore.shared
    )

    private let loggingStore: LoggingDestinationStore
    private let trackingStore: TrackingDestinationStore

    // Log stream
    private let logStream: AsyncStream<NexusLoggingEvent>
    private let logContinuation: AsyncStream<NexusLoggingEvent>.Continuation

    // Tracking stream
    private let trackStream: AsyncStream<NexusTrackingEvent>
    private let trackContinuation: AsyncStream<NexusTrackingEvent>.Continuation

    internal init(
        loggingStore: LoggingDestinationStore,
        trackingStore: TrackingDestinationStore
    ) {
        self.loggingStore = loggingStore
        self.trackingStore = trackingStore

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
        let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "Unknown Bundle"
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let entry = NexusLoggingEvent(
            level: level,
            time: Date(),
            bundleName: bundleName,
            appVersion: appVersion,
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

    private nonisolated func log(_ entry: NexusLoggingEvent) {
        logContinuation.yield(entry)
    }

    private nonisolated func track(_ entry: NexusTrackingEvent) {
        trackContinuation.yield(entry)
    }

    // MARK: — Processors

    private func processLog(_ entry: NexusLoggingEvent) async {
        let wrappers = loggingStore.wrappers

        await withTaskGroup(of: Void.self) { group in
            for wrapper in wrappers {
                group.addTask {
                    wrapper.log(entry: entry)
                }
            }
        }
    }

    private func processTrack(_ entry: NexusTrackingEvent) async {
        let wrappers = trackingStore.wrappers

        await withTaskGroup(of: Void.self) { group in
            for wrapper in wrappers {
                group.addTask {
                    wrapper.track(entry: entry)
                }
            }
        }
    }
}
