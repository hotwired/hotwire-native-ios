# Hotwire Native for iOS

**Build high-fidelity hybrid apps with native navigation and a single shared web view.** Hotwire Native for iOS provides the tooling to wrap your [Turbo 7](https://github.com/hotwired/turbo)-enabled web app in a native iOS shell. It manages a single WKWebView instance across multiple view controllers, giving you native navigation UI with all the client-side performance benefits of Turbo.

> [!CAUTION]
> This repo currently points to an unreleased Turbo branch, [turbo-navigator](https://github.com/hotwired/turbo-ios/pull/158).
> When the PR is merged this repo will point back to the official release.

## Features

- **Deliver fast, efficient hybrid apps.** Avoid reloading JavaScript and CSS. Save memory by sharing one WKWebView.
- **Reuse mobile web views across platforms.** Create your views once, on the server, in HTML. Deploy them to iOS, [Android](https://github.com/hotwired/turbo-android), and mobile browsers simultaneously. Ship new features without waiting on App Store approval.
- **Enhance web views with native UI.** Navigate web views using native patterns. Augment web UI with native controls.
- **Produce large apps with small teams.** Achieve baseline HTML coverage for free. Upgrade to native views as needed.

## Requirements

Hotwire Native iOS is written in Swift 5.3 and requires iOS 14 or higher. It supports web apps using either Turbo 7 or Turbolinks 5.

**Note:** You should understand how Turbo works with web applications in the browser before attempting to use Hotwire Native. See the [Turbo 7 documentation](https://github.com/hotwired/turbo) for details. Ensure that your web app sets the `window.Turbo` global variable as it's required by the native apps:

```javascript
import { Turbo } from "@hotwired/turbo-rails"
window.Turbo = Turbo
```

## Getting Started

The best way to get started with Hotwire Native iOS to try out the demo app first to get familiar with the framework. The demo app walks you through all the basic Hotwire Native flows as well as some advanced features. To run the demo, clone this repo and open `Demo/Demo.xcodeproj` in Xcode and run the Demo target. See [Demo/README.md](Demo/README.md) for more details about the demo. When you’re ready to start your own application, read through the rest of the documentation.

Note that this framework is a wrapper around [Turbo iOS](https://github.com/hotwired/turbo-ios) and [Strada iOS](https://github.com/hotwired/strada-ios). Each of these underlying dependencies have their own documentation and guides.

## Installation

Add Hotwire Native as a dependency through Xcode or directly to a Package.swift:

```
.package(url: "https://github.com/hotwired/hotwire-native-ios", from: "<latest-version>")
```

You can also integrate the framework manually if your prefer, such as by adding the repo as a submodule, and linking `Hotwire.framework` to your project.

## Documentation

- [Quick Start](Docs/QuickStartGuide.md)
- [Overview](Docs/Overview.md)
- [Advanced](Docs/Advanced.md)

## Contributing

Hotwire Native iOS is open-source software, freely distributable under the terms of an [MIT-style license](LICENSE). The [source code is hosted on GitHub](https://github.com/hotwired/hotwire-native-ios).
Development is sponsored by [37signals](https://37signals.com/).

We welcome contributions in the form of bug reports, pull requests, or thoughtful discussions in the [GitHub issue tracker](https://github.com/hotwired/hotwire-native-ios/issues).

Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.

---

© 2023 37signals LLC
