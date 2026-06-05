//
//  VolleyballMatchState.swift
//  ScoreTracker Watch App
//
//  Created by Turgut Egemen Özyürek on 30.08.2025.
//

import SwiftUI

struct VolleyballMatchState: Equatable {
    static let pointsToWinSet = 25
    static let setsToWinMatch = 3
    static let minPointLead = 2
    
    var point1: Int = 0
    var point2: Int = 0
    var set1: Int = 0
    var set2: Int = 0
    
    var matchWinner: Int? {
        if set1 >= Self.setsToWinMatch { return 1 }
        if set2 >= Self.setsToWinMatch { return 2 }
        return nil
    }
    
    mutating func awardPoint(to team: Int) {
        guard team == 1 || team == 2 else { return }
        guard matchWinner == nil else { return }
        
        if team == 1 {
            point1 += 1
            if Self.isSetWon(scorer: point1, other: point2) {
                set1 += 1
                point1 = 0
                point2 = 0
            }
        } else {
            point2 += 1
            if Self.isSetWon(scorer: point2, other: point1) {
                set2 += 1
                point1 = 0
                point2 = 0
            }
        }
    }
    
    private static func isSetWon(scorer: Int, other: Int) -> Bool {
        scorer >= pointsToWinSet && scorer - other >= minPointLead
    }
}
