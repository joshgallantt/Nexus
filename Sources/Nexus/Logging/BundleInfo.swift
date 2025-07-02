//
//  BundleInfo.swift
//  NexusLogger
//
//  Created by Josh Gallant on 01/07/2025.
//

import Foundation

package struct BundleInfo {
    let name: String
    let version: String

    init(bundle: Bundle = .main) {
        self.name = bundle.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "Unknown Bundle"
        self.version = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown Version"
    }
}
