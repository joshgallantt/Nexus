//
//  MockNexusDestination.swift
//  Nexus
//
//  Created by Josh Gallant on 15/07/2025.
//


final class MockNexusDestination: NexusDestination {
    private(set) var events: [NexusEvent] = []
    
    func send(_ event: NexusEvent) async {
        events.append(event)
    }
    
    func clearEvents() {
        events.removeAll()
    }
}
