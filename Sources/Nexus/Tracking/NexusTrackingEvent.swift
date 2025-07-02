//
//  NexusTrackingEvent.swift
//  Nexus
//
//  Created by Josh Gallant on 02/07/2025.
//

import Foundation

struct NexusTrackingEvent: Sendable {
    let name: String
    let time: Date
    let properties: [String: String]?
}
