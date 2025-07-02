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
        print("🧪\(level.name): \(message)")
    }
}
