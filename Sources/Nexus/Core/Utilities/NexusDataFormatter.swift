//
//  NexusDataFormatter.swift
//  Nexus
//
//  Created by Josh Gallant on 05/07/2025.
//

import Foundation

public enum NexusDataFormatter {
    /// Formats a dictionary, array, or general JSON root object into readable lines using ├─ / └─.
    public static func formatLines(from any: Any?, limit: Int = .max) -> [String]? {
        guard let any else { return nil }

        var lines: [String] = []
        formatRecursive(any, prefix: "", isLast: true, output: &lines)

        var result: [String] = []
        var total = 0
        for line in lines {
            let next = line + "\n"
            if total + next.count > limit {
                result.append("… [truncated]")
                break
            }
            result.append(line)
            total += next.count
        }

        return result.isEmpty ? nil : result
    }

    /// Deserializes JSON `Data` and formats it into pretty lines with visual prefixes.
    public static func formatLines(from jsonData: Data?, limit: Int = .max) -> [String]? {
        guard let jsonData else { return nil }

        do {
            let obj = try JSONSerialization.jsonObject(with: jsonData)
            return formatLines(from: obj, limit: limit)
        } catch {
            return ["<unreadable json: \(error.localizedDescription)>"]
        }
    }
    
    static func sanitizeString(_ input: String) -> String {
        input
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "\\r")
            .replacingOccurrences(of: "\t", with: "\\t")
            .replacingOccurrences(of: "|", with: "\\|")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: ",", with: "\\,")
            .replacingOccurrences(of: "=", with: "\\=")
    }

    // MARK: - Internal Recursive Logic

    private static func formatRecursive(_ value: Any, prefix: String, isLast: Bool, output: inout [String]) {
        let branch = isLast ? "└─ " : "├─ "
        let indent = isLast ? "    " : "│   "

        switch value {
        case let dict as [String: Any?]:
            let sortedKeys = dict.keys.sorted()
            for (index, key) in sortedKeys.enumerated() {
                let isLastItem = index == sortedKeys.count - 1
                let val = dict[key] ?? "nil"
                if val is [Any] || val is [String: Any?] {
                    output.append("\(prefix)\(branch)\(key):")
                    formatRecursive(val as Any, prefix: prefix + indent, isLast: isLastItem, output: &output)
                } else {
                    output.append("\(prefix)\(branch)\(key): \(stringify(val))")
                }
            }

        case let array as [Any]:
            for (index, item) in array.enumerated() {
                let isLastItem = index == array.count - 1
                output.append("\(prefix)\(branch)[\(index)]")
                formatRecursive(item, prefix: prefix + indent, isLast: isLastItem, output: &output)
            }

        default:
            output.append("\(prefix)\(branch)\(stringify(value))")
        }
    }

    private static func stringify(_ value: Any?) -> String {
        switch value {
        case let number as NSNumber:
            return number.stringValue
        case let string as String:
            return string
        case let bool as Bool:
            return bool ? "true" : "false"
        case is NSNull:
            return "null"
        default:
            return String(describing: value ?? "nil")
        }
    }
}
