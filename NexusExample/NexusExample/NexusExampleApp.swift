//
//  NexusExampleApp.swift
//  NexusExample
//
//  Created by Josh Gallant on 02/07/2025.
//

import SwiftUI
import Nexus

@main
struct NexusExampleApp: App {
    init() {
        // Logging setup
        Nexus.addDestination(OSLoggerHumanReadable(showData: true), serialised: true)
//        Nexus.addDestination(OSLoggerMachineParsable(), serialised: true)

        // Global user context
        let context = UserEventContext(
            userId: 123,
            name: "Josh Gallant",
            isPremium: true,
            createdAt: Date()
        )

        Nexus.track("User viewed home screen")

        Task.detached {
            Nexus.debug("Fetched 12 items from API", [
                "endpoint": "/api/items",
                "duration": "132ms"
            ])
        }

        Nexus.info("User enabled notifications", context)

        Nexus.notice("User verified email", [
            "method": "magic_link"
        ])

        Nexus.warning("App background fetch took unusually long", [
            "duration": "29s"
        ])

        Nexus.error("Failed to save user preferences", [
            "error": "disk full"
        ])

        Nexus.fault("Why are you force unwrapping?")
    }

    var body: some Scene {}
}

struct UserEventContext: Encodable {
    let userId: Int
    let name: String
    let isPremium: Bool
    let createdAt: Date
}
