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
        //        Nexus.addTrackingDestination(DefaultFirebaseDestination())
        Nexus.addDestination(OSLoggerHumanReadable(), serialised: true)
        
        Nexus.sendEvent("User Tapped Some Button!", .track)
        Nexus.sendEvent("User tapped login button", .debug)
        Nexus.sendEvent("User tapped login button", .info)
        Nexus.sendEvent("User tapped login button", .notice)
        Nexus.sendEvent("User tapped login button", .warning)
        Nexus.sendEvent("User tapped login button", .error)
        Nexus.track("hi")
        
        
        Nexus.sendEvent("User tapped login button", .fault)

        Nexus.sendEvent(
            "User tapped login button",
            attributes: [
                "view": "LoginViewController",
                "text": "Login"
            ]
        )

        Nexus.sendEvent("User tapped login button", .notice, attributes: [
            "userId": "12345",
            "device": "iPhone15,2"
        ])

        Nexus.sendEvent("User tapped login button", .warning, attributes: [
            "issue": "location permission not determined",
            "fallbackUsed": "true"
        ])

        Nexus.sendEvent("User tapped login button", .error, attributes: [
            "error": "network_unreachable",
            "retryCount": "2"
        ])

        Nexus.sendEvent("User tapped login button", .fault, attributes: [
            "reason": "unexpected nil during force unwrap",
            "file": "LoginManager.swift"
        ])
    }

    var body: some Scene {}
}
