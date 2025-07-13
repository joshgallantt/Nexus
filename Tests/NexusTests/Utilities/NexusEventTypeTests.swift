//
//  NexusEventTypeTests.swift
//  Nexus
//
//  Created by Josh Gallant on 13/07/2025.
//


import Testing
import os
@testable import Nexus

@Suite("NexusEventType Full Coverage")
struct NexusEventTypeTests {

    @Test
    func testAllCases() {
        let all: [NexusEventType] = [.debug, .track, .info, .notice, .warning, .error, .fault]
        #expect(NexusEventType.allCases == all)
    }

    @Test
    func testComparableOrdering() {
        #expect(NexusEventType.debug < .track)
        #expect(NexusEventType.track < .info)
        #expect(NexusEventType.info < .notice)
        #expect(NexusEventType.notice < .warning)
        #expect(NexusEventType.warning < .error)
        #expect(NexusEventType.error < .fault)
        #expect(NexusEventType.fault > .debug)
    }

    @Test
    func testEmojis() {
        #expect(NexusEventType.debug.emoji == "🟪")
        #expect(NexusEventType.track.emoji == "🟫")
        #expect(NexusEventType.info.emoji == "🟦")
        #expect(NexusEventType.notice.emoji == "🟩")
        #expect(NexusEventType.warning.emoji == "🟨")
        #expect(NexusEventType.error.emoji == "🟧")
        #expect(NexusEventType.fault.emoji == "🟥")
    }

    @Test
    func testNames() {
        #expect(NexusEventType.debug.name == "DEBUG")
        #expect(NexusEventType.track.name == "TRACKING")
        #expect(NexusEventType.info.name == "INFO")
        #expect(NexusEventType.notice.name == "NOTICE")
        #expect(NexusEventType.warning.name == "WARNING")
        #expect(NexusEventType.error.name == "ERROR")
        #expect(NexusEventType.fault.name == "FAULT")
    }

    @Test
    func testDefaultOSLogType() {
        #expect(NexusEventType.debug.defaultOSLogType == .debug)
        #expect(NexusEventType.track.defaultOSLogType == .info)
        #expect(NexusEventType.info.defaultOSLogType == .info)
        #expect(NexusEventType.notice.defaultOSLogType == .default)
        #expect(NexusEventType.warning.defaultOSLogType == .error)
        #expect(NexusEventType.error.defaultOSLogType == .error)
        #expect(NexusEventType.fault.defaultOSLogType == .fault)
    }

    @Test
    func testRawValueOrder() {
        let ordered = NexusEventType.allCases
        for (i, type) in ordered.enumerated() {
            #expect(type.rawValue == i)
        }
    }

    @Test
    func testCaseIterableConformance() {
        #expect(NexusEventType.allCases.count == 7)
    }

    @Test
    func testSendableConformance() async throws {
        let type: NexusEventType = .warning
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            let closure: @Sendable () -> Void = {
                _ = type
                cont.resume()
            }
            closure()
        }
    }
}
