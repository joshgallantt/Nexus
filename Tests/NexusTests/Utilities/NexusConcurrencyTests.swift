//
//  NexusConcurrencyTests.swift
//  Nexus
//
//  Created by Josh Gallant on 13/07/2025.
//

import XCTest
@testable import Nexus

final class NexusConcurrencyTests: XCTestCase {

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

    @MainActor
    func testThreadName_mainThread() async throws {
        Nexus.info("main thread test")
        try await waitForEvents(targetCount: 1)
        let event = testDest.events[0]
        XCTAssertEqual(event.metadata.threadName, "main")
    }

    func testThreadName_backgroundThread() async throws {
        let exp = expectation(description: "Background thread log")
        Task.detached {
            Nexus.info("background thread test")
            exp.fulfill()
        }
        await fulfillment(of: [exp], timeout: 1)
        try await waitForEvents(targetCount: 1)
        let event = testDest.events[0]
        XCTAssertNotEqual(event.metadata.threadName, "main")
    }
}
