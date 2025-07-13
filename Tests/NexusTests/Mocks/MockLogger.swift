//
//  MockLogger.swift
//  Nexus
//
//  Created by Josh Gallant on 13/07/2025.
//

import OSLog

final class MockLogger {
    var logs: [(level: OSLogType, message: String)] = []
    func log(level: OSLogType, _ message: String) {
        logs.append((level, message))
    }
}
