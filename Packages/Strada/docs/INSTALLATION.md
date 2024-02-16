# Installation

## Swift Package Manager
Add `strada-ios` as a dependency in your app directly in Xcode or in your `Package.swift` file:

```
dependencies: [
    .package(url: "https://github.com/hotwired/strada-ios", from: "<latest-version>")
]
```

**Note:** `strada-ios` works seamlessly with [turbo-ios](https://github.com/hotwired/turbo-ios) and the documentation provides instructions for integrating Strada with your [Turbo Native](https://turbo.hotwired.dev/handbook/native) app. Keep in mind that `turbo-ios` is not automatically included as a dependency in `strada-ios`, so you'll want to setup your `turbo-ios` app first.
