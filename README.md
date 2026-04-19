# EDCSwift

My "every day carry" toolkit for my Swift projects.

## Overview

EDCSwift is a Swift package designed to provide reusable utilities and extensions for iOS, watchOS, and macOS development. It's organized into focused modules covering Swift standard library extensions, SwiftUI components, UIKit helpers, and general utilities.

## Requirements

- **Swift**: 6.0+
- **Platforms**: 
  - iOS 17+
  - watchOS 8+
  - macOS 15+

## Installation

### Swift Package Manager

Add EDCSwift to your Swift Package using Swift Package Manager:

```swift
.package(url: "https://github.com/marlonjames71/EDCSwift.git", from: "0.1.0")
```

Then add it to your target dependencies:
```swift
.target(
    name: "YourTarget",
    dependencies: ["EDCSwift"]
)
```

**...or In your Xcode project**:

1. File  >  Add Package Dependencies
2. Paste URL in search bar: `https://github.com/marlonjames71/EDCSwift.git`
3. Then choose the target you wish to use the package in.

## Features

EDCSwift is organized into several modules:

- Swift: Core Swift language extensions and utilities
- SwiftUI: SwiftUI view modifiers and components
- UIKit: UIKit view controller and view helpers
- Utilities: General-purpose utility functions

## Usage

Import EDCSwift in your Swift files:

```swift
import EDCSwift
```
