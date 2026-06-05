//
//  BasketballScoreboardRow.swift
//  ScoreTracker Watch App
//
//  Created by Turgut Egemen Özyürek on 30.08.2025.
//

import SwiftUI

struct BasketballPointButton: View {
    let points: Int
    let color: Color
    let width: CGFloat
    let height: CGFloat
    let fontSize: CGFloat
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("+\(points)")
                .font(.system(size: fontSize, weight: .bold))
                .foregroundColor(.white)
                .frame(width: width, height: height)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.45)
    }
}

struct BasketballScoreboardRow: View {
    let team1Color: Color
    let team2Color: Color
    let sportIcon: String
    let team1Score: Int
    let team2Score: Int
    let timeString: String
    let team1Spin: Double
    let team2Spin: Double
    let isScoringEnabled: Bool
    let onAddPointsTeam1: (Int) -> Void
    let onAddPointsTeam2: (Int) -> Void
    let onDecrementTeam1: () -> Void
    let onDecrementTeam2: () -> Void
    
    var body: some View {
        GeometryReader { geo in
            let screenWidth = geo.size.width
            let buttonGap: CGFloat = 5
            let topRowGaps = buttonGap * 3
            let quarterWidth = (screenWidth - topRowGaps) / 4
            let halfWidth = (screenWidth - buttonGap) / 2
            let buttonHeight = min(34, quarterWidth)
            let buttonFontSize: CGFloat = buttonHeight >= 30 ? 14 : 12
            let buttonRowSpacing: CGFloat = 6
            let teamGap: CGFloat = 6
            let dashWidth: CGFloat = 10
            let scoreColumnWidth: CGFloat = 30
            let ballSide = min(46, max(36, screenWidth * 0.18))
            let maxScore = max(team1Score, team2Score)
            let scoreFontSize = scoreFontSize(for: maxScore, columnWidth: scoreColumnWidth)
            let dashFontSize = max(16, scoreFontSize * 0.75)
            let timerHeight: CGFloat = 18
            let contentHeight = ballSide + timerHeight + 6 + buttonHeight * 2 + buttonRowSpacing
            
            VStack(spacing: 6) {
                HStack(alignment: .top, spacing: teamGap) {
                    TeamScoreBall(
                        color: team1Color,
                        sportIcon: sportIcon,
                        spinDegrees: team1Spin,
                        side: ballSide,
                        allowsTapIncrement: false,
                        onIncrement: {},
                        onDecrement: onDecrementTeam1
                    )
                    
                    VStack(spacing: 3) {
                        HStack(spacing: 2) {
                            MatchScoreLabel(
                                score: team1Score,
                                columnWidth: scoreColumnWidth,
                                fontSize: scoreFontSize,
                                onGoal: {},
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
                                onGoal: {},
                                onDecrement: onDecrementTeam2
                            )
                        }
                        .fixedSize(horizontal: true, vertical: false)
                        
                        Text(timeString)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white.opacity(0.85))
                            .monospacedDigit()
                    }
                    
                    TeamScoreBall(
                        color: team2Color,
                        sportIcon: sportIcon,
                        spinDegrees: team2Spin,
                        side: ballSide,
                        allowsTapIncrement: false,
                        onIncrement: {},
                        onDecrement: onDecrementTeam2
                    )
                }
                .frame(maxWidth: .infinity, alignment: .center)
                
                VStack(spacing: buttonRowSpacing) {
                    HStack(spacing: buttonGap) {
                        BasketballPointButton(
                            points: 1,
                            color: team1Color,
                            width: quarterWidth,
                            height: buttonHeight,
                            fontSize: buttonFontSize,
                            isEnabled: isScoringEnabled,
                            action: { onAddPointsTeam1(1) }
                        )
                        
                        BasketballPointButton(
                            points: 2,
                            color: team1Color,
                            width: quarterWidth,
                            height: buttonHeight,
                            fontSize: buttonFontSize,
                            isEnabled: isScoringEnabled,
                            action: { onAddPointsTeam1(2) }
                        )
                        
                        BasketballPointButton(
                            points: 1,
                            color: team2Color,
                            width: quarterWidth,
                            height: buttonHeight,
                            fontSize: buttonFontSize,
                            isEnabled: isScoringEnabled,
                            action: { onAddPointsTeam2(1) }
                        )
                        
                        BasketballPointButton(
                            points: 2,
                            color: team2Color,
                            width: quarterWidth,
                            height: buttonHeight,
                            fontSize: buttonFontSize,
                            isEnabled: isScoringEnabled,
                            action: { onAddPointsTeam2(2) }
                        )
                    }
                    
                    HStack(spacing: buttonGap) {
                        BasketballPointButton(
                            points: 3,
                            color: team1Color,
                            width: halfWidth,
                            height: buttonHeight,
                            fontSize: buttonFontSize,
                            isEnabled: isScoringEnabled,
                            action: { onAddPointsTeam1(3) }
                        )
                        
                        BasketballPointButton(
                            points: 3,
                            color: team2Color,
                            width: halfWidth,
                            height: buttonHeight,
                            fontSize: buttonFontSize,
                            isEnabled: isScoringEnabled,
                            action: { onAddPointsTeam2(3) }
                        )
                    }
                }
                .frame(width: screenWidth)
            }
            .frame(width: screenWidth, height: contentHeight, alignment: .top)
            .padding(.top, 2)
        }
        .frame(height: 138)
    }
    
    func scoreFontSize(for score: Int, columnWidth: CGFloat) -> CGFloat {
        let digits = max(1, String(score).count)
        let base: CGFloat = switch digits {
        case 1: min(42, columnWidth * 1.4)
        case 2: min(36, columnWidth * 1.15)
        default: min(28, columnWidth * 0.95)
        }
        return max(20, base)
    }
}
