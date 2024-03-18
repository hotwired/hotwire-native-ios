# Build Bridge Components

## Your first component

After you set up your app in the [Quick Start](QUICK-START.md) guide, it's time to build your first native bridge component. Native components receive messages from corresponding web components of the same `name`. So, be sure to understand how [web components](https://strada.hotwired.dev/handbook/web) work in your web app and start there.

Once a component receives a message, it uses that message's `event` and `data` to perform custom native functionality. If the user performs a native action, the native component can reply back to the corresponding web component using the originally received `message` and (optionally) new `data`.

You create your first native component by subclassing the `BridgeComponent` class. The example below is from the `FormComponent` in the `turbo-ios` [demo app](https://github.com/hotwired/turbo-ios/tree/main/Demo).

Override the `name` to provide the component's name. The `name` (`"form"` in this instance) that you give to each component must be unique and match the name of the web component that it corresponds to.

It'll look like this:

**`FormComponent.swift`**
```swift
final class FormComponent: BridgeComponent {
    override class var name: String { "form" }

    // ...
}
```

## Handle received messages

Every component must implement the `onReceive(message: Message)` function. Each `message` has an `event` associated with it, so you should first look at the `event` to determine how to handle the incoming `message`. Here's how the `FormComponent` handles receiving messages:

**`FormComponent.swift`**
```swift
final class FormComponent: BridgeComponent {
    override class var name: String { "form" }

    override func onReceive(message: Message) {
        guard let event = Event(rawValue: message.event) else {
            return
        }

        switch event {
        case .connect:
            handleConnectEvent(message: message)
        case .submitEnabled:
            handleSubmitEnabled()
        case .submitDisabled:
            handleSubmitDisabled()
        }
    }

    // MARK: Private

    private func handleConnectEvent(message: Message) {
        guard let data: MessageData = message.data() else { return }

        // Write code to display a native submit button in the
        // app bar displayed in the delegate.destination. Use the
        // incoming data.title to set the button title. The
        // implementation depends on how your app is structured.
    }

    private func handleSubmitEnabled() {
        // Write code to enable the submit button.
    }

    private func handleSubmitDisabled() {
        // Write code to disable the submit button.
    }
}

// MARK: Events

private extension FormComponent {
    enum Event: String {
        case connect
        case submitEnabled
        case submitDisabled
    }
}

// MARK: Message data

private extension FormComponent {
    struct MessageData: Decodable {
        let submitTitle: String
    }
}
```

For each `BridgeComponent` subclass that you register in your app, zero or one component instances will exist for each destination screen. A component instance will be created when its first message is received from a corresponding web component of the same `name`. If no messages are received for a particular component in the current destination, no component instance will be created.

By default, `strada-ios` uses [JSONEncoder](https://developer.apple.com/documentation/foundation/jsonencoder) and [JSONDecoder](https://developer.apple.com/documentation/foundation/jsondecoder) to encode/decode `Message.data` with your own data models that implement the `Codeable`/`Decodable`/`Encodable` protocols. See the [Advanced Options](ADVANCED-OPTIONS.md) to configure your encoding/decoding strategy.

## Reply to received messages

If you'd like to inform the corresponding web component that an action has occurred, such as the user tapping on a submit button, you can reply to the originally received message. For the `FormComponent` it looks like this:

**`FormComponent.swift`**
```swift
final class FormComponent: BridgeComponent {

    // ...

    private func configureBarButton(with title: String) {
        guard let viewController else { return }

        let item = UIBarButtonItem(title: title,
                                   style: .plain,
                                   target: self,
                                   action: #selector(performAction))

        // ...
    }

    @objc func performAction() {
        reply(to: Event.connect.rawValue)
    }
}
```

When a web component receives a reply from a sent message, it can run a callback to perform the appropriate action in the web app. In this example, tapping on the native submit button and sending back a reply results in the web `"form"` component clicking the hidden web submit button in its form.

For convenience, there are multiple ways to reply to received messages. If you use `reply(to: eventName)`, the `BridgeComponent` internally replies with the last message received for the given `eventName`. The available reply options are:

```swift
reply(to: "eventName")
reply(to: "eventName", newData)
reply(with: originalMessage)
reply(with: originalMessage.replacing(data: newData))
reply(with: originalMessage.replacing(event: "newEventName"))
```

## Register your component

For every component that you want to use in your app, you must register it in the list you created in the [Quick Start](QUICK-START.md) guide. This allows the web app and backend (through the `WKWebView` user-agent) know what components are natively registered for the current version of the app. To register the new `FormComponent`, it looks like this:

**`BridgeComponent+App.swift`**
```swift
extension BridgeComponent {
    static var allTypes: [BridgeComponent.Type] {
        [
            FormComponent.self
        ]
    }
}
```

## Using your component

Your component is now ready. Whenever a web `form` component exists on a page in your web app, it'll automatically send messages to your app, a `FormComponent` instance will be created for you, and your component's native code will be invoked.
