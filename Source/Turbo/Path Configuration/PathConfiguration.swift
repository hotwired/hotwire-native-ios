import Foundation

public typealias PathProperties = [String: AnyHashable]

public protocol PathConfigurationDelegate: AnyObject {
    /// Notifies delegate when a path configuration has been updated with new data
    func pathConfigurationDidUpdate()
}

public struct PathConfigurationLoaderOptions {
    public init(urlSessionConfiguration: URLSessionConfiguration? = nil) {
        self.urlSessionConfiguration = urlSessionConfiguration
    }

    /// If present, the ``PathConfigurationLoader`` will initialize a new `URLSession` with
    /// this configuration to make its network request
    public let urlSessionConfiguration: URLSessionConfiguration?
}

public final class PathConfiguration {
    public weak var delegate: PathConfigurationDelegate?

    /// Enable to include the query string (in addition to the path) when applying rules.
    /// Disable to only consider the path when applying rules.
    public var matchQueryStrings = true

    /// Returns top-level settings: `{ settings: {} }`
    public private(set) var settings: [String: AnyHashable] = [:]

    /// The list of rules from the configuration: `{ rules: [] }`
    /// Default server route rules are included by default.
    public private(set) var rules: [PathRule] = PathRule.defaultServerRoutes

    /// Sources for this configuration, setting it will
    /// cause the configuration to be loaded from the new sources
    public var sources: [Source] = [] {
        didSet {
            load()
        }
    }

    /// Multiple sources will be loaded in order
    /// Remote sources should be last since they're loaded async
    public init(sources: [Source] = [], options: PathConfigurationLoaderOptions? = nil) {
        self.sources = sources
        self.options = options
        load()
    }

    /// Convenience method for getting properties for path: configuration["/path"]
    public subscript(path: String) -> PathProperties {
        properties(for: path)
    }

    /// Convenience method for retrieving properties for url: configuration[url]
    public subscript(url: URL) -> PathProperties {
        properties(for: url)
    }

    /// Returns a merged dictionary containing all the properties that match this URL.
    public func properties(for url: URL) -> PathProperties {
        if Hotwire.config.pathConfiguration.matchQueryStrings, let query = url.query {
            return properties(for: "\(url.path)?\(query)")
        }
        return properties(for: url.path)
    }

    /// Returns a merged dictionary containing all the properties
    /// that match this path
    public func properties(for path: String) -> PathProperties {
        var properties: PathProperties = [:]

        for rule in rules where rule.match(path: path) {
            properties.merge(rule.properties) { _, new in new }
        }

        return properties
    }

    // MARK: - Loading

    private let options: PathConfigurationLoaderOptions?

    private var loader: PathConfigurationLoader?

    private func load() {
        loader = PathConfigurationLoader(sources: sources, options: options)
        loader?.load { [weak self] config in
            self?.update(with: config)
        }
    }

    private func update(with config: PathConfigurationDecoder) {
        // Update our internal state with the config from the loader
        settings = config.settings
        rules = config.rules
        // Always include the default server route rules.
        rules.append(contentsOf: PathRule.defaultServerRoutes)
        delegate?.pathConfigurationDidUpdate()
    }
}

extension PathConfiguration: Equatable {
    public static func == (lhs: PathConfiguration, rhs: PathConfiguration) -> Bool {
        lhs.settings == rhs.settings && lhs.rules == rhs.rules
    }
}

public extension PathConfiguration {
    enum Source: Equatable {
        case data(Data)
        case file(URL)
        case server(URL)
    }
}
