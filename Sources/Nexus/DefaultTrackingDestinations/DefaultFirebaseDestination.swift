//
//  DefaultFirebaseDestination.swift
//  Nexus
//
//  Created by Josh Gallant on 02/07/2025.
//

import Foundation

public struct DefaultFirebaseDestination: NexusTrackingDestination {
    public init() {}
    
    public func track(
        name: String,
        time: Date,
        properties: [String : String]?
    ) async {
        // send to Firebase Analytics SDK...
        print("Firebase track: \(name) @ \(time) \(properties ?? [:])")
    }
}
