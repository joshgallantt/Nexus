//
//  NexusInfoEventTests.swift
//  Nexus
//
//  Created by Josh Gallant on 13/07/2025.
//

import XCTest
@testable import Nexus

final class NexusInfoEventTests: XCTestCase {

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

    func testInfo_logStringDictionary() async throws {
        Nexus.info("info msg", routingKey: "infoKey", ["foo": 123])
        try await waitForEvents(targetCount: 1)
        let event = testDest.events[0]
        XCTAssertEqual(event.message, "info msg")
        XCTAssertEqual(event.metadata.type, .info)
        XCTAssertEqual(event.metadata.routingKey, "infoKey")
        XCTAssertEqual(event.data?.values?["foo"], "123")
    }

    func testInfo_logEncodable_success() async throws {
        struct Payload: Codable { let name: String }
        Nexus.info("encodable", routingKey: "rk", Payload(name: "test"))
        try await waitForEvents(targetCount: 1)
        let data = testDest.events[0].data?.json
        XCTAssertNotNil(data)
        let dict = try? JSONSerialization.jsonObject(with: data!) as? [String: Any]
        XCTAssertEqual(dict?["name"] as? String, "test")
    }

    func testInfo_logEncodable_encodingFails() async throws {
        struct FailingPayload: Encodable {
            func encode(to encoder: Encoder) throws { throw NSError(domain: "fail", code: 1) }
        }
        Nexus.info("failEncode", routingKey: nil, FailingPayload())
        try await waitForEvents(targetCount: 1)
        let event = testDest.events[0]
        XCTAssertTrue(event.message.contains("Encoding failed:"))
        XCTAssertNotNil(event.data?.values?["encoding_error"])
    }

    func testInfo_logRawJSON() async throws {
        let json = #"{"key":"value"}"#.data(using: .utf8)!
        Nexus.info("rawjson", routingKey: "rk", json)
        try await waitForEvents(targetCount: 1)
        let dict = try? JSONSerialization.jsonObject(with: testDest.events[0].data!.json!) as? [String: Any]
        XCTAssertEqual(dict?["key"] as? String, "value")
    }
}
