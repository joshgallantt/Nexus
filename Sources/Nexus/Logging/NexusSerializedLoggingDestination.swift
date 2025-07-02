////
////  NexusSerializedLoggingDestination.swift
////  Nexus
////
////  Created by Josh Gallant on 02/07/2025.
////
//
//import Foundation
//
//package actor NexusSerializedLoggingDestination: NexusLoggingDestination {
//    private let wrapped: NexusLoggingDestination
//
//    package init(wrapping destination: NexusLoggingDestination) {
//        self.wrapped = destination
//    }
//
//    package func log(
//        level: NexusLogLevel,
//        time: Date,
//        bundleName: String,
//        appVersion: String,
//        fileName: String,
//        functionName: String,
//        lineNumber: String,
//        threadName: String,
//        message: String,
//        attributes: [String : String]?
//    ) async {
//        await wrapped.log(
//            level: level,
//            time: time,
//            bundleName: bundleName,
//            appVersion: appVersion,
//            fileName: fileName,
//            functionName: functionName,
//            lineNumber: lineNumber,
//            threadName: threadName,
//            message: message,
//            attributes: attributes
//        )
//    }
//}
