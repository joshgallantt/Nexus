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
        
        Nexus.log("User Tapped Some Button!", .track)
        Nexus.log("User tapped login button", .debug)
        Nexus.log("User tapped login button", .info)
        Nexus.log("User tapped login button", .notice)
        Nexus.log("User tapped login button", .warning)
        Nexus.log("User tapped login button", .error)
        
        
        Nexus.log("User tapped login button", .fault)

        Nexus.log(
            "User tapped login button",
            attributes: [
                "view": "LoginViewController",
                "text": "Login"
            ]
        )

        Nexus.log("User tapped login button", .notice, attributes: [
            "userId": "12345",
            "device": "iPhone15,2"
        ])

        Nexus.log("User tapped login button", .warning, attributes: [
            "issue": "location permission not determined",
            "fallbackUsed": "true"
        ])

        Nexus.log("User tapped login button", .error, attributes: [
            "error": "network_unreachable",
            "retryCount": "2"
        ])

        Nexus.log("User tapped login button", .fault, attributes: [
            "reason": "unexpected nil during force unwrap",
            "file": "LoginManager.swift"
        ])
    }

    var body: some Scene {}
}
