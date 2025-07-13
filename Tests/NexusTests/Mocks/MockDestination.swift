//
//  MockDestination.swift
//  Nexus
//
//  Created by Josh Gallant on 13/07/2025.
//

import XCTest
@testable import Nexus

@preconcurrency
final class MockDestination: NexusDestination, @unchecked Sendable {
    var received: [NexusEvent] = []
    let lock = NSLock()
    let onSend: ((NexusEvent) -> Void)?
    
    init(onSend: ((NexusEvent) -> Void)? = nil) {
        self.onSend = onSend
    }
    
    func send(_ event: NexusEvent) async {
        received.append(event)
        onSend?(event)
    }
    
    func clear() {
        lock.lock()
        received.removeAll()
        lock.unlock()
    }
    
    var events: [NexusEvent] {
        lock.lock()
        defer { lock.unlock() }
        return received
    }
}
