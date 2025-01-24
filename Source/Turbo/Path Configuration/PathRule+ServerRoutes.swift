import Foundation

extension PathRule {
    static let defaultServerRoutes: [PathRule] = [
        .recedeHistoricalLocation,
        .resumeHistoricalLocation,
        .refreshHistoricalLocation
    ]

    static let recedeHistoricalLocation = PathRule(
        patterns: ["/recede_historical_location"],
        properties: [
            "presentation": "pop",
            "visitable": false
        ]
    )

    static let resumeHistoricalLocation = PathRule(
        patterns: ["/resume_historical_location"],
        properties: [
            "presentation": "none",
            "visitable": false
        ]
    )

    static let refreshHistoricalLocation = PathRule(
        patterns: ["/refresh_historical_location"],
        properties: [
            "presentation": "refresh",
            "visitable": false
        ]
    )
}
