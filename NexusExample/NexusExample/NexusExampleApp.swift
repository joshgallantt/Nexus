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

        Nexus.addDestination(OSLoggerHumanReadable(), serialised: true)
        
        Nexus.sendEvent("All our base are under attack!", .track)
        Nexus.sendEvent("All our base are under attack!", .debug)
        Nexus.sendEvent("All our base are under attack!", .info)
        Nexus.sendEvent("All our base are under attack!", .notice)
        Nexus.sendEvent("All our base are under attack!", .warning)
        Nexus.sendEvent("All our base are under attack!", .error)
        Nexus.sendEvent("All our base are under attack!", .fault)

//        Nexus.sendEvent(
//            "User tapped login button",
//            attributes: [
//                "view": "LoginViewController",
//                "text": "Login"
//            ]
//        )
//
//        Nexus.sendEvent("User tapped login button", .notice, attributes: [
//            "userId": "12345",
//            "device": "iPhone15,2"
//        ])
//
//        Nexus.sendEvent("User tapped login button", .warning, attributes: [
//            "issue": "location permission not determined",
//            "fallbackUsed": "true"
//        ])
//
//        Nexus.sendEvent("User tapped login button", .error, attributes: [
//            "error": "network_unreachable",
//            "retryCount": "2"
//        ])
//
//        Nexus.sendEvent("User tapped login button", .fault, attributes: [
//            "reason": "unexpected nil during force unwrap",
//            "file": "LoginManager.swift"
//        ])
    }

    var body: some Scene {}
}
