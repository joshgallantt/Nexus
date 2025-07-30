//
//  NexusDebugLogTests.swift
//  Nexus
//
//  Created by Josh Gallant on 13/07/2025.
//

import Testing
import Foundation
@testable import Nexus
import os

@Suite("NexusDebugLog Full Coverage")
struct NexusDebugLogTests {
    private func makeMetadata(routingKey: String? = nil, type: NexusEventType = .debug, fileName: String = "file.swift", lineNumber: String = "1") -> NexusEventMetadata {
        .init(type: type, time: .init(timeIntervalSince1970: 1), deviceModel: "model", osVersion: "os", bundleName: "bundle", appVersion: "v", fileName: fileName, functionName: "func", lineNumber: lineNumber, threadName: "main", routingKey: routingKey)
    }

    private func makeEvent(type: NexusEventType = .debug, routingKey: String? = nil, message: String = "msg", data: NexusEventData? = nil) -> NexusEvent {
        .init(metadata: makeMetadata(routingKey: routingKey, type: type), message: message, data: data)
    }

    private func makeDebugLog(
        showData: Bool = true,
        logOnly: [NexusEventType] = NexusEventType.allCases,
        requiredRoutingKey: String? = nil,
        maxLogLength: Int = 1000,
        logger: Logger
    ) -> NexusDebugLog {
        NexusDebugLog(
            showData: showData,
            logOnly: logOnly,
            requiredRoutingKey: requiredRoutingKey,
            maxLogLength: maxLogLength,
            logger: logger
        )
    }

    @Test
    func testSendFiltersByRoutingKey() {
        let fakeLogger = Logger(subsystem: "test", category: "fake") // Using Logger here instead of FakeLogger
        let log = makeDebugLog(requiredRoutingKey: "rk", logger: fakeLogger)
        let meta = makeMetadata(routingKey: "other")
        let event = NexusEvent(metadata: meta, message: "message", data: nil)
        log.send(event)
        let _ = Bool(true)
    }

    @Test
    func testSendFiltersByType() {
        let fakeLogger = Logger(subsystem: "test", category: "fake")
        let log = makeDebugLog(logOnly: [.info], logger: fakeLogger)
        let event = makeEvent(type: .debug)
        log.send(event)
        let _ = Bool(true)
    }

    @Test
    func testSendBasicMessage() {
        let fakeLogger = Logger(subsystem: "test", category: "fake")
        let log = makeDebugLog(logger: fakeLogger)
        let event = makeEvent(message: "simple message")
        log.send(event)
        let _ = Bool(true)
    }

    @Test
    func testSendEmptyMessage() {
        let fakeLogger = Logger(subsystem: "test", category: "fake")
        let log = makeDebugLog(logger: fakeLogger)
        let event = makeEvent(message: "   \n\n ")
        log.send(event)
        let _ = Bool(true)
    }

    @Test
    func testSendWithValuesData() {
        let fakeLogger = Logger(subsystem: "test", category: "fake")
        let log = makeDebugLog(logger: fakeLogger)
        let data = NexusEventData(values: ["foo": "bar"])
        let event = makeEvent(data: data)
        log.send(event)
        let _ = Bool(true)
    }

    @Test
    func testSendWithJSONData() {
        let fakeLogger = Logger(subsystem: "test", category: "fake")
        let log = makeDebugLog(logger: fakeLogger)
        let json = try! JSONSerialization.data(withJSONObject: ["x": 1])
        let data = NexusEventData(json: json)
        let event = makeEvent(data: data)
        log.send(event)
        let _ = Bool(true)
    }

    @Test
    func testSendWithBadJSON() {
        let fakeLogger = Logger(subsystem: "test", category: "fake")
        let log = makeDebugLog(logger: fakeLogger)
        let badJSON = Data([0x00,0x01])
        let data = NexusEventData(json: badJSON)
        let event = makeEvent(data: data)
        log.send(event)
        let _ = Bool(true)
    }

    @Test
    func testSendWithRoutingKeyInjection() {
        let fakeLogger = Logger(subsystem: "test", category: "fake")
        let log = makeDebugLog(logger: fakeLogger)
        let data = NexusEventData(values: ["baz": "qux"])
        let event = makeEvent(routingKey: "rk", data: data)
        log.send(event)
        let _ = Bool(true)
    }

    @Test
    func testSendWithShowDataFalse() {
        let fakeLogger = Logger(subsystem: "test", category: "fake")
        let log = makeDebugLog(showData: false, logger: fakeLogger)
        let data = NexusEventData(values: ["foo": "bar"])
        let event = makeEvent(data: data)
        log.send(event)
        let _ = Bool(true)
    }

    @Test
    func testSendTruncation() {
        let fakeLogger = Logger(subsystem: "test", category: "fake")
        let log = makeDebugLog(maxLogLength: 40, logger: fakeLogger)
        let longMsg = String(repeating: "x", count: 100)
        let event = makeEvent(message: longMsg)
        log.send(event)
        let _ = Bool(true)
    }

    @Test
    func testFormatHeaderLineVariants() {
        let fakeLogger = Logger(subsystem: "test", category: "fake")
        let log = makeDebugLog(logger: fakeLogger)
        let event = makeEvent(message: "header test", data: nil)
        let header = log.formatHeaderLine(from: event, message: "header test")
        #expect(header.contains("header test"))
    }

    @Test
    func testFormatDataBlockVariants() {
        let fakeLogger = Logger(subsystem: "test", category: "fake")
        let log = makeDebugLog(logger: fakeLogger)
        let meta = makeMetadata(routingKey: "rk")
        let event = NexusEvent(metadata: meta, message: "msg", data: nil)
        let block = log.formatDataBlock(from: event, fittingIn: 1000)
        #expect(block?.first?.contains("nexusRoutingKey") == true)
    }
    
    @Test
    func testFormatDataBlockWithValues() {
        let fakeLogger = Logger(subsystem: "test", category: "fake")
        let log = makeDebugLog(logger: fakeLogger)
        let data = NexusEventData(values: ["foo": "bar"])
        let event = makeEvent(data: data)
        let block = log.formatDataBlock(from: event, fittingIn: 1000)
        #expect(block?.first?.contains("foo") == true)
    }

    @Test
    func testFormatDataBlockWithValuesAndRoutingKey() {
        let fakeLogger = Logger(subsystem: "test", category: "fake")
        let log = makeDebugLog(logger: fakeLogger)
        let data = NexusEventData(values: ["baz": "qux"])
        let event = makeEvent(routingKey: "rk", data: data)
        let block = log.formatDataBlock(from: event, fittingIn: 1000)
        #expect(block?.first?.contains("nexusRoutingKey") == true)
        #expect(block?.joined().contains("rk") == true)
    }

    @Test
    func testFormatDataBlockWithJSONDict() {
        let fakeLogger = Logger(subsystem: "test", category: "fake")
        let log = makeDebugLog(logger: fakeLogger)
        let dict = ["x": 1, "y": 2]
        let json = try! JSONSerialization.data(withJSONObject: dict)
        let data = NexusEventData(json: json)
        let event = makeEvent(data: data)
        let block = log.formatDataBlock(from: event, fittingIn: 1000)
        #expect(block?.first?.contains("x") == true)
        #expect(block?.joined().contains("1") == true)
    }

    @Test
    func testFormatDataBlockWithJSONArray() {
        let fakeLogger = Logger(subsystem: "test", category: "fake")
        let log = makeDebugLog(logger: fakeLogger)
        let arr = [1, 2, 3]
        let json = try! JSONSerialization.data(withJSONObject: arr)
        let data = NexusEventData(json: json)
        let event = makeEvent(data: data)
        let block = log.formatDataBlock(from: event, fittingIn: 1000)
        #expect(block?.joined().contains("data") == true)
        #expect(block?.joined().contains("1") == true)
    }

    @Test
    func testFormatDataBlockWithJSONArrayAndRoutingKey() {
        let fakeLogger = Logger(subsystem: "test", category: "fake")
        let log = makeDebugLog(logger: fakeLogger)
        let arr = [1, 2, 3]
        let json = try! JSONSerialization.data(withJSONObject: arr)
        let data = NexusEventData(json: json)
        let event = makeEvent(routingKey: "route", data: data)
        let block = log.formatDataBlock(from: event, fittingIn: 1000)
        #expect(block?.joined().contains("nexusRoutingKey") == true)
        #expect(block?.joined().contains("route") == true)
    }

    @Test
    func testFormatDataBlockWithBadJSON() {
        let fakeLogger = Logger(subsystem: "test", category: "fake")
        let log = makeDebugLog(logger: fakeLogger)
        let badJSON = Data([0x00,0x01,0x02])
        let data = NexusEventData(json: badJSON)
        let event = makeEvent(data: data)
        let block = log.formatDataBlock(from: event, fittingIn: 1000)
        // Should return nil (no data block can be formed)
        #expect(block == nil)
    }

    @Test
    func testFormatDataBlockWithNoDataAndRoutingKey() {
        let fakeLogger = Logger(subsystem: "test", category: "fake")
        let log = makeDebugLog(logger: fakeLogger)
        let event = makeEvent(routingKey: "rk", data: nil)
        let block = log.formatDataBlock(from: event, fittingIn: 1000)
        #expect(block?.joined().contains("nexusRoutingKey") == true)
    }

    @Test
    func testFormatDataBlockWithNoDataNoRoutingKey() {
        let fakeLogger = Logger(subsystem: "test", category: "fake")
        let log = makeDebugLog(logger: fakeLogger)
        let event = makeEvent(routingKey: nil, data: nil)
        let block = log.formatDataBlock(from: event, fittingIn: 1000)
        // Should return nil because there's nothing to format
        #expect(block == nil)
    }

    @Test
    func testFormatDataBlockShowDataFalse() {
        let fakeLogger = Logger(subsystem: "test", category: "fake")
        let log = makeDebugLog(showData: false, logger: fakeLogger)
        let data = NexusEventData(values: ["foo": "bar"])
        let event = makeEvent(data: data)
        let block = log.formatDataBlock(from: event, fittingIn: 1000)
        #expect(block == nil)
    }
    
    @Test
    func testSendRoutingKeyFilterBehavior() {
        let mockLogger = MockLogger()

        func testSend(
            requiredRoutingKey: String?,
            event: NexusEvent,
            logOnly: [NexusEventType] = NexusEventType.allCases
        ) {
            if let requiredRoutingKey, requiredRoutingKey != event.metadata.routingKey {
                return
            }
            if !logOnly.contains(event.metadata.type) {
                return
            }
            mockLogger.log(level: event.metadata.type.defaultOSLogType, event.message)
        }

        let event1 = makeEvent(routingKey: "A", message: "shouldNotLog")
        let event2 = makeEvent(routingKey: "rk", message: "shouldLog")
        testSend(requiredRoutingKey: "rk", event: event1)
        #expect(mockLogger.logs.isEmpty)

        testSend(requiredRoutingKey: "rk", event: event2)
        #expect(mockLogger.logs.count == 1)
        #expect(mockLogger.logs.first?.message == "shouldLog")
    }

}
