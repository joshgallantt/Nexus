//
//  NexusDeliveryMode.swift
//  Nexus
//
//  Created by Josh Gallant on 02/07/2025.
//

import Foundation


/// Specifies how events are delivered to a destination.
///
/// - serial: Events are delivered one at a time, in order (thread-safe).
///   Recommended for most destinations, especially those that write to files, update the UI, or require strict event ordering.
///   Guarantees safety and order, but may be slower for high-volume or high-throughput use cases.
///
/// - concurrent: Events are delivered in parallel and may arrive out of order.
///   Best for destinations that are fully thread-safe and can handle high event volumes in parallel, such as analytics SDKs, remote loggers, or batching systems.
///   Enables higher throughput and lower latency, but requires the destination to manage its own thread safety and tolerate out-of-order events.
///
///   **Avoid `.concurrent` if your destination:**
///   - Writes to files, updates UI, or modifies shared state without synchronization
///   - Needs events processed strictly in order
public enum NexusDeliveryMode: Sendable {
    case serial
    case concurrent
}


package enum NexusDestinationDeliveryMode {
    case serial(NexusSerialActor)
    case concurrent(NexusDestination)

    func send(_ event: NexusEvent) {
        switch self {
        case .serial(let actor):
            Task(priority: .background) {
                await actor.enqueue(event)
            }
        case .concurrent(let destination):
            Task.detached(priority: .background) {
                await destination.send(event)
            }
        }
    }
}
