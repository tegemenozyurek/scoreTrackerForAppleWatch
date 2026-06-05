//
//  VolleyballScoreboardViews.swift
//  ScoreTracker Watch App
//
//  Created by Turgut Egemen Özyürek on 30.08.2025.
//

import SwiftUI

struct VolleyballPlayerScoreRow: View {
    let accentColor: Color
    let sportIcon: String
    let spinDegrees: Double
    let sets: Int
    let points: Int
    let isScoringEnabled: Bool
    let onTap: () -> Void
    
    private let iconColumnWidth: CGFloat = 58
    private let statColumnWidth: CGFloat = 36
    private let pointFontSize: CGFloat = 30
    
    var body: some View {
        HStack(spacing: 0) {
            Image(systemName: sportIcon)
                .font(.system(size: 38, weight: .medium))
                .foregroundStyle(accentColor)
                .symbolRenderingMode(.monochrome)
                .rotationEffect(.degrees(spinDegrees))
                .animation(.easeInOut(duration: TeamScoreBall.spinDuration), value: spinDegrees)
                .frame(width: iconColumnWidth)
            
            columnDivider
            
            TennisStatValueLabel(
                value: sets,
                accentColor: accentColor,
                columnWidth: statColumnWidth
            )
            
            columnDivider
            
            Text("\(points)")
                .font(.system(size: pointFontSize, weight: .bold))
                .foregroundColor(.white)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.vertical, 11)
        .padding(.horizontal, 10)
        .contentShape(Rectangle())
        .onTapGesture {
            guard isScoringEnabled else { return }
            onTap()
        }
        .allowsHitTesting(isScoringEnabled)
    }
    
    private var columnDivider: some View {
        Rectangle()
            .fill(accentColor.opacity(0.28))
            .frame(width: 1)
            .padding(.vertical, 6)
    }
}

struct VolleyballScoreboardRow: View {
    let team1Color: Color
    let team2Color: Color
    let sportIcon: String
    let volleyballState: VolleyballMatchState
    let team1Spin: Double
    let team2Spin: Double
    let isScoringEnabled: Bool
    let onPointTeam1: () -> Void
    let onPointTeam2: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            VolleyballPlayerScoreRow(
                accentColor: team1Color,
                sportIcon: sportIcon,
                spinDegrees: team1Spin,
                sets: volleyballState.set1,
                points: volleyballState.point1,
                isScoringEnabled: isScoringEnabled,
                onTap: onPointTeam1
            )
            
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [team1Color.opacity(0.55), team2Color.opacity(0.55)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)
            
            VolleyballPlayerScoreRow(
                accentColor: team2Color,
                sportIcon: sportIcon,
                spinDegrees: team2Spin,
                sets: volleyballState.set2,
                points: volleyballState.point2,
                isScoringEnabled: isScoringEnabled,
                onTap: onPointTeam2
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 4)
        .frame(height: 118)
    }
}
