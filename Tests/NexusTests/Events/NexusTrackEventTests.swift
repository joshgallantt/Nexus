//
//  NexusTrackEventTests.swift
//  Nexus
//
//  Created by Josh Gallant on 13/07/2025.
//

import XCTest
@testable import Nexus

final class NexusTrackEventTests: XCTestCase {

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
            try await Task.sleep(nanoseconds: 10_000_000)
        }
        XCTFail("Timed out waiting for \(targetCount) events")
    }

    func testTrack_logStringDictionary() async throws {
        Nexus.track("track msg", routingKey: "trackKey", ["action": "tap"])
        try await waitForEvents(targetCount: 1)
        let event = testDest.events[0]
        XCTAssertEqual(event.message, "track msg")
        XCTAssertEqual(event.metadata.type, .track)
        XCTAssertEqual(event.metadata.routingKey, "trackKey")
        XCTAssertEqual(event.data?.values?["action"], "tap")
    }

    func testTrack_logEncodable_success() async throws {
        struct Payload: Codable { let screen: String }
        Nexus.track("encodable", routingKey: "trackRK", Payload(screen: "Main"))
        try await waitForEvents(targetCount: 1)
        let data = testDest.events[0].data?.json
        XCTAssertNotNil(data)
        let dict = try? JSONSerialization.jsonObject(with: data!) as? [String: Any]
        XCTAssertEqual(dict?["screen"] as? String, "Main")
    }

    func testTrack_logEncodable_encodingFails() async throws {
        struct FailingPayload: Encodable {
            func encode(to encoder: Encoder) throws { throw NSError(domain: "fail", code: 55) }
        }
        Nexus.track("failEncode", routingKey: nil, FailingPayload())
        try await waitForEvents(targetCount: 1)
        let event = testDest.events[0]
        XCTAssertTrue(event.message.contains("Encoding failed:"))
        XCTAssertNotNil(event.data?.values?["encoding_error"])
    }

    func testTrack_logRawJSON() async throws {
        let json = #"{"step":1}"#.data(using: .utf8)!
        Nexus.track("rawjson", routingKey: "rk", json)
        try await waitForEvents(targetCount: 1)
        let dict = try? JSONSerialization.jsonObject(with: testDest.events[0].data!.json!) as? [String: Any]
        XCTAssertEqual(dict?["step"] as? Int, 1)
    }
}
