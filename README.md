<p align="center">
  <img src="NexusExample/nexus.png" alt="App Screenshot" width="300" />
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Swift-5.9%2B-orange?style=flat-square" alt="Swift Version" />
  <img src="https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS%20%7C%20watchOS%20%7C%20tvOS-blue?style=flat-square" alt="Platforms" />
  <img src="https://img.shields.io/badge/SPM-ready-green?style=flat-square" alt="SPM Ready" />
  <img src="https://img.shields.io/badge/License-MIT-lightgrey?style=flat-square" alt="MIT License" />
</p>

<p align="center">
  <em>A modern, concurrency-safe, fire-and-forget logging and tracking interface for all your Swift applications. Flexible input. Flexible output. Gorgeous developer experience.</em>
</p>


<p align="center"\>
<img src="NexusExample/example.png" alt="App Screenshot" width="10000"/\>
</p>


## <br> 📦 Installation
### Swift Package Manager (Preferred)

1.  In Xcode: *File \> Add Packages...*
2.  Enter repo URL:
    ```
    https://github.com/joshgallantt/Nexus.git
    ```
3.  Add `Nexus` as a dependency to your target.


## <br> ✨ Quick Start

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

## <br> 🧠 Why Nexus?

Logging and analytics in Swift are fragmented, inconsistent, and often bolted on as an afterthought. Most teams end up with:

* 🧩 Dozens of custom `print` or `os_log` statements
* 🧪 Unstructured events tossed into multiple analytics platforms
* 🛠️ Painful process every time you integrate or remove a new service (Firebase, Mparticle, Mixpanel, Sentry, etc.)
* 😵 Confusing or unsafe concurrency around logging

**Nexus** was built to fix all of that. It's your app's **central nervous system for events**, designed to:

* 💡 **Standardize how you log and track**
* 🧵 **Guarantee thread-safety and performance**
* 🎯 **Route logs/events flexibly** to multiple outputs
* 🧱 **Scale with your architecture** (from toy apps to massive multi-module clients)

## <br> 🧬 Design Philosophy

Nexus is built with these core tenets:

* **Composability over hardcoding** – define your event once, route it anywhere: console, analytics, files, crash logs, and more.
* **First-class concurrency** – every part of Nexus is actor-based and thread-safe by default. Fire-and-forget, even from async contexts.
* **Stays out of your way** – drop-in logging, zero-config defaults, and Swift-native ergonomics.
* **Scalable architecture** – from side-projects to production apps, Nexus grows with your needs. Add new destinations their logic without touching call sites.
* **No Dependancies** – Ever.


## <br> ✨ What Makes Nexus Different?

While most logging tools focus on one job (e.g., logs to console), Nexus is built around **composable event routing**:

| Capability                              | Nexus | OSLog | Firebase | Custom DIY |
| --------------------------------------- | ----- | ----- | -------- | ---------- |
| Multi-destination routing               | ✅     | ❌     | ❌      | ❓         |
| Extensible with custom backends         | ✅     | ❌     | ❌      | 🔧         |
| Thread-safe, actor-backed delivery      | ✅     | ❌     | ❌      | ❌         |
| Tracks logs *and* analytics             | ✅     | ❌     | ✅      | ⚠️         |
| Works across iOS, macOS, watchOS, tvOS  | ✅     | ✅     | ✅      | Depends    |
| Fire-and-forget with structured context | ✅     | ❌     | ⚠️      |❌          |

---

## <br> 🪄 Example Use Case: Firebase + Console + File

```swift
import Nexus

Nexus.addDestination(OSLoggerHumanReadable())
Nexus.addDestination(FirebaseDestination(), serialised: false)
Nexus.addDestination(FileLogger("/logs/analytics.log"))

Nexus.track("User started onboarding", attributes: ["step": "1"])
```

That’s it. Events are sent to all destinations concurrently and safely. No juggling SDKs or writing glue code. No threading bugs.

## <br> 🧵 Event Serialization

```swift
Nexus.addDestination(MyDestination(), serialised: true)
```

The `serialised` parameter controls how events are delivered to a destination:

* `true` *(default)*: Events are delivered **one at a time and in the exact order** they were sent.
  Use this when your destination depends on **strict sequencing**—such as session tracking or event chaining.

* `false`: Events may be delivered **concurrently or in batches**, potentially out of order.
  This offers **higher throughput** and is ideal for analytics services or destinations where **ordering doesn't matter**.

## <br> Custom Destinations ⭐🚀🪐

Create your own by conforming to `NexusDestination`. Use as little or as much data as you'd like before sending it off to wherever you please\!

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

## <br> Example Firebase Destination
```swift
import Foundation
import FirebaseAnalytics

public struct FirebaseDestination: NexusDestination {
    public init() {}

    public func send(
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
        attributes: [String: String]? = nil,
        routingKey: String? = nil
    ) {
        guard routingKey == "firebase" else { return }

        var eventParams = attributes ?? [:]
        eventParams["type"] = type.name
        eventParams["timestamp"] = ISO8601DateFormatter().string(from: time)
        eventParams["deviceModel"] = deviceModel
        eventParams["osVersion"] = osVersion
        eventParams["bundleName"] = bundleName
        eventParams["appVersion"] = appVersion
        eventParams["fileName"] = fileName
        eventParams["functionName"] = functionName
        eventParams["lineNumber"] = lineNumber
        eventParams["threadName"] = threadName
        eventParams["message"] = message
        eventParams["routingKey"] = routingKey

        Analytics.logEvent(message, parameters: eventParams)
    }
}
```


## <br> 📖 Documentation

  - Full API Reference: *Coming soon\!*
  - Example project included: see `NexusExampleApp.swift`


## <br> 🤝 Contributing

Contributions, bug reports, and feature requests are welcome\!

  - Open issues or pull requests.
  - Code should be Swift 5.9+ and covered by tests.


## <br> 📜 License

MIT License — see `LICENSE` file.

## <br> 💬 Questions, Comments, Concerns?

Open an issue or start a discussion\!

— Made with ❤️ by Josh Gallant
