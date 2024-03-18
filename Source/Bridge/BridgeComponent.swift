import Foundation

@MainActor
protocol BridgingComponent: AnyObject {
    static var name: String { get }
    var delegate: BridgingDelegate { get }
    
    init(destination: BridgeDestination,
         delegate: BridgingDelegate)
    
    func onReceive(message: Message)
    func onViewDidLoad()
    func onViewWillAppear()
    func onViewDidAppear()
    func onViewWillDisappear()
    func onViewDidDisappear()
    
    func didReceive(message: Message)
    func viewDidLoad()
    func viewWillAppear()
    func viewDidAppear()
    func viewWillDisappear()
    func viewDidDisappear()
}

@MainActor
open class BridgeComponent: BridgingComponent {
    public typealias ReplyCompletionHandler = (Result<Bool, Error>) -> Void

    /// A unique name representing the `BridgeComponent` type.
    ///
    /// Subclasses must provide their own implementation of this property.
    ///
    /// - Note: This property is used for identifying the component.
    nonisolated open class var name: String {
        fatalError("BridgeComponent subclass must provide a unique 'name'")
    }
    
    public unowned let delegate: BridgingDelegate
    
    required public init(destination: BridgeDestination, delegate: BridgingDelegate) {
        self.delegate = delegate
    }
    
    /// Called when a message is received from the web bridge.
    /// Handle the message for its `event` type for the custom component's behavior.
    /// - Parameter message: The `message` received from the web bridge.
    open func onReceive(message: Message) {
        fatalError("BridgeComponent subclass must handle incoming messages")
    }
    
    @discardableResult
    /// Replies to the web with a received message, optionally replacing its `event` or `jsonData`.
    ///
    /// - Parameter message: The message to be replied with.
    /// - Returns: `true` if the reply was successful, `false` if the bridge is not available.
    public func reply(with message: Message) async throws -> Bool {
        try await delegate.reply(with: message)
    }

    /// Replies to the web with a received message, optionally replacing its `event` or `jsonData`.
    ///
    /// - Parameters:
    ///     - message: The message to be replied with.
    ///     - completion: An optional completion handler to be called when the reply attempt completes.
    ///                   It includes a result indicating whether the reply was successful or not.
    public func reply(with message: Message, completion: ReplyCompletionHandler? = nil) {
        Task {
            do {
                let result = try await delegate.reply(with: message)
                completion?(.success((result)))
            } catch {
                completion?(.failure(error))
            }
        }
    }

    @discardableResult
    /// Replies to the web with the last received message for a given `event` with its original `jsonData`.
    ///
    /// NOTE: If a message has not been received for the given `event`, the reply will be ignored.
    ///
    /// - Parameter event: The `event` for which a reply should be sent.
    /// - Returns: `true` if the reply was successful, `false` if the event message was not received.
    public func reply(to event: String) async throws -> Bool {
        guard let message = receivedMessage(for: event) else {
            logger.warning("bridgeMessageFailedToReply: message for event \(event) was not received")
            return false
        }
        
        return try await reply(with: message)
    }

    /// Replies to the web with the last received message for a given `event` with its original `jsonData`.
    ///
    /// NOTE: If a message has not been received for the given `event`, the reply will be ignored.
    ///
    /// - Parameters:
    ///     - event: The `event` for which a reply should be sent.
    ///     - completion: An optional completion handler to be called when the reply attempt completes.
    ///                   It includes a result indicating whether the reply was successful or not.
    public func reply(to event: String, completion: ReplyCompletionHandler? = nil) {
        Task {
            do {
                let result = try await reply(to: event)
                completion?(.success((result)))
            } catch {
                completion?(.failure(error))
            }
        }
    }

    @discardableResult
    /// Replies to the web with the last received message for a given `event`, replacing its `jsonData`.
    ///
    /// NOTE: If a message has not been received for the given `event`, the reply will be ignored.
    ///
    /// - Parameters:
    ///   - event: The `event` for which a reply should be sent.
    ///   - jsonData: The `jsonData` to be included in the reply message.
    /// - Returns: `true` if the reply was successful, `false` if the event message was not received.
    public func reply(to event: String, with jsonData: String) async throws -> Bool {
        guard let message = receivedMessage(for: event) else {
            logger.warning("bridgeMessageFailedToReply: message for event \(event) was not received")
            return false
        }
        
        let messageReply = message.replacing(jsonData: jsonData)
        return try await reply(with: messageReply)
    }
    
    /// Replies to the web with the last received message for a given `event`, replacing its `jsonData`.
    ///
    /// NOTE: If a message has not been received for the given `event`, the reply will be ignored.
    ///
    /// - Parameters:
    ///   - event: The `event` for which a reply should be sent.
    ///   - jsonData: The `jsonData` to be included in the reply message.
    ///   - completion: An optional completion handler to be called when the reply attempt completes.
    ///                 It includes a result indicating whether the reply was successful or not.
    public func reply(to event: String, with jsonData: String, completion: ReplyCompletionHandler? = nil) {
        Task {
            do {
                let result = try await reply(to: event, with: jsonData)
                completion?(.success((result)))
            } catch {
                completion?(.failure(error))
            }
        }
    }
    
    @discardableResult
    /// Replies to the web with the last received message for a given `event`, replacing its `jsonData`
    /// with the provided `Encodable` object.
    ///
    /// NOTE: If a message has not been received for the given `event`, the reply will be ignored.
    ///
    /// - Parameters:
    ///   - event: The `event` for which a reply should be sent.
    ///   - data: An instance conforming to `Encodable` to be included as `jsonData` in the reply message.
    /// - Returns: `true` if the reply was successful, `false` if the event message was not received.
    public func reply<T: Encodable>(to event: String, with data: T) async throws -> Bool {
        guard let message = receivedMessage(for: event) else {
            logger.warning("bridgeMessageFailedToReply: message for event \(event) was not received")
            return false
        }
        
        let messageReply = message.replacing(data: data)
        return try await reply(with: messageReply)
    }
    
    /// Replies to the web with the last received message for a given `event`, replacing its `jsonData`
    /// with the provided `Encodable` object.
    ///
    /// NOTE: If a message has not been received for the given `event`, the reply will be ignored.
    ///
    /// - Parameters:
    ///   - event: The `event` for which a reply should be sent.
    ///   - data: An instance conforming to `Encodable` to be included as `jsonData` in the reply message.
    ///   - completion: An optional completion handler to be called when the reply attempt completes.
    ///                 It includes a result indicating whether the reply was successful or not.
    public func reply<T: Encodable>(to event: String, with data: T, completion: ReplyCompletionHandler? = nil) {
        Task {
            do {
                let result = try await reply(to: event, with: data)
                completion?(.success((result)))
            } catch {
                completion?(.failure(error))
            }
        }
    }
    
    /// Returns the last received message for a given `event`, if available.
    /// - Parameter event: The event name.
    /// - Returns: The last received message, or nil.
    public func receivedMessage(for event: String) -> Message? {
        return receivedMessages[event]
    }
    
    /// Called when the component's destination view is loaded into memory
    /// (and is active) based on its lifecycle events.
    /// You can use this as an opportunity to update the component's state/view.
    open func onViewDidLoad() {}
    
    /// Called when the component's destination view is about to be added to a view hierarchy
    /// (and is active) based on its lifecycle events.
    /// You can use this as an opportunity to update the component's state/view.
    open func onViewWillAppear() {}
    
    /// Called when the component's destination view was added to a view hierarchy
    /// (and is active) based on its lifecycle events.
    /// You can use this as an opportunity to update the component's state/view.
    open func onViewDidAppear() {}
    
    /// Called when the component's destination view is about to be removed from a view hierarchy
    /// (and is inactive) based on its lifecycle events.
    /// You can use this as an opportunity to update the component's state/view.
    open func onViewWillDisappear() {}
    
    /// Called when the component's destination view was removed from a view hierarchy
    /// (and is inactive) based on its lifecycle events.
    /// You can use this as an opportunity to update the component's state/view.
    open func onViewDidDisappear() {}
    
    /// This passes a received message to `onReceive(message:)`, caching it
    /// for use with `reply(to: with:)` and `receivedMessage(for:)`.
    ///
    /// NOTE: This should not be called directly from within a component,
    /// but is available to use for testing.
    /// - Parameter message: The `message` received from the web bridge.
    public func didReceive(message: Message) {
        receivedMessages[message.event] = message
        onReceive(message: message)
    }
    
    /// This passes the `viewDidLoad` lifecycle event to `onViewDidLoad()`.
    ///
    /// NOTE: This should not be called directly from within a component,
    /// but is available to use for testing.
    public func viewDidLoad() {
        onViewDidLoad()
    }
    
    /// This passes the `viewWillAppear` lifecycle event to `onViewWillAppear()`.
    ///
    /// NOTE: This should not be called directly from within a component,
    /// but is available to use for testing.
    public func viewWillAppear() {
        onViewWillAppear()
    }
    
    /// This passes the `viewDidAppear` lifecycle event to `onViewDidAppear()`.
    ///
    /// NOTE: This should not be called directly from within a component,
    /// but is available to use for testing.
    public func viewDidAppear() {
        onViewDidAppear()
    }
    
    /// This passes the `viewWillDisappear` lifecycle event to `onViewWillDisappear()`.
    ///
    /// NOTE: This should not be called directly from within a component,
    /// but is available to use for testing.
    public func viewWillDisappear() {
        onViewWillDisappear()
    }
    
    /// This passes the `viewDidDisappear` lifecycle event to `onViewDidDisappear()`.
    ///
    /// NOTE: This should not be called directly from within a component,
    /// but is available to use for testing.
    public func viewDidDisappear() {
        onViewDidDisappear()
    }
    
    // MARK: Private
    
    private var receivedMessages = [String: Message]()
}

