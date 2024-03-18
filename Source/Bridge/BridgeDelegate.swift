import Foundation
import WebKit

public protocol BridgeDestination: AnyObject {}

@MainActor
public protocol BridgingDelegate: AnyObject {
    var location: String { get }
    var destination: BridgeDestination { get }
    var webView: WKWebView? { get }
    
    func webViewDidBecomeActive(_ webView: WKWebView)
    func webViewDidBecomeDeactivated()
    func reply(with message: Message) async throws -> Bool

    func onViewDidLoad()
    func onViewWillAppear()
    func onViewDidAppear()
    func onViewWillDisappear()
    func onViewDidDisappear()
    
    func component<C: BridgeComponent>() -> C?
    
    func bridgeDidInitialize()
    func bridgeDidReceiveMessage(_ message: Message) -> Bool
}

@MainActor
public final class BridgeDelegate: BridgingDelegate {
    public let location: String
    public unowned let destination: BridgeDestination
    public var webView: WKWebView? {
        bridge?.webView
    }
    
    weak var bridge: Bridgable?
    
    public init(location: String,
                destination: BridgeDestination,
                componentTypes: [BridgeComponent.Type]) {
        self.location = location
        self.destination = destination
        self.componentTypes = componentTypes
    }
    
    public func webViewDidBecomeActive(_ webView: WKWebView) {
        bridge = Bridge.getBridgeFor(webView)
        bridge?.delegate = self
        
        if bridge == nil {
            logger.warning("bridgeNotInitializedForWebView")
        }
    }
    
    public func webViewDidBecomeDeactivated() {
        bridge?.delegate = nil
        bridge = nil
    }
    
    @discardableResult
    /// Replies to the web with a received message, optionally replacing its `event` or `jsonData`.
    ///
    /// - Parameter message: The message to be replied with.
    /// - Returns: `true` if the reply was successful, `false` if the bridge is not available.
    public func reply(with message: Message) async throws -> Bool {
        guard let bridge else {
            logger.warning("bridgeMessageFailedToReply: bridge is not available")
            return false
        }
        
        try await bridge.reply(with: message)
        return true
    }
    
    // MARK: - Destination lifecycle
    
    public func onViewDidLoad() {
        logger.debug("bridgeDestinationViewDidLoad: \(self.resolvedLocation)")
        destinationIsActive = true
        activeComponents.forEach { $0.viewDidLoad() }
    }
    
    public func onViewWillAppear() {
        logger.debug("bridgeDestinationViewWillAppear: \(self.resolvedLocation)")
        destinationIsActive = true
        activeComponents.forEach { $0.viewWillAppear() }
    }
    
    public func onViewDidAppear() {
        logger.debug("bridgeDestinationViewDidAppear: \(self.resolvedLocation)")
        destinationIsActive = true
        activeComponents.forEach { $0.viewDidAppear() }
    }
    
    public func onViewWillDisappear() {
        activeComponents.forEach { $0.viewWillDisappear() }
        logger.debug("bridgeDestinationViewWillDisappear: \(self.resolvedLocation)")
    }
    
    public func onViewDidDisappear() {
        activeComponents.forEach { $0.viewDidDisappear() }
        destinationIsActive = false
        logger.debug("bridgeDestinationViewDidDisappear: \(self.resolvedLocation)")
    }
    
    // MARK: Retrieve component by type
    
    public func component<C: BridgeComponent>() -> C? {
        return activeComponents.compactMap { $0 as? C }.first
    }
    
    // MARK: Internal use
    
    public func bridgeDidInitialize() {
        let componentNames = componentTypes.map { $0.name }
        Task {
            do {
                try await bridge?.register(components: componentNames)
            } catch {
                logger.error("bridgeDidFailToRegisterComponents: \(error)")
            }
        }
    }
    
    @discardableResult
    public func bridgeDidReceiveMessage(_ message: Message) -> Bool {
        guard destinationIsActive,
              resolvedLocation == message.metadata?.url else {
            logger.warning("bridgeDidIgnoreMessage: \(String(describing: message))")
            return false
        }
        
        logger.debug("bridgeDidReceiveMessage \(String(describing: message))")
        getOrCreateComponent(name: message.component)?.didReceive(message: message)
        
        return true
    }
    
    // MARK: Private
    
    private var initializedComponents: [String: BridgeComponent] = [:]
    private var destinationIsActive = false
    private let componentTypes: [BridgeComponent.Type]
    private var resolvedLocation: String {
        webView?.url?.absoluteString ?? location
    }
    
    private var activeComponents: [BridgeComponent] {
        return initializedComponents.values.filter { _ in destinationIsActive }
    }
    
    private func getOrCreateComponent(name: String) -> BridgeComponent? {
        if let component = initializedComponents[name] {
            return component
        }
        
        guard let componentType = componentTypes.first(where: { $0.name == name }) else {
            return nil
        }
        
        let component = componentType.init(destination: destination, delegate: self)
        initializedComponents[name] = component
        
        return component
    }
}
