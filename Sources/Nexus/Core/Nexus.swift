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
        eventStore: NexusDestinationRegistry.shared
    )

    private let eventStore: NexusDestinationRegistry
    private let eventStream: AsyncStream<NexusEvent>
    private let eventContinuation: AsyncStream<NexusEvent>.Continuation

    private let bundleName: String
    private let appVersion: String
    private let deviceModel: String
    private let osVersion: String

    internal init(eventStore: NexusDestinationRegistry) {
        self.eventStore = eventStore
        (eventStream, eventContinuation) = AsyncStream.makeStream(
            bufferingPolicy: .bufferingNewest(1000)
        )

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
        let destinations = await eventStore.destinations

        await withTaskGroup(of: Void.self) { group in
            for destination in destinations {
                group.addTask(priority: .background) {
                    destination.send(event)
                }
            }
        }
    }
}
