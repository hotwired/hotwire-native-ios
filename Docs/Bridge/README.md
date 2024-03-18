# Strada iOS

**[Strada](https://strada.hotwired.dev)** lets you create fully native controls, driven by your web app. It's a set of libraries that work across your [web](https://github.com/hotwired/strada-web), [Android](https://github.com/hotwired/strada-android), and iOS apps to help you build features that make your [Turbo Native](https://turbo.hotwired.dev/handbook/native) hybrid apps stand out. Turn HTML elements that exist in the WebView into native components and communicate messages across your native and web code.

**Strada iOS** enables you to create native components that receive and reply to messages from web components that are present on the page. Native components receive messages to run native code, whether it's to build high fidelity native UI or call platform APIs.

## Features
- **Level up** your [Turbo Native](https://turbo.hotwired.dev/handbook/native) hybrid apps with high-fidelity native components, driven by web components.
- **Reuse web components** for your [Android](https://github.com/hotwired/strada-android) and iOS apps.
- **Communicate with the WebView** and its web components without writing any JavaScript in your app.

## Requirements

1. iOS 14 or higher is required for your app.
1. This library is written entirely in [Swift](https://www.swift.org/), and your app should use Swift as well.
1. This library supports [Turbo Native](https://turbo.hotwired.dev/handbook/native) hybrid apps.
1. Your web app must be running [strada-web](https://github.com/hotwired/strada-web). The `window.Strada` object is automatically exposed on the loaded WebView page, which enables `strada-ios` to work.

**Note:** You should understand how Strada works in the browser before attempting to use Strada iOS. See the [Strada documentation](https://strada.hotwired.dev) for details.

## Getting Started
The best way to get started with Strada iOS is to try out the Turbo iOS demo app first to get familiar with the framework and what it offers. The demo app provides several Strada component examples. To run the demo, clone the [turbo-ios](https://github.com/hotwired/turbo-ios) repo, and read the [instructions](https://github.com/hotwired/turbo-ios/tree/main/Demo#readme).

## Documentation

1. [Installation](docs/INSTALLATION.md)
1. [Overview](docs/OVERVIEW.md)
1. [Quick Start](docs/QUICK-START.md)
1. [Build Components](docs/BUILD-COMPONENTS.md)
1. [Advanced Options](docs/ADVANCED-OPTIONS.md)

## Contributing

Strada iOS is open-source software, freely distributable under the terms of an [MIT-style license](LICENSE). The [source code is hosted on GitHub](https://github.com/hotwired/strada-ios). Development is sponsored by [37signals](https://37signals.com/).

We welcome contributions in the form of bug reports, pull requests, or thoughtful discussions in the [GitHub issue tracker](https://github.com/hotwired/strada-ios/issues).

Please note that this project is released with a [Contributor Code of Conduct](docs/CONDUCT.md). By participating in this project you agree to abide by its terms.

---------

© 2023 37signals LLC
