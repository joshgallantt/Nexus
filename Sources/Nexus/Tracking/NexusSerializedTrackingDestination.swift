////
////  NexusSerializedTrackingDestination.swift
////  Nexus
////
////  Created by Josh Gallant on 02/07/2025.
////
//
//import Foundation
//
//package actor NexusSerializedTrackingDestination: NexusTrackingDestination {
//    private let wrapped: NexusTrackingDestination
//
//    package init(wrapping destination: NexusTrackingDestination) {
//        self.wrapped = destination
//    }
//
//    package func track(
//        name: String,
//        time: Date,
//        properties: [String : String]?
//    ) async {
//        await wrapped.track(name: name, time: time, properties: properties)
//    }
//}
