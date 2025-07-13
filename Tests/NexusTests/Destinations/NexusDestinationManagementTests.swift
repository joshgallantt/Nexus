//
//  NexusDestinationManagementTests.swift
//  Nexus
//
//  Created by Josh Gallant on 13/07/2025.
//

import XCTest
@testable import Nexus

final class NexusDestinationManagementTests: XCTestCase {

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

    func testRemoveAllDestinations() async throws {
        await NexusDestinationRegistry.shared.removeAllDestinations()
        let prevCount = testDest.events.count
        Nexus.debug("should not deliver")
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5s
        XCTAssertEqual(testDest.events.count, prevCount)
    }

    func testAddDestination_concurrent() async throws {
        let concurrentDest = MockDestination()
        await NexusDestinationRegistry.shared.addDestination(concurrentDest, mode: .concurrent)
        Nexus.info("concurrent test")
        let end = Date().addingTimeInterval(2)
        while Date() < end {
            if concurrentDest.events.count == 1 { break }
            try await Task.sleep(nanoseconds: 10_000_000)
        }
        XCTAssertEqual(concurrentDest.events.first?.message, "concurrent test")
    }

    func testAddDestination_publicAPI() async throws {
        let publicDest = MockDestination()
        Nexus.addDestination(publicDest, .serial)
        // Wait for the background task to complete registration
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2s
        Nexus.info("public API add test")
        let end = Date().addingTimeInterval(2)
        while Date() < end {
            if publicDest.events.count == 1 { break }
            try await Task.sleep(nanoseconds: 10_000_000)
        }
        XCTAssertEqual(publicDest.events.first?.message, "public API add test")
    }

    func testRemoveAllDestinations_publicAPI() async throws {
        let publicDest = MockDestination()
        Nexus.addDestination(publicDest, .serial)
        try await Task.sleep(nanoseconds: 150_000_000) // let registration complete
        Nexus.removeAllDestinations()
        try await Task.sleep(nanoseconds: 150_000_000) // let removal complete
        Nexus.warning("should not deliver (public API)")
        try await Task.sleep(nanoseconds: 500_000_000)
        XCTAssertEqual(publicDest.events.count, 0)
    }
}
