//
//  NexusDestination.swift
//  Nexus
//
//  Created by Josh Gallant on 01/07/2025.
//

import Foundation

public protocol NexusDestination: Sendable {
    func send(_ event: NexusEvent) async
}
