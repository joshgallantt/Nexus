//
//  NexusDataFormatter.swift
//  Nexus
//
//  Created by Josh Gallant on 05/07/2025.
//

import Foundation

public enum NexusDataFormatter {
    public static func formatLines(from any: Any?, limit: Int = .max) -> [String]? {
        guard let any else { return nil }

        var lines: [String] = []
        formatRecursive(any, key: nil, parentsLast: [], isLast: true, output: &lines, isRoot: true)

        var result: [String] = []
        var total = 0
        for line in lines {
            let next = line + "\n"
            if total + next.count > limit {
                result.append("└─ … [truncated]")
                break
            }
            result.append(line)
            total += next.count
        }

        return result
    }

    public static func formatLines(from jsonData: Data?, limit: Int = .max) -> [String]? {
        guard let jsonData else { return nil }

        do {
            let obj = try JSONSerialization.jsonObject(with: jsonData)
            return formatLines(from: obj, limit: limit)
        } catch {
            return ["<unreadable json: \(error.localizedDescription)>"]
        }
    }

    // MARK: - Recursive Formatting

    private static func formatRecursive(
        _ value: Any,
        key: String?,
        parentsLast: [Bool],
        isLast: Bool,
        output: inout [String],
        isRoot: Bool = false
    ) {
        let prefix = isRoot ? "" : drawPrefix(parentsLast: parentsLast, isLast: isLast)
        let label = key.map { "\($0): " } ?? ""

        switch value {
        case let dict as [String: Any?]:
            if !isRoot {
                // Always print the parent key line for non-root dicts
                output.append("\(prefix)\(label)")
            }
            let sortedKeys = customSortedKeys(for: dict)
            for (index, k) in sortedKeys.enumerated() {
                let v = dict[k] ?? "nil"
                let childIsLast = index == sortedKeys.count - 1
                formatRecursive(
                    v as Any,
                    key: k,
                    parentsLast: isRoot ? [] : (parentsLast + [isLast]),
                    isLast: childIsLast,
                    output: &output,
                    isRoot: false
                )
            }
        case let array as [Any]:
            // Always print the parent key line for arrays (unless at root, but arrays are never root here)
            output.append("\(prefix)\(label)")
            for (index, item) in array.enumerated() {
                let childIsLast = index == array.count - 1
                formatRecursive(item, key: "[\(index)]", parentsLast: parentsLast + [isLast], isLast: childIsLast, output: &output, isRoot: false)
            }
        default:
            output.append("\(prefix)\(label)\(stringify(value))")
        }
    }

    private static func customSortedKeys(for dict: [String: Any?]) -> [String] {
        var keys = Array(dict.keys)
        if let index = keys.firstIndex(of: "nexusRoutingKey") {
            keys.remove(at: index)
            return ["nexusRoutingKey"] + keys.sorted()
        }
        return keys.sorted()
    }

    private static func drawPrefix(parentsLast: [Bool], isLast: Bool) -> String {
        var prefix = ""
        for wasLast in parentsLast {
            prefix += wasLast ? "    " : "│   "
        }
        prefix += isLast ? "└─ " : "├─ "
        return prefix
    }

    private static func stringify(_ value: Any?) -> String {
        switch value {
        case let number as NSNumber:
            if CFGetTypeID(number) == CFBooleanGetTypeID() {
                return number.boolValue ? "true" : "false"
            }
            return number.stringValue
        case let string as String:
            return string
        case is NSNull:
            return "null"
        default:
            return String(describing: value ?? "nil")
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

}
