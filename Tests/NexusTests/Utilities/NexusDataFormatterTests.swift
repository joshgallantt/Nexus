//
//  NexusDataFormatterTests.swift
//  Nexus
//
//  Created by Josh Gallant on 13/07/2025.
//

import Testing
@testable import Nexus
import Foundation

@Suite("NexusDataFormatter")
struct NexusDataFormatterTests {
    @Test
    func testFormatLinesFromAny() {
        // nil input
        #expect(NexusDataFormatter.formatLines(from: nil) == nil)
        // flat dict
        let dict = ["a": 1, "b": true, "c": "test"] as [String: Any]
        let lines = NexusDataFormatter.formatLines(from: dict)
        #expect(lines != nil && lines!.joined().contains("a: 1"))
        // array
        let arr: [Any] = [1, "x", false]
        let arrLines = NexusDataFormatter.formatLines(from: arr)
        #expect(arrLines != nil && arrLines!.joined().contains("[0]: 1"))
        // deeply nested
        let nested: [String: Any] = [
            "outer": ["inner": [1, 2, 3]],
            "other": "z"
        ]
        let nestedLines = NexusDataFormatter.formatLines(from: nested)
        #expect(nestedLines != nil && nestedLines!.joined().contains("outer:"))
        // truncation
        let big = ["x": String(repeating: "a", count: 1000)]
        let truncated = NexusDataFormatter.formatLines(from: big, limit: 10)
        #expect(truncated != nil && truncated!.last?.contains("truncated") == true)
    }

    @Test
    func testFormatLinesFromJSONData() {
        let good = try! JSONSerialization.data(withJSONObject: ["a":1])
        let lines = NexusDataFormatter.formatLines(from: good)
        #expect(lines != nil && lines!.joined().contains("a"))
        let bad = "{".data(using: .utf8)!
        let errorLines = NexusDataFormatter.formatLines(from: bad)
        #expect(errorLines != nil && errorLines!.first?.contains("unreadable json") == true)
    }

    @Test
    func testCustomSortedKeys() {
        let dict = ["b": 1, "nexusRoutingKey": 2, "a": 3] as [String: Any?]
        let keys = NexusDataFormatter.customSortedKeys(for: dict)
        #expect(keys.first == "nexusRoutingKey" && keys.contains("a") && keys.contains("b"))
        let noRK = ["z": 1, "y": 2]
        let keys2 = NexusDataFormatter.customSortedKeys(for: noRK)
        #expect(keys2 == ["y", "z"])
    }

    @Test
    func testDrawPrefix() {
        #expect(NexusDataFormatter.drawPrefix(parentsLast: [], isLast: false).hasSuffix("├─ "))
        #expect(NexusDataFormatter.drawPrefix(parentsLast: [], isLast: true).hasSuffix("└─ "))
        #expect(NexusDataFormatter.drawPrefix(parentsLast: [false,true], isLast: true).contains("│   "))
    }

    @Test
    func testStringify() {
        #expect(NexusDataFormatter.stringify(1) == "1")
        #expect(NexusDataFormatter.stringify(true) == "true")
        #expect(NexusDataFormatter.stringify("abc") == "abc")
        #expect(NexusDataFormatter.stringify(NSNull()) == "null")
        #expect(NexusDataFormatter.stringify(nil) == "nil")
        struct D: CustomStringConvertible { var description: String { "desc" } }
        #expect(NexusDataFormatter.stringify(D()) == "desc")
    }

    @Test
    func testSanitizeString() {
        let dirty = "\tHello, world!\n|=\"\r\\"
        let sanitized = NexusDataFormatter.sanitizeString(dirty)
        #expect(sanitized.contains("\\t") && sanitized.contains("\\n") && sanitized.contains("\\|") && sanitized.contains("\\=") && sanitized.contains("\\\"") && sanitized.contains("\\r") && sanitized.contains("\\\\"))
    }
}
