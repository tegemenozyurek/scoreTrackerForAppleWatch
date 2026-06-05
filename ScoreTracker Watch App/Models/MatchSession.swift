//
//  MatchSession.swift
//  ScoreTracker Watch App
//
//  Created by Turgut Egemen Özyürek on 30.08.2025.
//

import SwiftUI

struct MatchSession: Identifiable {
    let id = UUID()
    let team1Color: Color
    let team2Color: Color
    let sportName: String
    let sportIcon: String
    let initialTimerSeconds: Int
    let countsUp: Bool
    
    var isBasketball: Bool { sportName == "Basketball" }
}
