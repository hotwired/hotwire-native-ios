# Hotwire Native for iOS

This repo combines [turbo-ios](https://github.com/hotwired/turbo-ios) and [strada-ios](https://github.com/hotwired/strada-ios) to make it even easier to get started.

> [!CAUTION]
> This repo currently points to an unreleased Turbo branch, [turbo-navigator](https://github.com/hotwired/turbo-ios/pull/158).
> When the PR is merged this repo will point back to the official release.

## Quick start

Check out the demo app in the `Demo/` directory to get a feel for Hotwire Native.

1. Download and install [Xcode 15+](https://developer.apple.com/xcode/)
1. Clone this repository
1. Open `Demo/Demo.xcodeproj`

## Create a new app

Alternatively, create your own app from scratch and integrate Hotwire Native.

First, download and install [Xcode 15+](https://developer.apple.com/xcode/)

### Create a new project

1. Open Xcode and create a new project via File → New Project…
1. Select the iOS tab and then App from the Application section and click Next
1. Enter or select the following options and click Next:
    * Product Name: HotwireNative
    * Organization Identifier: com.example
    * Interface: Storyboard
    * Language: Swift
    * Storage: None
    * Include Tests: (unchecked)
1. Select a location and click Create

### Add the hotwire-native-ios package

1. Click File → Add Package Dependencies…
1. Enter `https://github.com/hotwired/turbo-ios` in the search bar in the upper right
1. Click Add Package

### Integrate the package

1. Click `SceneDelegate` from the left pane and replace the contents with the following:

```swift
import Hotwire
import UIKit

let rootURL = URL(string: "https://turbo-native-demo.glitch.me")!

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private let navigator = TurboNavigator()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        window?.rootViewController = navigator.rootViewController
        navigator.route(rootURL)
    }
}
```
