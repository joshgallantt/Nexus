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

        // Global user context
        let context = UserEventContext(
            userId: 123,
            name: "Josh Gallant",
            isPremium: true,
            createdAt: Date()
        )

        trackUserLanding()
        fetchItemsFromAPI()
        enableNotifications(context: context)
        verifyUserEmail()
        getAccountTier()
        attemptSavingPreferences()
        unsafeForceUnwrap()

        // JSON test payloads
        testJSONObject()
        testJSONArray()
    }

    var body: some Scene {}
}

// MARK: - Sample functions generating logs

private func trackUserLanding() {
    Nexus.track("User viewed home screen", routingKey: "routing key")
}

private func fetchItemsFromAPI() {
    Task.detached {
        Nexus.debug("Fetched 12 items from API", [
            "endpoint": "/api/items",
            "duration": "132ms"
        ],)
    }
}

private func enableNotifications(context: UserEventContext) {
    Nexus.info("User enabled notifications", context)
}

private func verifyUserEmail() {
    Nexus.notice("User verified email", [
        "method": "magic_link"
    ])
}

private func getAccountTier() {
    Nexus.warning("Unable to determine tier, falling back to free tier.")
}

private func attemptSavingPreferences() {
    Nexus.error("Failed to save user preferences", [
        "error": "disk full"
    ])
}

private func unsafeForceUnwrap() {
    Nexus.fault("Why are you force unwrapping?")
}

// MARK: - Context model

struct UserEventContext: Encodable {
    let userId: Int
    let name: String
    let isPremium: Bool
    let createdAt: Date
}

// MARK: - Test JSON Payloads

private func testJSONObject() {
    let json: [String: Any] = [
        "active": true,
        "features": ["logging", "analytics"],
        "sessionId": "abc123",
        "timestamp": "2025-07-05T16:42:00Z",
        "user": [
            "id": 1,
            "name": "Ada Lovelace",
            "roles": ["admin", "developer"],
            "profile": [
                "email": "ada@example.com",
                "verified": true
            ]
        ],
        "tags": [],
        "config": [
            "env": "prod",
            "flags": [
                "debug": false,
                "beta": true
            ]
        ]
    ]


    if let data = try? JSONSerialization.data(withJSONObject: json, options: []) {
        Nexus.debug("Top-level object JSON", routingKey: "routingkey", data)
    }
}

private func testJSONArray() {
    let array: [[String: Any]] = [
        ["id": 1, "name": "Item A"],
        ["id": 2, "name": "Item B"]
    ]

    if let data = try? JSONSerialization.data(withJSONObject: array, options: []) {
        Nexus.debug("Top-level array JSON", routingKey: "routingkey", data)
    }
}
