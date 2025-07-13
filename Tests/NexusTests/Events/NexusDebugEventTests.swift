//
//  NexusDebugEventTests.swift
//  Nexus
//
//  Created by Josh Gallant on 13/07/2025.
//

import XCTest
@testable import Nexus

final class NexusDebugEventTests: XCTestCase {

    var testDest: MockDestination!

    override func setUp() async throws {
        try await super.setUp()
        await NexusDestinationRegistry.shared.removeAllDestinations()
        testDest = MockDestination()
        await NexusDestinationRegistry.shared.addDestination(testDest, mode: .serial)
    }

    override func tearDown() async throws {
        await NexusDestinationRegistry.shared.removeAllDestinations()
        testDest = nil
        try await super.tearDown()
    }

    func waitForEvents(targetCount: Int, timeout: TimeInterval = 2) async throws {
        let end = Date().addingTimeInterval(timeout)
        while Date() < end {
            if testDest.events.count == targetCount { return }
            try await Task.sleep(nanoseconds: 10_000_000) // 10ms
        }
        XCTFail("Timed out waiting for \(targetCount) events")
    }

    func testDebug_logStringDictionary() async throws {
        Nexus.debug("debug msg", routingKey: "debugKey", ["bar": 456])
        try await waitForEvents(targetCount: 1)
        let event = testDest.events[0]
        XCTAssertEqual(event.message, "debug msg")
        XCTAssertEqual(event.metadata.type, .debug)
        XCTAssertEqual(event.metadata.routingKey, "debugKey")
        XCTAssertEqual(event.data?.values?["bar"], "456")
    }

    func testDebug_logEncodable_success() async throws {
        struct Payload: Codable { let id: Int }
        Nexus.debug("encodable", routingKey: "debugRK", Payload(id: 7))
        try await waitForEvents(targetCount: 1)
        let data = testDest.events[0].data?.json
        XCTAssertNotNil(data)
        let dict = try? JSONSerialization.jsonObject(with: data!) as? [String: Any]
        XCTAssertEqual(dict?["id"] as? Int, 7)
    }

    func testDebug_logEncodable_encodingFails() async throws {
        struct FailingPayload: Encodable {
            func encode(to encoder: Encoder) throws { throw NSError(domain: "fail", code: 99) }
        }
        Nexus.debug("failEncode", routingKey: nil, FailingPayload())
        try await waitForEvents(targetCount: 1)
        let event = testDest.events[0]
        XCTAssertTrue(event.message.contains("Encoding failed:"))
        XCTAssertNotNil(event.data?.values?["encoding_error"])
    }

    func testDebug_logRawJSON() async throws {
        let json = #"{"flag":true}"#.data(using: .utf8)!
        Nexus.debug("rawjson", routingKey: "rk", json)
        try await waitForEvents(targetCount: 1)
        let dict = try? JSONSerialization.jsonObject(with: testDest.events[0].data!.json!) as? [String: Any]
        XCTAssertEqual(dict?["flag"] as? Bool, true)
    }
}
