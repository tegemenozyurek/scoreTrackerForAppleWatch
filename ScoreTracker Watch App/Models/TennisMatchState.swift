//
//  TennisMatchState.swift
//  ScoreTracker Watch App
//
//  Created by Turgut Egemen Özyürek on 30.08.2025.
//

import SwiftUI

enum TennisServeSide: String, Equatable {
    case left = "LEFT"
    case right = "RIGHT"
}

struct TennisMatchState: Equatable {
    var point1: Int = 0
    var point2: Int = 0
    var game1: Int = 0
    var game2: Int = 0
    var set1: Int = 0
    var set2: Int = 0
    var servingPlayer: Int = 1
    var serveSide: TennisServeSide = .right
    /// Server for tiebreak point 1 when at 6–6; nil outside tiebreak.
    var tiebreakFirstServer: Int? = nil
    
    private static let pointLabels = ["0", "15", "30", "40"]
    
    func pointDisplay(forTeam team: Int) -> String {
        let points = team == 1 ? point1 : point2
        let opponent = team == 1 ? point2 : point1
        if points < 4 { return Self.pointLabels[points] }
        if opponent >= 3 {
            if points - opponent == 1 { return "Ad" }
            return "40"
        }
        return "40"
    }
    
    mutating func awardPoint(to team: Int) {
        guard team == 1 || team == 2 else { return }
        let serverAtStart = servingPlayer
        let gamesBefore = (game1, game2)
        
        var p1 = point1
        var p2 = point2
        var g1 = game1
        var g2 = game2
        var s1 = set1
        var s2 = set2
        
        if team == 1 {
            Self.applyPoint(
                scorer: &p1,
                other: &p2,
                games: &g1,
                otherGames: &g2,
                sets: &s1,
                otherSets: &s2
            )
        } else {
            Self.applyPoint(
                scorer: &p2,
                other: &p1,
                games: &g2,
                otherGames: &g1,
                sets: &s2,
                otherSets: &s1
            )
        }
        
        point1 = p1
        point2 = p2
        game1 = g1
        game2 = g2
        set1 = s1
        set2 = s2
        
        let gameWon = game1 != gamesBefore.0 || game2 != gamesBefore.1
        advanceServe(gameWon: gameWon, serverAtPointStart: serverAtStart)
    }
    
    private mutating func advanceServe(gameWon: Bool, serverAtPointStart: Int) {
        if gameWon {
            servingPlayer = serverAtPointStart == 1 ? 2 : 1
            serveSide = .right
            if game1 == 6 && game2 == 6 {
                tiebreakFirstServer = servingPlayer
            } else {
                tiebreakFirstServer = nil
            }
            return
        }
        
        if game1 == 6 && game2 == 6 {
            if tiebreakFirstServer == nil {
                tiebreakFirstServer = servingPlayer
            }
            applyTiebreakServeRotation()
        } else {
            tiebreakFirstServer = nil
            serveSide = serveSide == .left ? .right : .left
        }
    }
    
    /// Tiebreak: first server one point, then alternate every two points; side alternates each point.
    private mutating func applyTiebreakServeRotation() {
        guard let first = tiebreakFirstServer else { return }
        let pointsPlayed = point1 + point2
        let serveBlock = max(0, (pointsPlayed - 1) / 2)
        servingPlayer = (serveBlock % 2 == 0) ? first : (3 - first)
        serveSide = (pointsPlayed % 2 == 1) ? .right : .left
    }
    
    private static func applyPoint(
        scorer: inout Int,
        other: inout Int,
        games: inout Int,
        otherGames: inout Int,
        sets: inout Int,
        otherSets: inout Int
    ) {
        var wonGame = false
        
        if scorer >= 3 && other >= 3 {
            if scorer - other >= 1 {
                wonGame = true
            } else if scorer == other {
                scorer += 1
            } else {
                scorer = 3
                other = 3
            }
        } else {
            scorer += 1
            if scorer >= 4 && scorer - other >= 2 {
                wonGame = true
            }
        }
        
        guard wonGame else { return }
        
        games += 1
        scorer = 0
        other = 0
        
        if Self.isSetWon(games: games, otherGames: otherGames) {
            sets += 1
            games = 0
            otherGames = 0
        }
    }
    
    private static func isSetWon(games: Int, otherGames: Int) -> Bool {
        if games >= 6 && games - otherGames >= 2 { return true }
        if games == 7 && otherGames == 5 { return true }
        return false
    }
}
