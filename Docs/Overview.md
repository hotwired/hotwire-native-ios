# Overview

Hotwire Native iOS is a wrapper around [Turbo iOS](https://github.com/hotwired/turbo-ios) and [Strada iOS](https://github.com/hotwired/strada-ios). It provides sane defaults to get the two frameworks working together and minimize boilerplate code on your send.

Here are the additional changes, features, and configuration that Hotwire Native iOS provides on top of the two frameworks.

## Imports

Importing Hotwire imports both Turbo and Strada. You don't need to import each framework individually.

```swift
import HotwireNative

let navigator = Navigator() // Part of Turbo
final class FormComponent: BridgeComponent { /* ... */ } // Part of Strada
```

## Strada Integration

Hotwire Native iOS configures Strada for you. All you need to do is register your components.

```swift
Hotwire.registerStradaComponents([
    // Your strada components go here.
])
```

Make sure to call this function before interacting with a Turbo Navigator.

Registering components automatically sets the user agent, initializes the Strada bridge on the web view, and configures Strada-enabled view controller.

## Configuration

By default, a `HotwireWebViewController` is used for all web visits. You're free to subclass this and add additional functionality. Make sure to set `Hotwire.config.defaultViewController` so Turbo Navigator knows to use your custom class.

```swift
class WebViewController: HotwireViewController {
    // Add your customizations here.
}

Hotwire.config.defaultViewController = { url in
    WebViewController(url: url)
}
```

Add a Done button to modals via:

```swift
Hotwire.config.showDoneButtonOnModals = true
```

Configure the back button display mode via:

```swift
Hotwire.config.backButtonDisplayMode = .minimal
```

Enable/disable logging via:

```swift
#if DEBUG
Hotwire.config.debugLoggingEnabled = true
#endif
```
