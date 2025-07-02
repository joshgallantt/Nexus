//
//  nexus_logger_exampleApp.swift
//  NexusLoggerExample
//
//  Created by Josh Gallant on 01/07/2025.
//

import SwiftUI
import NexusLogger

@main
struct NexusLoggerExampleApp: App {
    
    init() {
        DestinationStore.shared.addDestination(DefaultOSLoggerDestination())

        NLog("Logger initialized", .debug)
        NLog("Logger initialized", .info)
        NLog("Notice", .notice)
        NLog("Logger initialized", .warning)
        NLog("Logger initialized", .error)
        NLog("Fault", .fault)
    }

    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
}
