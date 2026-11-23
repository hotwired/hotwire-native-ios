import Foundation

public struct VisitProposal {
    public struct ModalRedirect {
        public let modalURL: URL
        public let presentingPageURL: URL?
    }

    public let url: URL
    public let options: VisitOptions
    public let properties: PathProperties
    public let parameters: [String: Any]?
    public let modalRedirect: ModalRedirect?

    public init(url: URL, options: VisitOptions, properties: PathProperties = [:], parameters: [String: Any]? = nil) {
        self.init(url: url, options: options, properties: properties, parameters: parameters, modalRedirect: nil)
    }

    init(url: URL, options: VisitOptions, properties: PathProperties, parameters: [String: Any]?, modalRedirect: ModalRedirect?) {
        self.url = url
        self.options = options
        self.properties = properties
        self.parameters = parameters
        self.modalRedirect = modalRedirect
    }
}
