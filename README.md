// Nexus

// ![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange?style=flat-square)
// ![Platforms](https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS%20%7C%20watchOS%20%7C%20tvOS-blue?style=flat-square)
// ![SPM](https://img.shields.io/badge/SPM-ready-green?style=flat-square)
// ![License](https://img.shields.io/badge/License-MIT-lightgrey?style=flat-square)

// > **Nexus**: _The elegant, powerful logging and event tracking solution for all your Apple apps. Flexible output. Gorgeous developer experience._

// ---

// ## 🚀 Features

// - **Flexible log/event routing** (multiple destinations: console, analytics, custom)
// - **Level-based logging** (`.debug`, `.info`, `.notice`, `.warning`, `.error`, `.fault`, `.track`)
// - **Attribute-rich events** (add context, device, file, and more)
// - **Thread-safe and highly performant** delivery
// - **Easy integration**—works everywhere Swift does
// - **Open for extension** (custom destinations, analytics, etc)

// ---

// ## 📦 Installation

// #### Swift Package Manager (Preferred)

// 1. In Xcode: _File > Add Packages..._
// 2. Enter repo URL:
//    ```
//    https://github.com/YOUR_USER_ORG/Nexus.git
//    ```
// 3. Add `Nexus` as a dependency to your target.

// ---

// ## ✨ Quick Start

// ```swift
// import Nexus

// // Add a destination (e.g., console logger, analytics, etc.)
// Nexus.addDestination(OSLoggerHumanReadable())

// // Send different types of events
// Nexus.debug("User tapped login button")
// Nexus.info("Screen appeared", attributes: ["screen": "HomeView"]) 
// Nexus.track("Signup Flow: Step 1 Start")
// Nexus.warning("Missing location permission")
// Nexus.error("Network unreachable", attributes: ["retryCount": "2"])
// Nexus.fault("Unexpected nil unwrapped!", attributes: ["file": "LoginManager.swift"])
// ```

// ---

// ## 🔍 API Highlights

// ### Log Event Types

// - `.debug`   – for verbose diagnostics (hidden by default)
// - `.track`   – analytics/tracking
// - `.info`    – normal operation
// - `.notice`  – significant conditions
// - `.warning` – recoverable issues
// - `.error`   – unrecoverable error
// - `.fault`   – critical failure

// ### Adding Destinations

// A destination is anything that can receive events: console, remote logging, analytics and more.

// ```swift
// Nexus.addDestination(YOUR_DESTINATION(), serialised: true)
// ```
// - `serialised: true` ensures events are delivered in order. Use `false` for maximum performance (out-of-order allowed).

// ### Custom Destinations

// Create your own by conforming to `NexusDestination`:

// ```swift
// public protocol NexusDestination: Sendable {
//     func send(
//         type: NexusEventType,
//         time: Date,
//         bundleName: String,
//         appVersion: String,
//         fileName: String,
//         functionName: String,
//         lineNumber: String,
//         threadName: String,
//         message: String,
//         attributes: [String: String]?
//     ) async
// }
// ```

// ---

// ## 💡 Example Output

// ```text
// 🟦 [INFO] 2025-07-02T18:33:12Z HomeView.swift:18 [main] — Screen appeared {"screen":"HomeView"}
// 🟧 [ERROR] 2025-07-02T18:33:13Z NetworkManager.swift:121 [main] — Network unreachable {"retryCount":"2"}
// 🟥 [FAULT] 2025-07-02T18:33:15Z LoginManager.swift:58 [main] — Unexpected nil unwrapped! {"file":"LoginManager.swift"}
// ```

// ---

// ## 📖 Documentation

// - Full API Reference: _Coming soon!_
// - Example project included: see `NexusExampleApp.swift`

// ---

// ## 🤝 Contributing

// Contributions, bug reports, and feature requests welcome!
// - Open issues or pull requests
// - Please follow [Conventional Commits](https://www.conventionalcommits.org/)
// - Code should be Swift 5.9+ and covered by tests

// ---

// ## 📜 License

// MIT License — see `LICENSE` file.

// ---

// ## 💬 Questions / Comments ?

// Open an issue or start a discussion!

// — Made with ❤️ by the Josh Gallant
