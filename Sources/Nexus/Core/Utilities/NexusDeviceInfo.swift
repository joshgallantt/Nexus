//
//  NexusDeviceInfo.swift
//  Nexus
//
//  Created by Josh Gallant on 02/07/2025.
//

import Foundation

#if os(iOS)
import UIKit

final class NexusDeviceInfo {
    static let model: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        return withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(cString: $0)
            }
        }
    }()

    static let osVersion: String = UIDevice.current.systemVersion
}

#elseif os(macOS)
import Darwin

final class NexusDeviceInfo {
    static let model: String = {
        var size: size_t = 0
        sysctlbyname("hw.model", nil, &size, nil, 0)
        var buffer = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.model", &buffer, &size, nil, 0)
        return String(cString: buffer)
    }()

    static let osVersion: String = {
        let version = ProcessInfo.processInfo.operatingSystemVersion
        return "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
    }()
}
#endif
