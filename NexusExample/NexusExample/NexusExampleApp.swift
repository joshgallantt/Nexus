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

        Nexus.addDestination(OSLoggerHumanReadable(showData: true), serialised: true)
        
        Nexus.track("All our base are under attack!")
        Nexus.debug("All our base are under attack!")
        Nexus.info("All our base are under attack!")
        Nexus.notice("All our base are under attack!")
        Nexus.warning("All our base are under attack!")
        Nexus.error("All our base are under attack!")
        Nexus.fault("All our base are under attack!", ["test" : "some value", "test2" : "some other value"])

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
