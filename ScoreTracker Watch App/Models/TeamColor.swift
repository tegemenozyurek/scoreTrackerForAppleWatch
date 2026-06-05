//
//  TeamColor.swift
//  ScoreTracker Watch App
//
//  Created by Turgut Egemen Özyürek on 30.08.2025.
//

import SwiftUI

enum TeamColor: Int, CaseIterable {
    case red = 0
    case blue = 1
    case green = 2
    case pink = 3
    case purple = 4
    
    var color: Color {
        switch self {
        case .red: .red
        case .blue: .blue
        case .green: .green
        case .pink: .pink
        case .purple: .purple
        }
    }
}
