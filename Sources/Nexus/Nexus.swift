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
        eventStore: NexusDestinationStore.shared
    )

    private let eventStore: NexusDestinationStore

    // Log stream
    private let eventStream: AsyncStream<NexusEvent>
    private let eventContinuation: AsyncStream<NexusEvent>.Continuation

    internal init(
        eventStore: NexusDestinationStore
    ) {
        self.eventStore = eventStore

        (eventStream, eventContinuation) = AsyncStream.makeStream()

        Task {
            for await entry in eventStream {
                await processEvent(entry)
            }
        }
    }

    // MARK: — Public Static API

    public nonisolated static func addDestination(
        _ dest: NexusDestination,
        serialised: Bool = false
    ) {
        NexusDestinationStore.shared.addDestination(dest, serialised: serialised)
    }

    public nonisolated static func log(
        _ message: String,
        _ level: NexusEventType = .info,
        attributes: [String: String]? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "Unknown Bundle"
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let entry = NexusEvent(
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
        shared.send(entry)
    }

    // MARK: — Nonisolated Instance Yielders

    private nonisolated func send(_ entry: NexusEvent) {
        eventContinuation.yield(entry)
    }

    // MARK: — Processors

    private func processEvent(_ event: NexusEvent) async {
        let wrappers = eventStore.destinations

        await withTaskGroup(of: Void.self) { group in
            for wrapper in wrappers {
                group.addTask {
                    wrapper.send(event)
                }
            }
        }
    }
}
