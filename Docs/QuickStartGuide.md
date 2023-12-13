# Quick Start Guide

This is a quick start guide to creating the most minimal Hotwire Native iOS application from scratch get up and running in a few minutes. This will support basic back/forward navigation, but will not be a fully functional application.

1. First, download and install [Xcode 15+](https://developer.apple.com/xcode/)

2. Create a new iOS app in Xcode via File → New → Project… and choose the default iOS "App" template. Be sure to choose "Swift" under "Language" and "Storyboard" under "Interface" in the project creation dialog.

3. Add the package via File → Add Packages Dependencies… and enter `https://github.com/hotwired/hotwire-native-ios`.

4. Open `SceneDelegate`, and replace the entire file with this code:

```swift
import Hotwire
import UIKit

let rootURL = URL(string: "https://turbo-native-demo.glitch.me")!

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private let navigator = TurboNavigator()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        Hotwire.registerStradaComponents([])
        window?.rootViewController = navigator.rootViewController
        navigator.route(rootURL)
    }
}
```

5. Hit run, and you have a basic working app. You can now tap links and navigate the demo back and forth in the simulator. We've only touched the very core requirements here of creating a `TurboNavigator` and routing the root URL.

Feel free to can change the URL we use for the initial visit to your web app. A real application will want to customize the view controller, respond to different visit actions, gracefully handle errors, and build a more powerful routing system. Read the rest of the documentation to learn more.
