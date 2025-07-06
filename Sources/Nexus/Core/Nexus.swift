//
//  Nexus.swift
//  Nexus
//
//  Created by Josh Gallant on 02/07/2025.
//

import SwiftUI
import Foundation

public actor Nexus {

    public static let shared = Nexus(
        eventStore: NexusDestinationStore.shared
    )

    private let eventStore: NexusDestinationStore
    private let eventStream: AsyncStream<NexusEvent>
    private let eventContinuation: AsyncStream<NexusEvent>.Continuation

    private let bundleName: String
    private let appVersion: String
    private let deviceModel: String
    private let osVersion: String

    internal init(eventStore: NexusDestinationStore) {
        self.eventStore = eventStore
        (eventStream, eventContinuation) = AsyncStream.makeStream()

        self.bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "Unknown Bundle"
        self.appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown Version"
        self.deviceModel = NexusDeviceInfo.model
        self.osVersion = NexusDeviceInfo.osVersion

        Task(priority: .background) {
            for await entry in eventStream {
                await processEvent(entry)
            }
        }
    }

    package nonisolated func metadata() -> (bundleName: String, appVersion: String, deviceModel: String, osVersion: String) {
        (bundleName, appVersion, deviceModel, osVersion)
    }

    package nonisolated func send(_ entry: NexusEvent) {
        eventContinuation.yield(entry)
    }

    private func processEvent(_ event: NexusEvent) async {
        let wrappers = await eventStore.destinations

        await withTaskGroup(of: Void.self) { group in
            for wrapper in wrappers {
                group.addTask(priority: .background) {
                    wrapper.send(event)
                }
            }
        }
    }
}
