//
//  ScreenMetrics.swift
//  ScoreTracker Watch App
//
//  Created by Turgut Egemen Özyürek on 30.08.2025.
//

import SwiftUI

enum SetupScreenMetrics {
    static let buttonStackWidth: CGFloat = 120
    static let buttonTopPadding: CGFloat = 26
    static let contentVerticalOffset: CGFloat = 10
    /// Matches Team # title + icon block height on the color steps.
    static let headerBlockHeight: CGFloat = 80
}

enum MatchScreenMetrics {
    /// Fixed BPM band height (pre-shrink layout) so scoreboards stay put when visuals scale down.
    static let bpmBandHeight: CGFloat = 36
}
