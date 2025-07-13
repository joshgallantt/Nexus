//
//  NexusErrorEventTests.swift
//  Nexus
//
//  Created by Josh Gallant on 13/07/2025.
//

import XCTest
@testable import Nexus

final class NexusErrorEventTests: XCTestCase {

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

    func testError_logStringDictionary() async throws {
        Nexus.error("error msg", routingKey: "errorKey", ["cause": "disk"])
        try await waitForEvents(targetCount: 1)
        let event = testDest.events[0]
        XCTAssertEqual(event.message, "error msg")
        XCTAssertEqual(event.metadata.type, .error)
        XCTAssertEqual(event.metadata.routingKey, "errorKey")
        XCTAssertEqual(event.data?.values?["cause"], "disk")
    }

    func testError_logEncodable_success() async throws {
        struct Payload: Codable { let code: Int }
        Nexus.error("encodable", routingKey: "errorRK", Payload(code: 404))
        try await waitForEvents(targetCount: 1)
        let data = testDest.events[0].data?.json
        XCTAssertNotNil(data)
        let dict = try? JSONSerialization.jsonObject(with: data!) as? [String: Any]
        XCTAssertEqual(dict?["code"] as? Int, 404)
    }

    func testError_logEncodable_encodingFails() async throws {
        struct FailingPayload: Encodable {
            func encode(to encoder: Encoder) throws { throw NSError(domain: "fail", code: 77) }
        }
        Nexus.error("failEncode", routingKey: nil, FailingPayload())
        try await waitForEvents(targetCount: 1)
        let event = testDest.events[0]
        XCTAssertTrue(event.message.contains("Encoding failed:"))
        XCTAssertNotNil(event.data?.values?["encoding_error"])
    }

    func testError_logRawJSON() async throws {
        let json = #"{"reason":"file not found"}"#.data(using: .utf8)!
        Nexus.error("rawjson", routingKey: "rk", json)
        try await waitForEvents(targetCount: 1)
        let dict = try? JSONSerialization.jsonObject(with: testDest.events[0].data!.json!) as? [String: Any]
        XCTAssertEqual(dict?["reason"] as? String, "file not found")
    }
}
