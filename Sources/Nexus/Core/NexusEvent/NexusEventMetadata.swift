//
//  NexusEventMetadata.swift
//  Nexus
//
//  Created by Josh Gallant on 03/07/2025.
//


import Foundation

/// Metadata describing the context, severity, and routing of an event.
public struct NexusEventMetadata: Sendable {
    public let type: NexusEventType
    public let time: Date
    public let deviceModel: String
    public let osVersion: String
    public let bundleName: String
    public let appVersion: String
    public let fileName: String
    public let functionName: String
    public let lineNumber: String
    public let threadName: String
    public let routingKey: String?

    public init(
        type: NexusEventType,
        time: Date = Date(),
        deviceModel: String,
        osVersion: String,
        bundleName: String,
        appVersion: String,
        fileName: String,
        functionName: String,
        lineNumber: String,
        threadName: String,
        routingKey: String? = nil
    ) {
        self.type = type
        self.time = time
        self.deviceModel = deviceModel
        self.osVersion = osVersion
        self.bundleName = bundleName
        self.appVersion = appVersion
        self.fileName = fileName
        self.functionName = functionName
        self.lineNumber = lineNumber
        self.threadName = threadName
        self.routingKey = routingKey
    }
}
