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
    }

    var body: some Scene {}
}

// MARK: - Sample functions generating logs

private func trackUserLanding() {
    Nexus.track("User viewed home screen")
}

private func fetchItemsFromAPI() {
    Task.detached {
        Nexus.debug("Fetched 12 items from API", [
            "endpoint": "/api/items",
            "duration": "132ms"
        ])
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
