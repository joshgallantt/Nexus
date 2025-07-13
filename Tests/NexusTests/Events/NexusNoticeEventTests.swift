//
//  NexusNoticeEventTests.swift
//  Nexus
//
//  Created by Josh Gallant on 13/07/2025.
//

import XCTest
@testable import Nexus

final class NexusNoticeEventTests: XCTestCase {

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

    func testNotice_logStringDictionary() async throws {
        Nexus.notice("notice msg", routingKey: "noticeKey", ["note": 1])
        try await waitForEvents(targetCount: 1)
        let event = testDest.events[0]
        XCTAssertEqual(event.message, "notice msg")
        XCTAssertEqual(event.metadata.type, .notice)
        XCTAssertEqual(event.metadata.routingKey, "noticeKey")
        XCTAssertEqual(event.data?.values?["note"], "1")
    }

    func testNotice_logEncodable_success() async throws {
        struct Payload: Codable { let category: String }
        Nexus.notice("encodable", routingKey: "noticeRK", Payload(category: "user"))
        try await waitForEvents(targetCount: 1)
        let data = testDest.events[0].data?.json
        XCTAssertNotNil(data)
        let dict = try? JSONSerialization.jsonObject(with: data!) as? [String: Any]
        XCTAssertEqual(dict?["category"] as? String, "user")
    }

    func testNotice_logEncodable_encodingFails() async throws {
        struct FailingPayload: Encodable {
            func encode(to encoder: Encoder) throws { throw NSError(domain: "fail", code: 66) }
        }
        Nexus.notice("failEncode", routingKey: nil, FailingPayload())
        try await waitForEvents(targetCount: 1)
        let event = testDest.events[0]
        XCTAssertTrue(event.message.contains("Encoding failed:"))
        XCTAssertNotNil(event.data?.values?["encoding_error"])
    }

    func testNotice_logRawJSON() async throws {
        let json = #"{"foo":"bar"}"#.data(using: .utf8)!
        Nexus.notice("rawjson", routingKey: "rk", json)
        try await waitForEvents(targetCount: 1)
        let dict = try? JSONSerialization.jsonObject(with: testDest.events[0].data!.json!) as? [String: Any]
        XCTAssertEqual(dict?["foo"] as? String, "bar")
    }
}
