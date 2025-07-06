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
        // Setup Logging Destination
        #if DEBUG
        let setupLogger = NexusDebugLog()
        Nexus.addDestination(setupLogger, serialised: true)
        #endif

        // Example Logging
        Task.detached(priority: .userInitiated) {
            trackUserLanding()
        }
        
        fetchItemsFromAPI()
        enableNotifications()
        verifyUserEmail()
        getAccountTier()
        attemptSavingPreferences()
        unsafeForceUnwrap()

        exampleKeyValuePairs()
        exampleEncodable()
        exampleJSONObjects()
    }

    var body: some Scene {}
}

// MARK: - Sample functions generating logs

private func trackUserLanding() {
    Nexus.track("User viewed home screen")
}

private func fetchItemsFromAPI() {
    Nexus.debug("Fetched 12 items from API")
}

private func enableNotifications() {
    Nexus.info("User enabled notifications")
}

private func verifyUserEmail() {
    Nexus.notice("User verified email successfully!")
}

private func getAccountTier() {
    Nexus.warning("Falling back to free tier.")
}

private func attemptSavingPreferences() {
    Nexus.error("Failed to save user preferences")
}

private func unsafeForceUnwrap() {
    Nexus.fault("Why are you force unwrapping?")
}

// MARK: - Example Key-Value Pairs

private func exampleKeyValuePairs() {
    Nexus.debug("Key-value pairs Example", routingKey: "routingkey", [
        "count": 5,
        "status": "ok",
        "user": [
            "id": 7,
            "role": "tester"
        ]
    ])
}


// MARK: - Example JSON Payloads

private func exampleJSONObjects() {
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
    
    let array: [[String: Any]] = [
        ["id": 1, "name": "Item A"],
        ["id": 2, "name": "Item B"]
    ]

    if let data = try? JSONSerialization.data(withJSONObject: array, options: []) {
        Nexus.debug("Top-level array JSON", routingKey: "routingkey", data)
    }


    if let data = try? JSONSerialization.data(withJSONObject: json, options: []) {
        Nexus.debug("Top-level object JSON", routingKey: "routingkey", data)
    }
}

// MARK: - Example Three-Level Nested Encodable Types

struct UserProfile: Encodable {
    let email: String
    let verified: Bool
}

struct User: Encodable {
    let id: Int
    let name: String
    let roles: [String]
    let profile: UserProfile
}

struct UserEvent: Encodable {
    let active: Bool
    let sessionId: String
    let user: User
}

private func exampleEncodable() {
    let event = UserEvent(
        active: true,
        sessionId: "abc123",
        user: User(
            id: 42,
            name: "Alan Turing",
            roles: ["admin", "mathematician"],
            profile: UserProfile(
                email: "alan@bombe.com",
                verified: true
            )
        )
    )
    Nexus.debug("Three-level Encodable object", routingKey: "routingkey", event)
}
