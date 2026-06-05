//
//  ScoreboardScoreRow.swift
//  ScoreTracker Watch App
//
//  Created by Turgut Egemen Özyürek on 30.08.2025.
//

import SwiftUI

struct ScoreboardScoreRow: View {
    let team1Color: Color
    let team2Color: Color
    let sportIcon: String
    let team1Score: Int
    let team2Score: Int
    let team1Spin: Double
    let team2Spin: Double
    var allowsScoreTapIncrement: Bool = true
    let onGoalTeam1: () -> Void
    let onGoalTeam2: () -> Void
    let onDecrementTeam1: () -> Void
    let onDecrementTeam2: () -> Void
    
    var body: some View {
        GeometryReader { geo in
            let horizontalSpacing: CGFloat = 4
            let dashWidth: CGFloat = 12
            let ballSide = min(46, max(34, geo.size.width * 0.21))
            let scoreAreaWidth = max(
                0,
                geo.size.width - (ballSide * 2) - dashWidth - (horizontalSpacing * 4)
            )
            let scoreColumnWidth = max(22, scoreAreaWidth / 2)
            let maxScore = max(team1Score, team2Score)
            let scoreFontSize = scoreFontSize(for: maxScore, columnWidth: scoreColumnWidth)
            let dashFontSize = max(18, scoreFontSize * 0.75)
            
            HStack(spacing: horizontalSpacing) {
                TeamScoreBall(
                    color: team1Color,
                    sportIcon: sportIcon,
                    spinDegrees: team1Spin,
                    side: ballSide,
                    onIncrement: onGoalTeam1,
                    onDecrement: onDecrementTeam1
                )
                
                HStack(spacing: 2) {
                    MatchScoreLabel(
                        score: team1Score,
                        columnWidth: scoreColumnWidth,
                        fontSize: scoreFontSize,
                        onGoal: allowsScoreTapIncrement ? onGoalTeam1 : {},
                        onDecrement: onDecrementTeam1
                    )
                    
                    Text("-")
                        .font(.system(size: dashFontSize, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                        .frame(width: dashWidth)
                        .lineLimit(1)
                    
                    MatchScoreLabel(
                        score: team2Score,
                        columnWidth: scoreColumnWidth,
                        fontSize: scoreFontSize,
                        onGoal: allowsScoreTapIncrement ? onGoalTeam2 : {},
                        onDecrement: onDecrementTeam2
                    )
                }
                .fixedSize(horizontal: true, vertical: false)
                .layoutPriority(1)
                
                TeamScoreBall(
                    color: team2Color,
                    sportIcon: sportIcon,
                    spinDegrees: team2Spin,
                    side: ballSide,
                    onIncrement: onGoalTeam2,
                    onDecrement: onDecrementTeam2
                )
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
        }
        .frame(height: 50)
    }
    
    func scoreFontSize(for score: Int, columnWidth: CGFloat) -> CGFloat {
        let digits = max(1, String(score).count)
        let base: CGFloat = switch digits {
        case 1: min(36, columnWidth * 1.35)
        case 2: min(30, columnWidth * 1.1)
        default: min(24, columnWidth * 0.95)
        }
        return max(18, base)
    }
}
