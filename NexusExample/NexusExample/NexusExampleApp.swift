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
        Nexus.addLoggingDestination(DefaultOSLoggerDestination(), serialised: true)
        Nexus.addTrackingDestination(DefaultFirebaseDestination())
        Nexus.addLoggingDestination(PrintLogger(), serialised: true)

        Nexus.log("1", .debug)
        Nexus.log("2", .info)
        Nexus.log("3", .notice)
        Nexus.log("4", .warning)
        Nexus.log("5", .error)
        Nexus.log("6", .fault)
        Nexus.track("App Started!", ["someProp":"somePropValue"])
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
