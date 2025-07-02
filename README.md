<p align="center">
  <img src="NexusExample/nexus.png" alt="App Screenshot" width="300"/>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Swift-5.9%2B-orange?style=flat-square" />
  <img src="https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS%20%7C%20watchOS%20%7C%20tvOS-blue?style=flat-square" />
  <img src="https://img.shields.io/badge/SPM-ready-green?style=flat-square" />
  <img src="https://img.shields.io/badge/License-MIT-lightgrey?style=flat-square" />
</p>

<p align="center">
  <em>A modern, concurrency-safe, fire-and-forget logging and tracking interface for all your Swift applications. Flexible input. Flexible output. Gorgeous developer experience.</em>
</p>

<p align="center">
  <img src="NexusExample/example.png" alt="App Screenshot" width="10000"/>
</p>

 ---

 ## 🚀 Features

 - **Flexible log/event routing** (multiple destinations: console, analytics, custom)
 - **Level-based logging** (`.debug`, `.info`, `.notice`, `.warning`, `.error`, `.fault`, `.track`)
 - **Attribute-rich events** (add context, device, file, and more)
 - **Thread-safe and highly performant** delivery
 - **Easy integration**—works everywhere Swift does
 - **Open for extension** (custom destinations, analytics, etc)
 
  ## 🧭 Guiding Principles

 - **Flexible log/event routing** (multiple destinations: console, analytics, custom)
 - **Level-based logging** (`.debug`, `.info`, `.notice`, `.warning`, `.error`, `.fault`, `.track`)
 - **Attribute-rich events** (add context, device, file, and more)
 - **Thread-safe and highly performant** delivery
 - **Easy integration**—works everywhere Swift does
 - **Open for extension** (custom destinations, analytics, etc)
 ---

 ## 📦 Installation

 #### Swift Package Manager (Preferred)

 1. In Xcode: _File > Add Packages..._
 2. Enter repo URL:
    ```
    https://github.com/YOUR_USER_ORG/Nexus.git
    ```
 3. Add `Nexus` as a dependency to your target.

 ---

 ## ✨ Quick Start

 ```swift
 import Nexus

 // Add a destination (e.g., console logger, analytics, etc.)
 Nexus.addDestination(OSLoggerHumanReadable())

 // Send different types of events
 Nexus.debug("User tapped login button")
 Nexus.info("Screen appeared", attributes: ["screen": "HomeView"]) 
 Nexus.track("Signup Flow: Step 1 Start")
 Nexus.warning("Missing location permission")
 Nexus.error("Network unreachable", attributes: ["retryCount": "2"])
 Nexus.fault("Unexpected nil unwrapped!", attributes: ["file": "LoginManager.swift"])
 ```

 ---

 ## 🔍 API Highlights

 ### Log Event Types

 - `.debug`   – for debugging
 - `.track`   – analytics/tracking
 - `.info`    – normal operation
 - `.notice`  – normal but significant conditions that may require monitoring
 - `.warning` – recoverable issues or unusual conditions
 - `.error`   – expected but unrecoverable errors that require developer attention
 - `.fault`   – entered a expected and critical state that should never occur.

 ### Adding Destinations

 A destination is anything that can receive events: console, remote logging, analytics and more.

 ```swift
 Nexus.addDestination(YOUR_DESTINATION(), serialised: true)
 ```
 - `serialised: Bool = true`
 When set to true, events are delivered individually and in the exact order they were sent (strict ordering), which is ideal for destinations that rely on event sequence. When set to false, events may be delivered out of order or in batches, offering better performance when ordering is not important or batching is desired.

 ### Custom Destinations ⭐🚀🪐

 Create your own by conforming to `NexusDestination`, use as little data or as much as you'd like before sending it off to wherever you please!'

 ```swift
 public protocol NexusDestination: Sendable {
     func send(
         type: NexusEventType,
         time: Date,
         deviceModel: String,
         osVersion: String,
         bundleName: String,
         appVersion: String,
         fileName: String,
         functionName: String,
         lineNumber: String,
         threadName: String,
         message: String,
         attributes: [String: String]?,
         routingKey: String?
     ) async
 }
 ```

 ---

 ## 📖 Documentation

 - Full API Reference: _Coming soon!_
 - Example project included: see `NexusExampleApp.swift`

 ---

 ## 🤝 Contributing

 Contributions, bug reports, and feature requests welcome!
 - Open issues or pull requests
 - Code should be Swift 5.9+ and covered by tests

 ---

 ## 📜 License

 MIT License — see `LICENSE` file.

 ---

 ## 💬 Questions, Comments, Concerns?

 Open an issue or start a discussion!

 — Made with ❤️ by Josh Gallant
