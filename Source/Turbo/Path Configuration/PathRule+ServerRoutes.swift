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
            "historical_location": true
        ]
    )

    static let resumeHistoricalLocation = PathRule(
        patterns: ["/resume_historical_location"],
        properties: [
            "presentation": "none",
            "historical_location": true
        ]
    )

    static let refreshHistoricalLocation = PathRule(
        patterns: ["/refresh_historical_location"],
        properties: [
            "presentation": "refresh",
            "historical_location": true
        ]
    )
}
