//
//  NexusMachineParsableLogTests.swift
//  Nexus
//
//  Created by Josh Gallant on 13/07/2025.
//

import Testing
@testable import Nexus
import Foundation

@Suite("NexusMachineParsableLog Coverage")
struct NexusMachineParsableLogTests {
    private func makeMetadata(routingKey: String? = nil, type: NexusEventType = .debug) -> NexusEventMetadata {
        .init(type: type, time: .init(), deviceModel: "model", osVersion: "os", bundleName: "bundle", appVersion: "v", fileName: "file.swift", functionName: "func", lineNumber: "1", threadName: "main", routingKey: routingKey)
    }

    @Test
    func testInitDefaultAndCustom() {
        let d1 = NexusMachineParsableLog()
        _ = NexusMachineParsableLog(subsystem: "sys", category: "cat")
        #expect(type(of: d1) == NexusMachineParsableLog.self)
    }

    @Test
    func testFormatLogOutputVariants() {
        let log = NexusMachineParsableLog()
        let meta = makeMetadata()
        let minimal = NexusEvent(metadata: meta, message: " ", data: nil)
        let s1 = log.formatLogOutput(for: minimal)
        #expect(s1.contains("<no message>"))

        let withMessage = NexusEvent(metadata: meta, message: "msg", data: nil)
        let s2 = log.formatLogOutput(for: withMessage)
        #expect(s2.contains("\"msg\""))

        let rk = makeMetadata(routingKey: "rk")
        let eventRK = NexusEvent(metadata: rk, message: "m", data: nil)
        let s3 = log.formatLogOutput(for: eventRK)
        #expect(s3.contains("nexusRoutingKey=rk"))

        let values = NexusEventData(values: ["k":"v"])
        let eventVal = NexusEvent(metadata: meta, message: "m", data: values)
        let s4 = log.formatLogOutput(for: eventVal)
        #expect(s4.contains("k=v"))

        let obj: [String: Any] = ["a": 1]
        let json = try! JSONSerialization.data(withJSONObject: obj)
        let eventJSON = NexusEvent(metadata: meta, message: "m", data: NexusEventData(json: json))
        let s5 = log.formatLogOutput(for: eventJSON)
        #expect(s5.contains("a=1"))

        let badJSON = Data([0x00, 0x01])
        let badEvent = NexusEvent(metadata: meta, message: "m", data: NexusEventData(json: badJSON))
        let s6 = log.formatLogOutput(for: badEvent)
        #expect(s6.contains("json=<invalid>"))

        let long = String(repeating: "a", count: 600)
        let longEvent = NexusEvent(metadata: meta, message: long, data: NexusEventData(values: ["k": long]))
        let s7 = log.formatLogOutput(for: longEvent)
        #expect(s7.contains("…"))
    }

    @Test
    func testFlattenData() {
        let log = NexusMachineParsableLog()
        let d = NexusEventData(values: ["a": "b"])
        let f1 = log.flattenData(from: d)
        #expect(f1["a"] == "b")
        let obj: [String: Any] = ["x": 1]
        let json = try! JSONSerialization.data(withJSONObject: obj)
        let d2 = NexusEventData(json: json)
        let f2 = log.flattenData(from: d2)
        #expect(f2["x"] == "1")
        let bad = Data([0xFF])
        let d3 = NexusEventData(json: bad)
        let f3 = log.flattenData(from: d3)
        #expect(f3["json"] == "<invalid>")
        #expect(log.flattenData(from: nil).isEmpty)
    }

    @Test
    func testSanitizeAndTruncate() {
        let log = NexusMachineParsableLog()
        let s = log.sanitizeAndTruncate("abc", limit: 5)
        #expect(s == "abc")
        let long = String(repeating: "x", count: 300)
        let ret = log.sanitizeAndTruncate(long, limit: 20)
        #expect(ret.count <= 21 && ret.hasSuffix("…"))
    }
}
