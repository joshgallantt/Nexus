//
//  PrintLogger.swift
//  Nexus
//
//  Created by Josh Gallant on 02/07/2025.
//

import Foundation


public actor PrintLogger: NexusLoggingDestination {
    public init() {}

    public func log(
        level: NexusLogLevel,
        time: Date,
        bundleName: String,
        appVersion: String,
        fileName: String,
        functionName: String,
        lineNumber: String,
        threadName: String,
        message: String,
        attributes: [String : String]?
    ) async {
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        print("🟩\(message)")
    }
}
