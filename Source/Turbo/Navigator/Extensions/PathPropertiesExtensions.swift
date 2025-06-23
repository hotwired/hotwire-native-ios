public extension PathProperties {
    var context: Navigation.Context {
        guard let rawValue = self["context"] as? String,
              let context = Navigation.Context(rawValue: rawValue) else {
            return .default
        }

        return context
    }

    var presentation: Navigation.Presentation {
        guard let rawValue = self["presentation"] as? String,
              let presentation = Navigation.Presentation(rawValue: rawValue) else {
            return .default
        }

        return presentation
    }

    var modalStyle: Navigation.ModalStyle {
        guard let rawValue = self["modal_style"] as? String,
              let modalStyle = Navigation.ModalStyle(rawValue: rawValue) else {
            return .large
        }

        return modalStyle
    }

    var pullToRefreshEnabled: Bool {
        self["pull_to_refresh_enabled"] as? Bool ?? true
    }

    var modalDismissGestureEnabled: Bool {
        self["modal_dismiss_gesture_enabled"] as? Bool ?? true
    }

    /// Used to identify a custom native view controller if provided in the path configuration properties of a given pattern.
    ///
    /// For example, given the following configuration file:
    ///
    /// ```json
    /// {
    ///   "rules": [
    ///     {
    ///       "patterns": [
    ///         "/recipes/*"
    ///       ],
    ///       "properties": {
    ///         "view_controller": "recipes",
    ///       }
    ///     }
    ///  ]
    /// }
    /// ```
    ///
    /// A VisitProposal to `https://example.com/recipes/` will have
    /// ```swift
    /// proposal.viewController == "recipes"
    /// ```
    ///
    /// - Important: A default value is provided in case the view controller property is missing from the configuration file. This will route the default `VisitableViewController`.
    /// - Note: A `ViewController` must conform to `PathConfigurationIdentifiable` to couple the identifier with a view controlelr.
    var viewController: String {
        guard let viewController = self["view_controller"] as? String else {
            return VisitableViewController.pathConfigurationIdentifier
        }

        return viewController
    }

    /// Allows the proposal to change the animation status when pushing, popping or presenting.
    var animated: Bool {
        self["animated"] as? Bool ?? true
    }

    internal var historicalLocation: Bool {
        self["historical_location"] as? Bool ?? false
    }

    var queryStringPresentation: Navigation.QueryStringPresentation {
        guard let rawValue = self["query_string_presentation"] as? String,
              let presentation = Navigation.QueryStringPresentation(rawValue: rawValue) else {
            return .default
        }

        return presentation
    }
}
